# outline

These are the required variables that you need to define for your environment.

```yaml
## Database password
postgres_password:

## For accessing the configured bucket in minio
outline_s3_access_key_id:
outline_s3_secret_access_key:

## These secrets need to be 32 byte hex strings. Generate with "openssl rand -hex 32"
outline_secret_key:
outline_utils_secret_key:

## Generic OIDC configuration
outline_oidc_client_id:
outline_oidc_client_secret:

## Example with keycloak
outline_oidc_auth_uri: https://keycloak.example.net/auth/realms/EXAMPLE/protocol/openid-connect/auth
outline_oidc_token_uri: https://keycloak.example.net/auth/realms/EXAMPLE/protocol/openid-connect/token
outline_oidc_userinfo_uri: https://keycloak.example.net/auth/realms/EXAMPLE/protocol/openid-connect/userinfo

## Outline landing page visual effect only
outline_oidc_display_name: "OIDC provider"
```

## Minio for s3 compatible file storage service

The latest versions of outline can now store files in a filesystem mount, previously an s3 service was a requirement.
This role still uses minio for s3. We have not tested the new feature yet.

## Minio

Using this role we setup minio to be hosted on the same instance as outline itself, behind a reverse proxy. The minio service opens 2 ports - one for the user facing API and one for the administration console.

Once the minio service is up, using the administrators console, create a bucket for outline file storage. Add a user and assign an access policy that allows access to said bucket.
Do not leave the bucket open as a "public bucket"

Bucket access policy example - take care that you define the correct bucket name.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads"
      ],
      "Resource": ["arn:aws:s3:::odata"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListMultipartUploadParts",
        "s3:PutObject"
      ],
      "Resource": ["arn:aws:s3:::odata/*"]
    }
  ]
}
```

## Public folders in the private bucket

Outline wants to store and show user profile pictures under **bucketname/public/** and some other avatars under **bucketname/avatars/**.
Since we have locked down our bucket to be private, we have to add anonymous access rules under the bucket configuration (readonly access)

```shell
avatars/
public/
```

## Minio automatic configuration for outline

This role will also configure the minio service for outline, using minio client.
Default is set to **true** by variable `minio_client_configuration`

## Reverse proxy for the services

Configuring a reverse proxy is not in the scope of this role.
Example configuration: <https://docs.getoutline.com/s/hosting/doc/nginx-6htaRboR57>

Keep in mind that you need to configure the reverse proxy for the outline service **and** the s3 service as well.

Example

- <https://outline.domain.tld> -> <http://outline:3000>
- <https://s3-outline.domain.tld> -> <http://outline:9000>
- <https://s3-console-outline.domain.tld> -> <http://outline-storage:9090>

## Importing and exporting

- In order for the exporting/importing functions to be successful, please make sure that you have connectivity between the outline application container and the s3 service (that can also be a container, running on the same host).
- If importing or exporting fails, make sure that there are no DNS issues (that the outline container can resolve the s3 service), no certificate trust issues etc.
- Exporting the wiki **does not include users, groups or any permission schemes**, only articles and attachments are included. Makes sense to always make backups at the OS level as well.
- Exporting the wiki includes only those collections that you have the permissions to read, even if you are admin.
