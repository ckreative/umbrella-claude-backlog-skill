#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

"$PROJECT_ROOT/scripts/db/migrate.sh"

for file in "$PROJECT_ROOT"/sql/tests/*.sql; do
  echo "Testing $(basename "$file")"
  psql_db -v ON_ERROR_STOP=1 -f "$file"
done

echo "Validation complete."

