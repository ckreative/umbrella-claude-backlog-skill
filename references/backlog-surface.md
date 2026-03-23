# Backlog Surface

Use this reference when operating the Umbrella backlog through the `umbrella-backlog` skill.

## Repo

- Root: Umbrella repo root (run all scripts from there)
- Migrations: `bash scripts/db/migrate.sh`
- Import script: `bash scripts/db/import_wave2_spec.sh`
- Validation: `bash scripts/db/test.sh`
- Direct SQL: `bash scripts/db/psql.sh`

## Stable Write Surface

```sql
SELECT backlog.create_epic(...);
SELECT backlog.create_ticket(...);
SELECT backlog.create_tag(...);
SELECT backlog.add_ticket_tag(...);
SELECT backlog.assign_ticket(...);
SELECT backlog.transition_ticket(...);
SELECT backlog.log_work(...);
```

## Stable Read Surface

```sql
SELECT * FROM backlog.current_backlog_v;
SELECT * FROM backlog.product_sync_v;
SELECT * FROM backlog.member_current_work_v;
SELECT * FROM backlog.member_weekly_activity_v;
SELECT * FROM backlog.blocked_tickets_v;
SELECT * FROM backlog.workload_summary_v;
```

## Tags

Platform:
- `mobile`
- `desktop`
- `cross-platform`
- `backend`
- `ai`

Domain:
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

## Common Queries

### Tickets in a domain

```sql
SELECT ticket_key, ticket_title, status, priority
FROM backlog.current_backlog_v
WHERE 'domain-navigation' = ANY(tag_slugs)
ORDER BY ticket_key;
```

### Tickets on a platform

```sql
SELECT ticket_key, ticket_title, status, priority
FROM backlog.current_backlog_v
WHERE 'mobile' = ANY(tag_slugs)
ORDER BY ticket_key;
```

### Active work by developer

```sql
SELECT ticket_key, ticket_title, status, priority
FROM backlog.member_current_work_v
WHERE handle = 'alex'
ORDER BY ticket_key;
```

### Issues in an epic

```sql
SELECT ticket_key, ticket_title, status, priority
FROM backlog.current_backlog_v
WHERE epic_key = 'W2-E10'
ORDER BY ticket_key;
```
