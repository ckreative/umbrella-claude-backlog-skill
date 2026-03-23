#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

bash "$PROJECT_ROOT/scripts/db/migrate.sh" >/dev/null

psql_db -v ON_ERROR_STOP=1 -f "$PROJECT_ROOT/sql/imports/20260323_wave2_spec.sql"

echo "Wave 2 spec import complete."
