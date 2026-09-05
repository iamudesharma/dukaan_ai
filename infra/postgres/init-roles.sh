#!/bin/sh
# Create the least-privilege application role on first init of the local
# Postgres volume. Runs once via docker-entrypoint-initdb.d; deleting the
# volume re-runs it. Table/sequence grants are applied by the Django RLS
# migration when the role exists.
set -eu

: "${POSTGRES_USER:?POSTGRES_USER is required}"
: "${POSTGRES_DB:?POSTGRES_DB is required}"
: "${DUKAAN_APP_DB_PASSWORD:?DUKAAN_APP_DB_PASSWORD is required}"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<EOSQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dukaan_app') THEN
    CREATE ROLE dukaan_app LOGIN PASSWORD '${DUKAAN_APP_DB_PASSWORD}';
  END IF;
END
\$\$;
GRANT CONNECT ON DATABASE "${POSTGRES_DB}" TO dukaan_app;
GRANT USAGE ON SCHEMA public TO dukaan_app;
EOSQL
