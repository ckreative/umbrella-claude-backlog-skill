CREATE OR REPLACE VIEW backlog.current_backlog_v AS
WITH blocker_counts AS (
    SELECT
        tl.target_ticket_id AS ticket_id,
        count(*) FILTER (WHERE source.status <> 'done') AS open_blocker_count,
        string_agg(source.ticket_key, ', ' ORDER BY source.ticket_key) FILTER (WHERE source.status <> 'done') AS open_blocker_keys
    FROM backlog.ticket_links tl
    JOIN backlog.tickets source ON source.id = tl.source_ticket_id
    WHERE tl.link_type = 'blocks'
    GROUP BY tl.target_ticket_id
),
status_changes AS (
    SELECT ticket_id, max(changed_at) AS last_status_changed_at
    FROM backlog.ticket_status_history
    GROUP BY ticket_id
),
assignment_changes AS (
    SELECT ticket_id, max(changed_at) AS last_assignment_changed_at
    FROM backlog.ticket_assignment_history
    GROUP BY ticket_id
),
work_log_changes AS (
    SELECT ticket_id, max(logged_at) AS last_work_logged_at
    FROM backlog.work_logs
    GROUP BY ticket_id
)
SELECT
    t.id AS ticket_id,
    t.ticket_key,
    t.slug AS ticket_slug,
    t.title AS ticket_title,
    t.summary AS ticket_summary,
    t.acceptance_criteria,
    t.ticket_type,
    t.status,
    t.priority,
    t.blocked_reason,
    t.due_date,
    t.estimate_points,
    t.repo_path,
    t.environment,
    e.id AS epic_id,
    e.epic_key,
    e.slug AS epic_slug,
    e.title AS epic_title,
    e.status AS epic_status,
    e.priority AS epic_priority,
    owner.handle AS epic_owner_handle,
    owner.name AS epic_owner_name,
    assignee.handle AS current_assignee_handle,
    assignee.name AS current_assignee_name,
    assignee.role AS current_assignee_role,
    team.slug AS current_assignee_team_slug,
    reporter.handle AS reporter_handle,
    reporter.name AS reporter_name,
    COALESCE(bc.open_blocker_count, 0) AS open_blocker_count,
    bc.open_blocker_keys,
    sc.last_status_changed_at,
    ac.last_assignment_changed_at,
    wc.last_work_logged_at,
    GREATEST(
        COALESCE(sc.last_status_changed_at, t.updated_at),
        COALESCE(ac.last_assignment_changed_at, t.updated_at),
        COALESCE(wc.last_work_logged_at, t.updated_at),
        t.updated_at
    ) AS last_changed_at,
    t.created_at,
    t.updated_at
FROM backlog.tickets t
JOIN backlog.epics e ON e.id = t.epic_id
LEFT JOIN backlog.people owner ON owner.id = e.owner_id
LEFT JOIN backlog.people assignee ON assignee.id = t.current_assignee_id
LEFT JOIN backlog.teams team ON team.id = assignee.team_id
LEFT JOIN backlog.people reporter ON reporter.id = t.reporter_id
LEFT JOIN blocker_counts bc ON bc.ticket_id = t.id
LEFT JOIN status_changes sc ON sc.ticket_id = t.id
LEFT JOIN assignment_changes ac ON ac.ticket_id = t.id
LEFT JOIN work_log_changes wc ON wc.ticket_id = t.id;

CREATE OR REPLACE VIEW backlog.member_current_work_v AS
SELECT
    p.id AS person_id,
    p.handle,
    p.name,
    p.role,
    team.slug AS team_slug,
    team.name AS team_name,
    p.capacity_points,
    cbv.ticket_id,
    cbv.ticket_key,
    cbv.ticket_slug,
    cbv.ticket_title,
    cbv.ticket_type,
    cbv.status,
    cbv.priority,
    cbv.epic_key,
    cbv.epic_slug,
    cbv.epic_title,
    cbv.blocked_reason,
    cbv.open_blocker_count,
    cbv.open_blocker_keys,
    cbv.due_date,
    cbv.estimate_points,
    cbv.last_changed_at
FROM backlog.people p
JOIN backlog.current_backlog_v cbv
    ON cbv.current_assignee_handle = p.handle
LEFT JOIN backlog.teams team
    ON team.id = p.team_id
WHERE cbv.status IN ('in_progress', 'blocked', 'review')
  AND p.active = true
ORDER BY p.handle, cbv.priority DESC, cbv.due_date NULLS LAST, cbv.ticket_key;

CREATE OR REPLACE VIEW backlog.member_weekly_activity_v AS
WITH bounds AS (
    SELECT
        (date_trunc('week', now() AT TIME ZONE 'America/New_York') - interval '7 days')::date AS week_start,
        (date_trunc('week', now() AT TIME ZONE 'America/New_York') - interval '1 day')::date AS week_end,
        (date_trunc('week', now() AT TIME ZONE 'America/New_York') - interval '7 days') AT TIME ZONE 'America/New_York' AS week_start_at,
        date_trunc('week', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York' AS week_end_at
),
activity AS (
    SELECT
        h.ticket_id,
        h.changed_by_person_id AS person_id,
        h.changed_at AS activity_at,
        'status'::text AS activity_type,
        1 AS status_events,
        0 AS assignment_events,
        0 AS work_log_entries,
        0 AS duration_minutes
    FROM backlog.ticket_status_history h
    CROSS JOIN bounds b
    WHERE h.changed_by_person_id IS NOT NULL
      AND h.changed_at >= b.week_start_at
      AND h.changed_at < b.week_end_at

    UNION ALL

    SELECT
        h.ticket_id,
        h.changed_by_person_id AS person_id,
        h.changed_at AS activity_at,
        'assignment'::text AS activity_type,
        0 AS status_events,
        1 AS assignment_events,
        0 AS work_log_entries,
        0 AS duration_minutes
    FROM backlog.ticket_assignment_history h
    CROSS JOIN bounds b
    WHERE h.changed_by_person_id IS NOT NULL
      AND h.changed_at >= b.week_start_at
      AND h.changed_at < b.week_end_at

    UNION ALL

    SELECT
        w.ticket_id,
        w.person_id,
        w.logged_at AS activity_at,
        'work_log'::text AS activity_type,
        0 AS status_events,
        0 AS assignment_events,
        1 AS work_log_entries,
        COALESCE(w.duration_minutes, 0) AS duration_minutes
    FROM backlog.work_logs w
    CROSS JOIN bounds b
    WHERE w.logged_at >= b.week_start_at
      AND w.logged_at < b.week_end_at
)
SELECT
    b.week_start,
    b.week_end,
    p.id AS person_id,
    p.handle,
    p.name,
    team.slug AS team_slug,
    t.id AS ticket_id,
    t.ticket_key,
    t.title AS ticket_title,
    e.epic_key,
    e.slug AS epic_slug,
    e.title AS epic_title,
    t.status AS current_status,
    count(*) AS activity_events,
    sum(a.status_events) AS status_events,
    sum(a.assignment_events) AS assignment_events,
    sum(a.work_log_entries) AS work_log_entries,
    sum(a.duration_minutes) AS total_duration_minutes,
    min(a.activity_at) AS first_activity_at,
    max(a.activity_at) AS last_activity_at,
    string_agg(DISTINCT a.activity_type, ', ' ORDER BY a.activity_type) AS activity_types
FROM activity a
JOIN bounds b ON true
JOIN backlog.people p ON p.id = a.person_id
LEFT JOIN backlog.teams team ON team.id = p.team_id
JOIN backlog.tickets t ON t.id = a.ticket_id
JOIN backlog.epics e ON e.id = t.epic_id
GROUP BY
    b.week_start,
    b.week_end,
    p.id,
    p.handle,
    p.name,
    team.slug,
    t.id,
    t.ticket_key,
    t.title,
    e.epic_key,
    e.slug,
    e.title,
    t.status
ORDER BY p.handle, last_activity_at DESC, t.ticket_key;

CREATE OR REPLACE VIEW backlog.product_sync_v AS
SELECT
    cbv.ticket_id,
    cbv.ticket_key,
    cbv.ticket_slug,
    cbv.ticket_title,
    cbv.ticket_type,
    cbv.status,
    cbv.priority,
    cbv.epic_key,
    cbv.epic_slug,
    cbv.epic_title,
    cbv.epic_status,
    cbv.epic_priority,
    cbv.epic_owner_name,
    cbv.current_assignee_name,
    cbv.current_assignee_handle,
    cbv.due_date,
    cbv.blocked_reason,
    cbv.open_blocker_count,
    cbv.open_blocker_keys,
    cbv.last_changed_at,
    CASE
        WHEN cbv.status = 'blocked' THEN 'blocked'
        WHEN cbv.status = 'ready' THEN 'ready'
        WHEN cbv.due_date IS NOT NULL AND cbv.due_date < (now() AT TIME ZONE 'America/New_York')::date THEN 'overdue'
        WHEN cbv.status IN ('in_progress', 'review') THEN 'active'
        ELSE 'backlog'
    END AS product_bucket
FROM backlog.current_backlog_v cbv
ORDER BY
    CASE cbv.priority
        WHEN 'critical' THEN 1
        WHEN 'high' THEN 2
        WHEN 'medium' THEN 3
        ELSE 4
    END,
    cbv.due_date NULLS LAST,
    cbv.ticket_key;

CREATE OR REPLACE VIEW backlog.blocked_tickets_v AS
SELECT
    cbv.ticket_id,
    cbv.ticket_key,
    cbv.ticket_title,
    cbv.epic_key,
    cbv.epic_title,
    cbv.current_assignee_handle,
    cbv.current_assignee_name,
    cbv.blocked_reason,
    cbv.open_blocker_count,
    cbv.open_blocker_keys,
    cbv.last_changed_at
FROM backlog.current_backlog_v cbv
WHERE cbv.status = 'blocked'
   OR cbv.open_blocker_count > 0
ORDER BY cbv.last_changed_at DESC, cbv.ticket_key;

CREATE OR REPLACE VIEW backlog.workload_summary_v AS
WITH active_work AS (
    SELECT *
    FROM backlog.member_current_work_v
),
recent_activity AS (
    SELECT
        person_id,
        max(last_activity_at) AS last_activity_at
    FROM backlog.member_weekly_activity_v
    GROUP BY person_id
)
SELECT
    p.id AS person_id,
    p.handle,
    p.name,
    p.role,
    team.slug AS team_slug,
    team.name AS team_name,
    p.capacity_points,
    count(aw.ticket_id) AS current_ticket_count,
    count(*) FILTER (WHERE aw.status = 'in_progress') AS in_progress_count,
    count(*) FILTER (WHERE aw.status = 'blocked') AS blocked_count,
    count(*) FILTER (WHERE aw.status = 'review') AS review_count,
    COALESCE(sum(aw.estimate_points), 0) AS current_estimate_points,
    count(*) FILTER (
        WHERE aw.due_date IS NOT NULL
          AND aw.due_date < (now() AT TIME ZONE 'America/New_York')::date
    ) AS overdue_ticket_count,
    ra.last_activity_at
FROM backlog.people p
LEFT JOIN backlog.teams team ON team.id = p.team_id
LEFT JOIN active_work aw ON aw.person_id = p.id
LEFT JOIN recent_activity ra ON ra.person_id = p.id
WHERE p.active = true
GROUP BY
    p.id,
    p.handle,
    p.name,
    p.role,
    team.slug,
    team.name,
    p.capacity_points,
    ra.last_activity_at
ORDER BY current_ticket_count DESC, p.handle;

