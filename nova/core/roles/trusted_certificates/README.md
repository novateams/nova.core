# trusted_certificates

This role installs trusted certificates on the target Windows, Linux or VyOS system. Trusted certificates are used to verify the identity of a remote system. This role is used to install certificates that are not part of the default trusted certificate store. The source of the certificates can be a file for url.

## Requirements

The certificates must be in PEM (base64 encoded) format. The role will convert the certificates to the correct format for the target system.

## Role Variables

Refer to [defaults/main.yml](https://github.com/novateams/nova.core/blob/main/nova/core/roles/trusted_certificates/defaults/main.yml) for the full list of variables.

## Dependencies

none

## Example

```yaml
# This example will install the RootCA certificate from the url http://example.com/pem and the SecondRootCA certificate from the local file SecondRootCA.cer. The certificates will also be added to the Java truststore.
- name: Including trusted_certificates role...
  ansible.builtin.include_role:
    name: nova.core.trusted_certificates
  vars:
    trusted_certificates_to_jks: true
    trusted_certificates_list:
      - name: RootCA
        src: http://example.com/pem
      - name: SecondRootCA
        src: SecondRootCA.cer
```
