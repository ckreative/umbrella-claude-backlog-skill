# Umbrella Engineering Backlog

## Skill

Read `SKILL.md` for the full backlog interface — SQL functions, views, tags, and workflows.

**Triggers:** "backlog", "epic", "ticket", "sprint", "sync", "roadmap", "workload", "assign", "tag ticket", "blocked", "current work", "weekly activity"

## Core Commands

```bash
bash scripts/db/migrate.sh          # Run migrations
bash scripts/db/test.sh             # Verify schema
bash scripts/db/psql.sh             # Interactive SQL
bash scripts/db/import_wave2_spec.sh # Import Wave 2 spec
```

## Conventions

- All backlog data lives in the `backlog` schema
- Use the stable SQL functions (not raw INSERT/UPDATE) to modify data
- Run `bash scripts/db/test.sh` after any schema changes
