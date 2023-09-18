DOCUMENTATION = """
  name: providentia_v3
  plugin_type: inventory
  short_description: Providentia inventory source
  requirements:
    - requests >= 2.18.4
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
      required: True
    sso_token_url:
      description: The endpoint where token may be obtained for Providentia
    sso_client_id:
      description: SSO client id for Providentia.
      type: string
      default: "Providentia"
    credentials_lookup_env:
      description: ENV var used to lookup Providentia credentials KeePass path
      type: string
      default: KEEPASS_DEPLOYER_CREDENTIALS_PATH
      required: False
"""

from typing import DefaultDict
import requests
import os
import json
import socket
import aiohttp
import asyncio
from oauthlib.oauth2 import LegacyApplicationClient
from pykeepass import PyKeePass
from requests_oauthlib import OAuth2Session
from ansible.plugins.inventory import BaseInventoryPlugin
from ansible.errors import AnsibleError, AnsibleParserError
from ansible.utils.vars import combine_vars, load_extra_vars
from pprint import pprint

class InventoryModule(BaseInventoryPlugin):
  NAME = 'providentia_v3'

  def verify_file(self, path):
    if super(InventoryModule, self).verify_file(path):
      return True
    return False

  def parse(self, inventory, loader, path, cache=True):
    super(InventoryModule, self).parse(inventory, loader, path)
    self._read_config_data(path)
    # merge extra vars
    self._options = combine_vars(self._options, load_extra_vars(loader))

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
    keepass_creds = os.environ.get(self.get_option('credentials_lookup_env'),"").strip()
    sso_creds = self.fetch_creds(keepass_creds)

    self._access_token = self.fetch_access_token(sso_creds)

  def fetch_creds(self, creds_path):
    if 'KEEPASS_DEPLOYER_CREDENTIALS_PATH' in os.environ and os.environ['KEEPASS_DEPLOYER_CREDENTIALS_PATH'].strip() != "":

      kp_soc = "/tmp/ansible-keepass.sock"
      sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
      sock.connect(kp_soc)

      username = {'attr': "username", 'path': creds_path}
      sock.send(json.dumps(username).encode())
      username = json.loads(sock.recv(1024).decode())

      password = {'attr': "password", 'path': creds_path}
      sock.send(json.dumps(password).encode())
      password = json.loads(sock.recv(1024).decode())

      sock.close()

      if(username['status']=='error' or password['status']=='error'):
        raise Exception('Error retrieving credentials from Keepass')

      return {
        'username': username['text'],
        'password': password['text']
      }

    else:

      if(self.get_option('deployer_username') is None or self.get_option('deployer_password') is None):
        raise Exception('Error - deployer_username or deployer_password not found in Ansible vault')

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

    # Add groups to inventory
    # We do this in separate loop because of groups can reference to
    # child groups that may not have been added to inventory already
    for group_data in groups['result']:
      group = group_data['id']
      group_children = group_data['children']

      for child_group in group_children:
        self.inventory.add_child(group, child_group)

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
    exercise = self.get_option('exercise')

    url = f"{providentia_host}/api/v3/{exercise}/{endpoint}"

    headers = {
      'Authorization': f"{self._access_token['token_type']} {self._access_token['access_token']}"
    }
    async with self._session.get(url, headers=headers) as response:
      if response.status == 200:
        return await response.json()

      if response.status == 401:
        raise Exception('Providentia responded with 401: Unauthenticated')

      if response.status == 403:
        raise Exception('Requested token is not authorized to perform this action')

      if response.status == 404:
        raise Exception('Providentia responded with 404: not found')

      if response.status == 500:
        raise Exception('Providentia responded with 500: server error')

  def fetch_access_token(self, creds):
    client_id = self.get_option('sso_client_id')
    oauth = OAuth2Session(client=LegacyApplicationClient(client_id=client_id))
    token = oauth.fetch_token(
      token_url=self.get_option('sso_token_url'),
      username=creds['username'],
      password=creds['password'],
      client_id=client_id)

    return token
