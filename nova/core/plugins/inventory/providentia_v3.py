DOCUMENTATION = """
    name: nova.core.providentia_v3
    plugin_type: inventory
    short_description: Providentia inventory source
    requirements:
        - requests_oauthlib
        - oauthlib
    description:
        - Get inventory hosts and groups from Providentia.
        - Uses a YAML configuration file that ends with providentia.(yml|yaml).
    options:
        plugin:
            description: token that ensures this is a source file for the 'providentia' plugin.
            required: True
        providentia_host:
            description: Root URL to Providentia.
            type: string
            required: True
        environment:
            description: |
                Free text field to define the general environment for the project eg. org name, dev, staging, prod etc.
                Can be used for setting env specific credentials for matching project names.
            type: string
            required: False
        project:
            description: Project abbreviation which defines configuration to populate inventory with.
            type: string
            required: True
        sso_token_url:
            description: The endpoint where token may be obtained for Providentia
        sso_client_id:
            description: SSO client id for Providentia.
            type: string
            default: Providentia
"""
import os, aiohttp, asyncio, time, json, functools
from oauthlib.oauth2 import LegacyApplicationClient
from requests_oauthlib import OAuth2Session
from ansible.plugins.inventory import BaseInventoryPlugin
from ansible.errors import AnsibleParserError
from ansible.utils.vars import combine_vars, load_extra_vars

# To enable async functions set
# export PROVIDENTIA_PLUGIN_TIMING=1
ENABLE_TIMING = bool(int(os.getenv("PROVIDENTIA_PLUGIN_TIMING", "0")))

class InventoryModule(BaseInventoryPlugin):
    NAME = 'nova.core.providentia_v3'

    #############################
    # Optional timing decorator #
    #############################

    def timed(func):
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            if ENABLE_TIMING:
                start = time.time()
                result = await func(*args, **kwargs)
                end = time.time()
                print(f"[TIMER] {func.__qualname__} took {end - start:.2f}s")
                return result
            else:
                return await func(*args, **kwargs)
        return wrapper

    ############################
    # Inventory initialization #
    ############################

    def verify_file(self, path):
        if super(InventoryModule, self).verify_file(path):
            return True
        return False

    def parse(self, inventory, loader, path, cache=True):
        '''
            inventory: inventory object with existing data and the methods to add hosts/groups/variables to inventory
            loader: Ansible DataLoader. The DataLoader can read files, auto load JSON/YAML and decrypt vaulted data, and cache read files.
            path: string with inventory source (this is usually a path, but is not required)
            cache: indicates whether the plugin should use or avoid caches (cache plugin and/or loader)
        '''
        super(InventoryModule, self).parse(inventory, loader, path, cache=cache)
        self._read_config_data(path)

        # Merging extra vars
        self._options = combine_vars(self._options, load_extra_vars(loader))

        # Making sure all variables coming from the inventory file can be templated with jinja
        self.templar.available_variables = self._vars
        for key, value in self._options.items():
                self._options[key] = self.templar.template(value)

        self.project = self.templar.template(self.get_option('project'))
        self.providentia_host = self.templar.template(self.get_option('providentia_host'))
        self.sso_client_id = self.templar.template(self.get_option('sso_client_id'))
        self.sso_token_url = self.templar.template(self.get_option('sso_token_url'))

        # Templating environment variable if it is set, since it's optional
        self.environment = (
            self.templar.template(self.get_option('environment'))
            if self.get_option('environment') is not None else None
        )

        asyncio.run(self.run())

    def init_inventory(self):
        self.inventory.add_group("all")
        self.inventory.set_variable("all", "providentia_api_version", 3)

    ########################
    # Inventory generation #
    ########################

    @timed
    async def generate_inventory(self):

        # Run all fetches concurrently
        hosts, groups, project_info = await asyncio.gather(
            self.fetch_from_providentia('inventory'),
            self.fetch_from_providentia('tags'),
            self.fetch_from_providentia('')
        )

        for key,value in project_info['result'].items():
                # Replacing nondescriptive keys with more descriptive ones
                if key == 'name':
                    key = 'providentia_project_display_name'
                if key == 'id':
                    key = 'providentia_project_id'
                if key == 'description':
                    key = 'providentia_project_description'
                self.inventory.set_variable("all", key, value)

        # Add groups to inventory
        for group_data in groups['result']:
            group = group_data['id']
            group_vars = group_data['config_map']
            priority = group_data.get('priority')

            self.inventory.add_group(group)

            # Add group specific variables to group
            for key, value in group_vars.items():
                self.inventory.set_variable(group, key, value)

            if priority:
                self.inventory.set_variable(group, 'ansible_group_priority', int(priority))

        # List of Providentia keys that should be excluded from being added as variables
        excluded_keys = {"instances", "tags"}

        for host in hosts['result']:
            host_tags = host.get('tags', [])
            instances = host.get('instances', [])

            for host_instance in instances:
                host_instance_id = host_instance['id']
                self.inventory.add_host(host_instance_id)

                # Set main_id
                self.inventory.set_variable(host_instance_id, "main_id", host['id'])

                # Combine variables from host and host_instance
                host_vars = {k: v for k, v in host.items() if k not in excluded_keys}
                instance_vars = {k: v for k, v in host_instance.items() if k not in excluded_keys}

                combined_vars = {**host_vars, **instance_vars}
                for k, v in combined_vars.items():
                    self.inventory.set_variable(host_instance_id, k, v)

                # Add tags to groups
                for group in host_tags + host_instance.get('tags', []):
                    self.inventory.add_child(group, host_instance_id)

    #############################################
    # Providentia API endpoint request function #
    #############################################

    @timed
    async def fetch_from_providentia(self, endpoint=""):
        url = f"{self.providentia_host}/api/v3/{self.project}/{endpoint}"

        headers = {
            "Authorization": f"{self._access_token['token_type']} {self._access_token['access_token']}",
            "Accept": "application/json",
        }

        # Inventory-only cache
        if endpoint == "inventory":
            etag_file = f"/tmp/providentia_{self.project}_inventory.etag"
            cache_file = f"/tmp/providentia_{self.project}_inventory.json"

            if os.path.exists(etag_file):
                with open(etag_file) as f:
                    headers["If-None-Match"] = f.read().strip()

        async with self._session.get(url, headers=headers) as response:
            if endpoint == "inventory" and response.status == 304:
                with open(cache_file) as f:
                    return json.load(f)

            if response.status == 200:
                data = await response.json()
                if endpoint == "inventory":
                    etag = response.headers.get("ETag")
                    if etag:
                        with open(etag_file, "w") as f:
                            f.write(etag)
                        with open(cache_file, "w") as f:
                            json.dump(data, f)
                return data

            if response.status == 401:
                raise AnsibleParserError("Providentia responded with 401: Unauthenticated")
            if response.status == 403:
                raise AnsibleParserError("Providentia responded with 403: Forbidden")
            if response.status == 404:
                raise AnsibleParserError("Providentia responded with 404: Not found")
            if response.status >= 500:
                raise AnsibleParserError("Providentia server error")

            raise AnsibleParserError(f"Providentia responded with {response.status}")

    ###################################
    # Credentials and token functions #
    ###################################

    def fetch_creds(self):
        """
        Retrieve deployer credentials from Ansible Vault in the following order of precedence:
        1. Environment and project specific deployer credentials eg. dev_projectA_deployer_username
        2. Project specific deployer credentials eg. projectA_deployer_username
        3. Default deployer credentials eg. deployer_username
        """
        if self.environment is not None:
            env_project_deployer_username = self._options.get(f"{self.environment}_{self.project}_deployer_username")
            env_project_deployer_password = self._options.get(f"{self.environment}_{self.project}_deployer_password")
        else:
            env_project_deployer_username = None
            env_project_deployer_password = None

        # Feature to allow project specific deployer credentials from Ansible vault
        project_deployer_username = self._options.get(f"{self.project}_deployer_username")
        project_deployer_password = self._options.get(f"{self.project}_deployer_password")

        if env_project_deployer_username is not None and env_project_deployer_password is not None:

            # Adding env and project specific deployer credentials as variables
            self.inventory.set_variable("all", "project_deployer_username", env_project_deployer_username)
            self.inventory.set_variable("all", "project_deployer_password", env_project_deployer_password)

            return {
                'username': env_project_deployer_username,
                'password': env_project_deployer_password
            }

        elif project_deployer_username is not None and project_deployer_password is not None:

            # Adding project specific deployer credentials as variables
            self.inventory.set_variable("all", "project_deployer_username", project_deployer_username)
            self.inventory.set_variable("all", "project_deployer_password", project_deployer_password)

            return {
                'username': project_deployer_username,
                'password': project_deployer_password
            }

        else:

            if self.get_option('deployer_username') is None:
                raise AnsibleParserError('Error - deployer_username not found in Ansible vault')

            if self.get_option('deployer_password') is None:
                raise AnsibleParserError('Error - deployer_password not found in Ansible vault')

            return {
                'username': self.get_option('deployer_username'),
                'password': self.get_option('deployer_password')
            }

    def fetch_access_token(self, creds):
        oauth = OAuth2Session(client=LegacyApplicationClient(client_id=self.sso_client_id))
        token = oauth.fetch_token(
            token_url=self.sso_token_url,
            username=creds['username'],
            password=creds['password'],
            client_id=self.sso_client_id)

        return token

    async def store_access_token(self):
        self._access_token = self.fetch_access_token(self.fetch_creds())

    ###########################
    # Main function execution #
    ###########################

    @timed
    async def run(self):
        self.init_inventory()
        await self.store_access_token()
        async with aiohttp.ClientSession() as session:
            self._session = session
            await self.generate_inventory()
