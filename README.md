# Umbrella Claude Code Backlog Skill

Claude Code skill for managing the [Umbrella](https://github.com/ckreative/umbrella) engineering backlog.

## Install

### Option 1: Install script

Clone this repo and run the install script from your Umbrella project root:

```bash
git clone https://github.com/ckreative/umbrella-claude-backlog-skill.git /tmp/umbrella-skill
cd /path/to/umbrella
bash /tmp/umbrella-skill/install.sh
```

This copies the skill into `.claude/skills/umbrella-backlog/`. Claude Code picks it up automatically.

### Option 2: Manual copy

```bash
mkdir -p .claude/skills/umbrella-backlog/references
cp SKILL.md .claude/skills/umbrella-backlog/
cp references/backlog-surface.md .claude/skills/umbrella-backlog/references/
```

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

## Requirements

- The [Umbrella](https://github.com/ckreative/umbrella) repo cloned and set up (migrations run, `.env` configured)
- Claude Code

## Also Available

Codex (OpenAI) version: [ckreative/umbrella-codex-backlog-skill](https://github.com/ckreative/umbrella-codex-backlog-skill)
