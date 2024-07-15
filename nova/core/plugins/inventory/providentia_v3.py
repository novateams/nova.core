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
    exercise:
      description: Exercise abbreviation which defines configuration to populate inventory with.
      type: string
      required: False
    project:
      description: Project abbreviation which defines configuration to populate inventory with.
      type: string
      required: False
    sso_token_url:
      description: The endpoint where token may be obtained for Providentia
    sso_client_id:
      description: SSO client id for Providentia.
      type: string
      default: "Providentia"
"""

import os, json, socket, aiohttp, asyncio
from oauthlib.oauth2 import LegacyApplicationClient
from requests_oauthlib import OAuth2Session
from ansible.plugins.inventory import BaseInventoryPlugin
from ansible.errors import AnsibleParserError
from ansible.utils.vars import combine_vars, load_extra_vars

class InventoryModule(BaseInventoryPlugin):
  NAME = 'nova.core.providentia_v3'

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
    super(InventoryModule, self).parse(inventory, loader, path)
    self._read_config_data(path)

    # Merging extra vars
    self._options = combine_vars(self._options, load_extra_vars(loader))

    # Making sure all variables coming from the inventory file can be templated with jinja
    self.templar.available_variables = self._vars
    for key, value in self._options.items():
        self._options[key] = self.templar.template(value)

    # Checking for deprecated exercise option in the inventory file
    if self.get_option('exercise') is not None:
        print("\033[93m[DEPRECATION WARNING]: The 'exercise' option will be deprecated. Replace 'exercise' with 'project' in your Providentia inventory file.\033[0m")
        self.project = self.templar.template(self.get_option('exercise'))

    if self.get_option('project') is not None:
        self.project = self.templar.template(self.get_option('project'))

    asyncio.run(self.run())

  async def run(self):
    self.init_inventory()
    await self.store_access_token()

    async with aiohttp.ClientSession() as session:
      self._session = session
      await self.fetch_environment()
      await self.fetch_groups()
      await self.fetch_hosts()

  def init_inventory(self):
    self.inventory.add_group("all")
    self.inventory.set_variable("all", "providentia_api_version", 3)

  async def store_access_token(self):
    self._access_token = self.fetch_access_token(self.fetch_creds())

  def fetch_creds(self):

    # Feature to allow project specific deployer credentials from Ansible vault
    project_deployer_username = self._options.get(self.project + '_deployer_username')
    project_deployer_password = self._options.get(self.project + '_deployer_password')

    if project_deployer_username is not None and project_deployer_password is not None:

      # Adding project specific deployer credentials as variables
      self.inventory.set_variable("all", "project_deployer_username", project_deployer_username)
      self.inventory.set_variable("all", "project_deployer_password", project_deployer_password)

      return {
        'username': project_deployer_username,
        'password': project_deployer_password
      }

    # Feature to get deployer credentials from Ansible vault
    else:

      if(self.get_option('deployer_username') is None or self.get_option('deployer_password') is None):
        raise AnsibleParserError('Error - deployer_username or deployer_password not found in Ansible vault')

      return {
        'username': self.get_option('deployer_username'),
        'password': self.get_option('deployer_password')
      }

  async def fetch_environment(self):
    event = await self.fetch_from_providentia('')
    for key,value in event['result'].items():
      self.inventory.set_variable("all", key, value)

  async def fetch_groups(self):
    groups = await self.fetch_from_providentia('tags')

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

  async def fetch_hosts(self):
    hosts = await self.fetch_from_providentia('inventory')

    # List of keys that should be excluded from host variables to avoid endless recursion and overwriting
    excluded_keys = ["id", "instances"]

    # Creating a new dictionary with filtered parent vars using first host as a template since all of the host have the same keys
    filtered_parent_vars = {key: value for key, value in hosts['result'][0].items() if key not in excluded_keys}

    # Add hosts to inventory
    for host in hosts['result']:
      for host_instance in host.get('instances', []):
        host_instance_id = host_instance['id']
        self.inventory.add_host(host_instance_id)

        self.inventory.set_variable(host_instance_id, "main_id", host['id'])

        for var_name in filtered_parent_vars:
          if var_name in host:
            self.inventory.set_variable(host_instance_id, var_name, host[var_name])

        for key, value in host_instance.items():
          self.inventory.set_variable(host_instance_id, key, value)

        for group in host.get('tags', []):
          self.inventory.add_child(group, host_instance_id)

        for group in host_instance.get('tags', []):
          self.inventory.add_child(group, host_instance_id)

  async def fetch_from_providentia(self, endpoint=""):
    providentia_host = self.get_option('providentia_host')
    url = f"{providentia_host}/api/v3/{self.project}/{endpoint}"

    headers = {
      'Authorization': f"{self._access_token['token_type']} {self._access_token['access_token']}"
    }
    async with self._session.get(url, headers=headers) as response:
      if response.status == 200:
        return await response.json()

      elif response.status == 401:
        raise AnsibleParserError('Providentia responded with 401: Unauthenticated')

      elif response.status == 403:
        raise AnsibleParserError('Requested token is not authorized to perform this action')

      elif response.status == 404:
        raise AnsibleParserError('Providentia responded with 404: not found')

      elif response.status == 500:
        raise AnsibleParserError('Providentia responded with 500: server error')

      else:
        raise AnsibleParserError('Fetching Providentia responded with ' + str(response.status))

  def fetch_access_token(self, creds):
    client_id = self.get_option('sso_client_id')
    oauth = OAuth2Session(client=LegacyApplicationClient(client_id=client_id))
    token = oauth.fetch_token(
      token_url=self.get_option('sso_token_url'),
      username=creds['username'],
      password=creds['password'],
      client_id=client_id)

    return token
