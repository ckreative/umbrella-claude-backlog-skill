---
name: umbrella-backlog
description: Use when managing the Umbrella engineering backlog — creating epics/tickets, importing roadmap specs, tagging by platform/domain, reporting by developer/epic, and preparing product-engineering sync views. Triggers on "backlog", "epic", "ticket", "sprint", "sync", "roadmap", "workload", "assign", "tag ticket".
---

# Umbrella Backlog

Use this skill when operating the shared engineering backlog for the Umbrella project.

## Quick Start

Run SQL queries via:

```bash
bash scripts/db/psql.sh
```

Read [references/backlog-surface.md](references/backlog-surface.md) for the full stable SQL interface, tag taxonomy, and common query patterns.

---

## Write Surface

Use these SQL functions via `bash scripts/db/psql.sh` to modify the backlog:

```sql
SELECT backlog.create_epic(...);
SELECT backlog.create_ticket(...);
SELECT backlog.create_tag(...);
SELECT backlog.add_ticket_tag(...);
SELECT backlog.assign_ticket(...);
SELECT backlog.transition_ticket(...);
SELECT backlog.log_work(...);
```

---

## Read Surface

Use these views for reporting and planning:

```sql
SELECT * FROM backlog.current_backlog_v;
SELECT * FROM backlog.product_sync_v;
SELECT * FROM backlog.member_current_work_v;
SELECT * FROM backlog.member_weekly_activity_v;
SELECT * FROM backlog.blocked_tickets_v;
SELECT * FROM backlog.workload_summary_v;
```

---

## Tag Taxonomy

### Platform Tags
- `mobile`
- `desktop`
- `cross-platform`
- `backend`
- `ai`

### Domain Tags
- `domain-navigation`
- `domain-workspaces`
- `domain-org-identity`
- `domain-invites`
- `domain-project-creation`
- `domain-call-sheet-read`
- `domain-call-sheet-create`
- `domain-document-automation`
- `domain-ai-requirements`
- `domain-onboarding`

---

## Team Workflows

### Intake Roadmap Work

1. Create or find the target epic.
2. Create tickets as feature-sized work items unless the source spec already defines the right granularity.
3. Prefer `ready` for implementation-ready backlog work and `intake` for loosely captured ideas.
4. Tag tickets with both platform and domain slices when possible.

### Run Product-Engineering Sync

Start from `backlog.product_sync_v` for the overall backlog state, then use:
- `backlog.blocked_tickets_v` for risks
- `backlog.member_current_work_v` for active assignments
- `backlog.member_weekly_activity_v` for "what changed last week"

### Slice the Backlog

Use tags to answer planning questions quickly:

```sql
-- All mobile work
SELECT ticket_key, ticket_title, status, priority
FROM backlog.current_backlog_v
WHERE 'mobile' = ANY(tag_slugs)
ORDER BY ticket_key;

-- All work in a domain
SELECT ticket_key, ticket_title, status, priority
FROM backlog.current_backlog_v
WHERE 'domain-navigation' = ANY(tag_slugs)
ORDER BY ticket_key;

-- Active work by developer
SELECT ticket_key, ticket_title, status, priority
FROM backlog.member_current_work_v
WHERE handle = 'alex'
ORDER BY ticket_key;

-- Issues in an epic
SELECT ticket_key, ticket_title, status, priority
FROM backlog.current_backlog_v
WHERE epic_key = 'W2-E10'
ORDER BY ticket_key;
```

---

## Guidance

- Preserve external ticket keys when importing a structured spec if they are already meaningful.
- Use the stable SQL functions (not raw INSERT/UPDATE) to modify data.
- Keep the backlog easy to query: one clear epic, feature-sized tickets, explicit tags, and current status.
