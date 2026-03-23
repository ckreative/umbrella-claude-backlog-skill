# Umbrella Engineering Backlog

## Skill

Read `SKILL.md` for the full backlog interface — SQL functions, views, tags, and workflows.

**Triggers:** "backlog", "epic", "ticket", "sprint", "sync", "roadmap", "workload", "assign", "tag ticket", "blocked", "current work", "weekly activity"

## Core Command

```bash
bash scripts/db/psql.sh             # Interactive SQL session
```

## Conventions

- All backlog data lives in the `backlog` schema
- Use the stable SQL functions (not raw INSERT/UPDATE) to modify data
