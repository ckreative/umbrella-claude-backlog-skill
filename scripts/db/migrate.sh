#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

psql_db -v ON_ERROR_STOP=1 -f "$PROJECT_ROOT/sql/bootstrap/001_schema_migrations.sql"

for file in "$PROJECT_ROOT"/sql/migrations/*.sql; do
  version="$(basename "$file")"

  if psql_db -tAc "SELECT 1 FROM public.schema_migrations WHERE version = '$version'" | grep -q 1; then
    echo "Skipping $version"
    continue
  fi

  echo "Applying $version"
  psql_db -v ON_ERROR_STOP=1 -f "$file"
  psql_db -v ON_ERROR_STOP=1 -c "INSERT INTO public.schema_migrations (version) VALUES ('$version')"
done

echo "Migrations complete."

