# Umbrella Claude Code Backlog Skill

Self-contained Claude Code skill for managing the Umbrella engineering backlog on Supabase Postgres.

## Setup

```bash
git clone https://github.com/ckreative/umbrella-claude-backlog-skill.git
cd umbrella-claude-backlog-skill
cp .env.example .env   # fill in DATABASE_URL + Supabase keys (get from your team lead)
claude
```

The database is already migrated and populated on the hosted Supabase instance. You just need credentials.

## What It Does

Gives Claude Code full knowledge of the Umbrella backlog system:

- **Write operations** — create epics, tickets, tags; assign work; transition status; log work
- **Read operations** — query the backlog, sync views, blocked tickets, workload summaries
- **Tag taxonomy** — platform tags (mobile, desktop, ai) and domain tags (navigation, workspaces, etc.)
- **Team workflows** — intake roadmap work, run product-engineering sync, slice by tags

## What You Can Ask

- "Show me the current backlog"
- "List tickets in epic W2-E10"
- "What's blocked?"
- "Show mobile platform work"
- "Create a ticket for..."
- "Assign ticket CS-01 to alex"
- "What did alex work on last week?"

## Prerequisites

- `psql` — [install guide](https://www.postgresql.org/download/)
- Database credentials (ask your team lead for the `.env` values)

## Scripts

| Command | Purpose |
|---------|---------|
| `bash scripts/db/psql.sh` | Interactive SQL session |
| `bash scripts/db/migrate.sh` | Run SQL migrations (admin only) |
| `bash scripts/db/test.sh` | Verify schema and functions (admin only) |
| `bash scripts/db/import_wave2_spec.sh` | Import Wave 2 roadmap spec (admin only) |

## Also Available

Codex (OpenAI) version: [ckreative/umbrella-codex-backlog-skill](https://github.com/ckreative/umbrella-codex-backlog-skill)
