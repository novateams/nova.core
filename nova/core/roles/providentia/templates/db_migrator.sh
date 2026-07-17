#!/bin/bash
set -euo pipefail

docker volume create --name providentia_postgresql_data
docker run --rm -v providentia_database_storage:/from -v providentia_postgresql_data:/to alpine sh -c "apk add --no-cache rsync; rsync -av /from/ /to/"
docker run --rm -d --name providentia_db_migration -v providentia_postgresql_data:/var/lib/postgresql/data {{ providentia_builtin_database_image }}

until docker exec providentia_db_migration pg_isready -U providentia -d {{ providentia_builtin_database_name }}; do
  echo "Waiting for Postgres..."
  sleep 1
done

docker exec providentia_db_migration createuser -U providentia --superuser tempuser

docker exec providentia_db_migration psql -U tempuser postgres \
  -c "ALTER USER providentia WITH PASSWORD '{{ providentia_builtin_database_superuser_password }}';" \
  -c "ALTER USER providentia RENAME TO {{ providentia_builtin_database_superuser }};";

docker exec providentia_db_migration psql -U {{ providentia_builtin_database_superuser }} {{ providentia_builtin_database_name }} \
  -c "DROP ROLE tempuser;" \
  -c "CREATE USER {{ providentia_builtin_database_app_user }} WITH PASSWORD '{{ providentia_builtin_database_app_password }}';" \
  -c "GRANT CONNECT ON DATABASE {{ providentia_builtin_database_name }} TO {{ providentia_builtin_database_app_user }};" \
  -c "GRANT USAGE ON SCHEMA public TO {{ providentia_builtin_database_app_user }};" \
  -c "ALTER DATABASE {{ providentia_builtin_database_name }} OWNER TO {{ providentia_builtin_database_app_user }};" \
  -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO {{ providentia_builtin_database_app_user }};" \
  -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO {{ providentia_builtin_database_app_user }};" \
  -c "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO {{ providentia_builtin_database_app_user }};" \
  -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO {{ providentia_builtin_database_app_user }};" \
  -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO {{ providentia_builtin_database_app_user }};" \
  -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON FUNCTIONS TO {{ providentia_builtin_database_app_user }};";

echo "SELECT 'ALTER TABLE '|| schemaname || '.\"' || tablename ||'\" OWNER TO {{ providentia_builtin_database_app_user }};' FROM pg_tables WHERE NOT schemaname IN ('pg_catalog', 'information_schema') ORDER BY schemaname, tablename; \gexec" |  docker exec -i providentia_db_migration psql -U {{ providentia_builtin_database_superuser }} {{ providentia_builtin_database_name }}
echo "SELECT 'ALTER SEQUENCE '|| sequence_schema || '.\"' || sequence_name ||'\" OWNER TO {{ providentia_builtin_database_app_user }};' FROM information_schema.sequences WHERE NOT sequence_schema IN ('pg_catalog', 'information_schema') ORDER BY sequence_schema, sequence_name; \gexec" |  docker exec -i providentia_db_migration psql -U {{ providentia_builtin_database_superuser }} {{ providentia_builtin_database_name }}

docker rm --force providentia_db_migration
docker volume rm providentia_database_storage
