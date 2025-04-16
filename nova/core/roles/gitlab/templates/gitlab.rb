external_url '{{ gitlab_url }}'
gitlab_rails['initial_root_password'] = '{{ gitlab_initial_root_personal_passwd }}'
gitlab_rails['gitlab_shell_ssh_port'] = '{{ gitlab_ssh_port }}'
gitlab_rails['lfs_enabled'] = true

### gitlab pages https://docs.gitlab.com/ee/administration/pages/
{% if gitlab_pages_enabled is sameas true %}
gitlab_pages['internal_gitlab_server'] = 'http://localhost:8080'
pages_external_url '{{ gitlab_pages_url }}'
pages_nginx['enable'] = true
pages_nginx['listen_port'] = 80
pages_nginx['listen_https'] = false
pages_nginx['redirect_http_to_https'] = false
{% endif %}

### gitlab registry https://docs.gitlab.com/ee/user/packages/
registry['enable'] = {{ gitlab_registry_enabled | string | lower }}
gitlab_rails['registry_enabled'] = {{ gitlab_registry_enabled | string | lower }}
{% if gitlab_registry_enabled is sameas true %}
gitlab_rails['registry_host'] = '{{ gitlab_registry_fqdn }}'
registry_external_url '{{ gitlab_registry_url }}'
registry_nginx['listen_port'] = 80
registry_nginx['listen_https'] = false
{% endif %}

### gitlab nginx ( internal ) https://docs.gitlab.com/omnibus/settings/nginx.html
nginx['listen_port'] = 80
nginx['listen_https'] = false
nginx['client_max_body_size'] = '0'
nginx['redirect_http_to_https'] = false
nginx['hsts_max_age'] = 0
nginx['proxy_protocol'] = false

nginx['real_ip_trusted_addresses'] = {{ gitlab_nginx_real_ip_trusted_addresses }}
nginx['real_ip_header'] = '{{ gitlab_nginx_real_ip_header }}'
nginx['real_ip_recursive'] = 'on'

### gitlab smtp https://docs.gitlab.com/omnibus/settings/smtp.html
gitlab_rails['smtp_enable'] = {{ gitlab_smtp_enabled | string | lower }}
{% if gitlab_smtp_enabled is sameas true %}
gitlab_rails['smtp_address'] = '{{ gitlab_smtp_address }}'
gitlab_rails['smtp_domain'] = '{{ gitlab_smtp_domain }}'
gitlab_rails['smtp_port'] = {{ gitlab_smtp_port }}
gitlab_rails['smtp_tls'] = {{ gitlab_smtp_tls | string | lower }}
gitlab_rails['smtp_enable_starttls_auto'] = {{ gitlab_smtp_enable_starttls_auto | string | lower }}
{% if gitlab_smtp_openssl_verify_mode is not sameas false %}
gitlab_rails['smtp_openssl_verify_mode'] = '{{ gitlab_smtp_openssl_verify_mode }}'
{% endif %}
{% if gitlab_smtp_authentication is not sameas false %}
gitlab_rails['smtp_authentication'] = '{{ gitlab_smtp_authentication }}'
{% endif %}
{% if gitlab_smtp_username is not sameas false %}
gitlab_rails['smtp_user_name'] = '{{ gitlab_smtp_username }}'
{% endif %}
{% if gitlab_smtp_password is not sameas false %}
gitlab_rails['smtp_password'] = '{{ gitlab_smtp_password }}'
{% endif %}
gitlab_rails['gitlab_email_from'] = '{{ gitlab_email_from }}'
gitlab_rails['gitlab_email_reply_to'] = '{{ gitlab_email_reply_to }}'
{% endif %}

### gitlab ldap https://docs.gitlab.com/ee/administration/auth/ldap/index.html#basic-configuration-settings
gitlab_rails['ldap_enabled'] = {{ gitlab_ldap_enabled | string | lower  }}
gitlab_rails['prevent_ldap_sign_in'] = false
gitlab_rails['ldap_servers'] = {
  'main' => {
    'label' => '{{ gitlab_ldap_label }}',
    'host' =>  '{{ gitlab_ldap_server }}',
    'port' => '{{ gitlab_ldap_port }}',
    'uid' => 'sAMAccountName',
    'bind_dn' => '{{ gitlab_ldap_user_dn }}',
    'password' => '{{ gitlab_ldap_user_password }}',
    'encryption' => '{{ gitlab_ldap_encryption | default("plain") }}',
    'verify_certificates' => {{ gitlab_ldap_verify_certificates | default("true") | lower }},
    'timeout' => 10,
    'active_directory' => {{ gitlab_active_directory | default("true") | lower }},
    'allow_username_or_email_login' => false,
    'block_auto_created_users' => false,
    'base' => '{{ gitlab_ldap_domain_ou_base }}',
    'user_filter' => '(objectclass=user)',
    'attributes' => {
      'username' => ['uid', 'userid', 'sAMAccountName'],
      'email' => ['mail', 'email', 'userPrincipalName'],
      'name' => 'cn',
      'first_name' => 'givenName',
      'last_name' => 'sn'
    },
    'lowercase_usernames' => false,
    'group_base' => '{{ gitlab_ldap_domain_groups_ou }}',
    'admin_group' => 'Domain Admins',
    'external_groups' => [],
    'sync_ssh_keys' => false
  }
}
