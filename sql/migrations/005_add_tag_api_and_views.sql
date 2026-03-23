CREATE OR REPLACE FUNCTION backlog.tag_id_for_slug(p_slug text)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
    v_tag_id uuid;
BEGIN
    IF p_slug IS NULL THEN
        RETURN NULL;
    END IF;

    SELECT id INTO v_tag_id
    FROM backlog.tags
    WHERE slug = p_slug;

    IF v_tag_id IS NULL THEN
        RAISE EXCEPTION 'Unknown tag slug: %', p_slug;
    END IF;

    RETURN v_tag_id;
END;
$$;

CREATE OR REPLACE FUNCTION backlog.create_tag(
    p_slug text,
    p_label text,
    p_color text DEFAULT NULL
)
RETURNS backlog.tags
LANGUAGE plpgsql
AS $$
DECLARE
    v_row backlog.tags;
BEGIN
    INSERT INTO backlog.tags (slug, label, color)
    VALUES (p_slug, p_label, p_color)
    ON CONFLICT (slug) DO UPDATE
    SET label = EXCLUDED.label,
        color = EXCLUDED.color
    RETURNING * INTO v_row;

    RETURN v_row;
END;
$$;

CREATE OR REPLACE FUNCTION backlog.add_ticket_tag(
    p_ticket_key text,
    p_tag_slug text
)
RETURNS backlog.ticket_tags
LANGUAGE plpgsql
AS $$
DECLARE
    v_row backlog.ticket_tags;
BEGIN
    INSERT INTO backlog.ticket_tags (ticket_id, tag_id)
    VALUES (
        backlog.ticket_id_for_key(p_ticket_key),
        backlog.tag_id_for_slug(p_tag_slug)
    )
    ON CONFLICT (ticket_id, tag_id) DO NOTHING
    RETURNING * INTO v_row;

    IF v_row.ticket_id IS NULL THEN
        SELECT *
        INTO v_row
        FROM backlog.ticket_tags
        WHERE ticket_id = backlog.ticket_id_for_key(p_ticket_key)
          AND tag_id = backlog.tag_id_for_slug(p_tag_slug);
    END IF;

    RETURN v_row;
END;
$$;

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
),
ticket_tag_rollup AS (
    SELECT
        tt.ticket_id,
        array_agg(t.slug ORDER BY t.slug) AS tag_slugs,
        array_agg(t.label ORDER BY t.slug) AS tag_labels,
        string_agg(t.label, ', ' ORDER BY t.slug) AS tag_list
    FROM backlog.ticket_tags tt
    JOIN backlog.tags t ON t.id = tt.tag_id
    GROUP BY tt.ticket_id
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
    t.updated_at,
    COALESCE(ttr.tag_slugs, ARRAY[]::text[]) AS tag_slugs,
    COALESCE(ttr.tag_labels, ARRAY[]::text[]) AS tag_labels,
    ttr.tag_list
FROM backlog.tickets t
JOIN backlog.epics e ON e.id = t.epic_id
LEFT JOIN backlog.people owner ON owner.id = e.owner_id
LEFT JOIN backlog.people assignee ON assignee.id = t.current_assignee_id
LEFT JOIN backlog.teams team ON team.id = assignee.team_id
LEFT JOIN backlog.people reporter ON reporter.id = t.reporter_id
LEFT JOIN blocker_counts bc ON bc.ticket_id = t.id
LEFT JOIN status_changes sc ON sc.ticket_id = t.id
LEFT JOIN assignment_changes ac ON ac.ticket_id = t.id
LEFT JOIN work_log_changes wc ON wc.ticket_id = t.id
LEFT JOIN ticket_tag_rollup ttr ON ttr.ticket_id = t.id;

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
    cbv.last_changed_at,
    cbv.tag_slugs,
    cbv.tag_labels,
    cbv.tag_list
FROM backlog.people p
JOIN backlog.current_backlog_v cbv
    ON cbv.current_assignee_handle = p.handle
LEFT JOIN backlog.teams team
    ON team.id = p.team_id
WHERE cbv.status IN ('in_progress', 'blocked', 'review')
  AND p.active = true
ORDER BY p.handle, cbv.priority DESC, cbv.due_date NULLS LAST, cbv.ticket_key;

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
    END AS product_bucket,
    cbv.tag_slugs,
    cbv.tag_labels,
    cbv.tag_list
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
