# Umbrella Claude Code Backlog Skill

Claude Code skill for managing the [Umbrella](https://github.com/ckreative/umbrella) engineering backlog.

This skill teaches Claude Code how to operate the Umbrella backlog — it references scripts and SQL functions that live in the main [Umbrella repo](https://github.com/ckreative/umbrella). You must have the Umbrella repo cloned and set up before using this skill.

## Install

The Umbrella repo already includes this skill at `.claude/skills/umbrella-backlog/`. If you've cloned the Umbrella repo, **you already have it** — no extra install needed.

If for some reason you need to install it manually:

```bash
cd /path/to/umbrella
mkdir -p .claude/skills/umbrella-backlog/references
curl -sL https://raw.githubusercontent.com/ckreative/umbrella-claude-backlog-skill/main/SKILL.md \
  -o .claude/skills/umbrella-backlog/SKILL.md
curl -sL https://raw.githubusercontent.com/ckreative/umbrella-claude-backlog-skill/main/references/backlog-surface.md \
  -o .claude/skills/umbrella-backlog/references/backlog-surface.md
```

## What It Does

Gives Claude Code full knowledge of the Umbrella backlog system:

- **Write operations** — create epics, tickets, tags; assign work; transition status; log work
- **Read operations** — query the backlog, sync views, blocked tickets, workload summaries
- **Tag taxonomy** — platform tags (mobile, desktop, ai) and domain tags (navigation, workspaces, etc.)
- **Team workflows** — intake roadmap work, run product-engineering sync, slice by tags

The skill references shell scripts (`scripts/db/psql.sh`, `scripts/db/migrate.sh`, etc.) and SQL functions that live in the Umbrella repo — not in this skill repo.

## What You Can Ask

- "Show me the current backlog"
- "List tickets in epic W2-E10"
- "What's blocked?"
- "Show mobile platform work"
- "Create a ticket for..."
- "Assign ticket CS-01 to alex"
- "What did alex work on last week?"

## Requirements

- The [Umbrella](https://github.com/ckreative/umbrella) repo cloned and set up (migrations run, `.env` configured with `DATABASE_URL`)
- `psql` installed
- Claude Code

## Also Available

Codex (OpenAI) version: [ckreative/umbrella-codex-backlog-skill](https://github.com/ckreative/umbrella-codex-backlog-skill)
