# configure_package_mirrors

This role is used to configure package mirrors for Linux apt repos or Windows Chocolatey package manager.

## Requirements

### Windows

[Chocolatey](https://chocolatey.org/install) must be installed on the machine.

### Linux

none

## Role Variables

Refer to the [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/template_os_configuration/defaults/main.yml) file for a list and description of the variables used in this role.

## Dependencies

none

## Example

```yaml
- name: Configuring package mirrors for Kali or Ubuntu...
  ansible.builtin.include_role:
    name: nova.core.configure_package_mirrors
```

```yaml
- name: Configuring package mirrors for Chocolatey...
  ansible.builtin.include_role:
    name: nova.core.configure_package_mirrors
  vars:
    package_mirror_chocolatey_sources_list:
      - package_mirror_chocolatey_source_name: choco-mirror
        package_mirror_chocolatey_source_state: present
        package_mirror_chocolatey_source: https://nexus.example.com/repository/choco-mirror/
        package_mirror_chocolatey_source_priority: 1
```

```yaml
- name: Configuring package mirrors for Chocolatey with authentication...
  ansible.builtin.include_role:
    name: nova.core.configure_package_mirrors
  vars:
    package_mirror_chocolatey_sources_list:
      - package_mirror_chocolatey_source_name: choco-mirror
        package_mirror_chocolatey_source_state: present
        package_mirror_chocolatey_source: https://nexus.example.com/repository/choco-mirror/
        package_mirror_chocolatey_source_priority: 1
        package_mirror_chocolatey_username: admin
        package_mirror_chocolatey_password: password
```

```yaml
- name: Configuring package mirrors for Ubuntu...
  ansible.builtin.include_role:
    name: nova.core.configure_package_mirrors
  vars:
    package_mirror_ubuntu_uri: 
      general: "https://nexus.example.com/repository/{{ ansible_facts.lsb.codename }}/"
      updates: "https://nexus.example.com/repository/{{ ansible_facts.lsb.codename }}-updates/"
      security: "https://nexus.example.com/repository/{{ ansible_facts.lsb.codename }}-security/"
      backports: "https://nexus.example.com/repository/{{ ansible_facts.lsb.codename }}-backports/"
```
