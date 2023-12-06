#!/bin/tcsh

# THIS SCRIPT RUNS WITH CRON ON REBOOT TO MAKE SURE THAT admin_accounts IN PFSENSE USERS ARE IN THE WHEEL GROUP

{% for user in admin_accounts %}
pw usermod {{ user.username }} -g {{ unix_distro_root_group_map[ansible_distribution] }}
{% endfor %}
