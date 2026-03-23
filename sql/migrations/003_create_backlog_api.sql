CREATE OR REPLACE FUNCTION backlog.team_id_for_slug(p_team_slug text)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
    v_team_id uuid;
BEGIN
    IF p_team_slug IS NULL THEN
        RETURN NULL;
    END IF;

    SELECT id INTO v_team_id
    FROM backlog.teams
    WHERE slug = p_team_slug;

    IF v_team_id IS NULL THEN
        RAISE EXCEPTION 'Unknown team slug: %', p_team_slug;
    END IF;

    RETURN v_team_id;
END;
$$;

CREATE OR REPLACE FUNCTION backlog.person_id_for_handle(p_handle text)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
    v_person_id uuid;
BEGIN
    IF p_handle IS NULL THEN
        RETURN NULL;
    END IF;

    SELECT id INTO v_person_id
    FROM backlog.people
    WHERE handle = p_handle;

    IF v_person_id IS NULL THEN
        RAISE EXCEPTION 'Unknown person handle: %', p_handle;
    END IF;

    RETURN v_person_id;
END;
$$;

CREATE OR REPLACE FUNCTION backlog.epic_id_for_slug(p_slug text)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
    v_epic_id uuid;
BEGIN
    SELECT id INTO v_epic_id
    FROM backlog.epics
    WHERE slug = p_slug;

    IF v_epic_id IS NULL THEN
        RAISE EXCEPTION 'Unknown epic slug: %', p_slug;
    END IF;

    RETURN v_epic_id;
END;
$$;

CREATE OR REPLACE FUNCTION backlog.ticket_id_for_key(p_ticket_key text)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
    v_ticket_id uuid;
BEGIN
    SELECT id INTO v_ticket_id
    FROM backlog.tickets
    WHERE ticket_key = p_ticket_key;

    IF v_ticket_id IS NULL THEN
        RAISE EXCEPTION 'Unknown ticket key: %', p_ticket_key;
    END IF;

    RETURN v_ticket_id;
END;
$$;

CREATE OR REPLACE FUNCTION backlog.set_change_context(
    p_actor_handle text DEFAULT NULL,
    p_note text DEFAULT NULL,
    p_changed_at timestamptz DEFAULT now()
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_actor_id uuid;
BEGIN
    v_actor_id = backlog.person_id_for_handle(p_actor_handle);
    PERFORM set_config('backlog.actor_person_id', COALESCE(v_actor_id::text, ''), true);
    PERFORM set_config('backlog.change_note', COALESCE(p_note, ''), true);
    PERFORM set_config('backlog.changed_at', COALESCE(p_changed_at::text, ''), true);
END;
$$;

CREATE OR REPLACE FUNCTION backlog.clear_change_context()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM set_config('backlog.actor_person_id', '', true);
    PERFORM set_config('backlog.change_note', '', true);
    PERFORM set_config('backlog.changed_at', '', true);
END;
$$;

CREATE OR REPLACE FUNCTION backlog.create_team(
    p_slug text,
    p_name text,
    p_summary text DEFAULT NULL
)
RETURNS backlog.teams
LANGUAGE plpgsql
AS $$
DECLARE
    v_row backlog.teams;
BEGIN
    INSERT INTO backlog.teams (slug, name, summary)
    VALUES (p_slug, p_name, p_summary)
    ON CONFLICT (slug) DO UPDATE
    SET name = EXCLUDED.name,
        summary = EXCLUDED.summary
    RETURNING * INTO v_row;

    RETURN v_row;
END;
$$;

CREATE OR REPLACE FUNCTION backlog.create_person(
    p_handle text,
    p_name text,
    p_email text,
    p_role text,
    p_team_slug text DEFAULT NULL,
    p_timezone text DEFAULT 'America/New_York',
    p_capacity_points integer DEFAULT 8,
    p_active boolean DEFAULT true
)
RETURNS backlog.people
LANGUAGE plpgsql
AS $$
DECLARE
    v_row backlog.people;
    v_team_id uuid;
BEGIN
    v_team_id = backlog.team_id_for_slug(p_team_slug);

    INSERT INTO backlog.people (
        handle,
        name,
        email,
        role,
        team_id,
        timezone,
        capacity_points,
        active
    )
    VALUES (
        p_handle,
        p_name,
        p_email,
        p_role,
        v_team_id,
        p_timezone,
        p_capacity_points,
        p_active
    )
    ON CONFLICT (handle) DO UPDATE
    SET name = EXCLUDED.name,
        email = EXCLUDED.email,
        role = EXCLUDED.role,
        team_id = EXCLUDED.team_id,
        timezone = EXCLUDED.timezone,
        capacity_points = EXCLUDED.capacity_points,
        active = EXCLUDED.active
    RETURNING * INTO v_row;

    RETURN v_row;
END;
$$;

CREATE OR REPLACE FUNCTION backlog.create_epic(
    p_title text,
    p_slug text DEFAULT NULL,
    p_summary text DEFAULT NULL,
    p_status text DEFAULT 'proposed',
    p_priority text DEFAULT 'medium',
    p_owner_handle text DEFAULT NULL,
    p_target_date date DEFAULT NULL,
    p_start_date date DEFAULT NULL,
    p_epic_key text DEFAULT NULL
)
RETURNS backlog.epics
LANGUAGE plpgsql
AS $$
DECLARE
    v_row backlog.epics;
    v_slug text;
    v_owner_id uuid;
    v_epic_key text;
BEGIN
    v_slug = COALESCE(p_slug, backlog.slugify(p_title));
    v_owner_id = backlog.person_id_for_handle(p_owner_handle);
    v_epic_key = COALESCE(p_epic_key, backlog.next_epic_key());

    INSERT INTO backlog.epics (
        epic_key,
        slug,
        title,
        summary,
        status,
        priority,
        owner_id,
        target_date,
        start_date
    )
    VALUES (
        v_epic_key,
        v_slug,
        p_title,
        p_summary,
        p_status,
        p_priority,
        v_owner_id,
        p_target_date,
        p_start_date
    )
    ON CONFLICT (slug) DO UPDATE
    SET title = EXCLUDED.title,
        summary = EXCLUDED.summary,
        status = EXCLUDED.status,
        priority = EXCLUDED.priority,
        owner_id = EXCLUDED.owner_id,
        target_date = EXCLUDED.target_date,
        start_date = EXCLUDED.start_date
    RETURNING * INTO v_row;

    RETURN v_row;
END;
$$;

CREATE OR REPLACE FUNCTION backlog.create_ticket(
    p_epic_slug text,
    p_title text,
    p_slug text DEFAULT NULL,
    p_ticket_type text DEFAULT 'feature',
    p_status text DEFAULT 'intake',
    p_priority text DEFAULT 'medium',
    p_assignee_handle text DEFAULT NULL,
    p_reporter_handle text DEFAULT NULL,
    p_summary text DEFAULT NULL,
    p_acceptance_criteria text DEFAULT NULL,
    p_blocked_reason text DEFAULT NULL,
    p_due_date date DEFAULT NULL,
    p_estimate_points numeric DEFAULT NULL,
    p_repo_path text DEFAULT NULL,
    p_environment text DEFAULT NULL,
    p_ticket_key text DEFAULT NULL
)
RETURNS backlog.tickets
LANGUAGE plpgsql
AS $$
DECLARE
    v_row backlog.tickets;
    v_ticket_key text;
    v_slug text;
BEGIN
    v_ticket_key = COALESCE(p_ticket_key, backlog.next_ticket_key());
    v_slug = COALESCE(p_slug, backlog.slugify(v_ticket_key || ' ' || p_title));

    INSERT INTO backlog.tickets (
        ticket_key,
        slug,
        epic_id,
        title,
        summary,
        acceptance_criteria,
        ticket_type,
        status,
        priority,
        current_assignee_id,
        reporter_id,
        blocked_reason,
        due_date,
        estimate_points,
        repo_path,
        environment
    )
    VALUES (
        v_ticket_key,
        v_slug,
        backlog.epic_id_for_slug(p_epic_slug),
        p_title,
        p_summary,
        p_acceptance_criteria,
        p_ticket_type,
        p_status,
        p_priority,
        backlog.person_id_for_handle(p_assignee_handle),
        backlog.person_id_for_handle(p_reporter_handle),
        CASE WHEN p_status = 'blocked' THEN p_blocked_reason ELSE NULL END,
        p_due_date,
        p_estimate_points,
        p_repo_path,
        p_environment
    )
    RETURNING * INTO v_row;

    RETURN v_row;
END;
$$;

CREATE OR REPLACE FUNCTION backlog.assign_ticket(
    p_ticket_key text,
    p_assignee_handle text,
    p_changed_by_handle text DEFAULT NULL,
    p_note text DEFAULT NULL,
    p_changed_at timestamptz DEFAULT now()
)
RETURNS backlog.tickets
LANGUAGE plpgsql
AS $$
DECLARE
    v_row backlog.tickets;
BEGIN
    PERFORM backlog.set_change_context(p_changed_by_handle, p_note, p_changed_at);

    UPDATE backlog.tickets
    SET current_assignee_id = backlog.person_id_for_handle(p_assignee_handle)
    WHERE ticket_key = p_ticket_key
    RETURNING * INTO v_row;

    PERFORM backlog.clear_change_context();

    IF v_row.id IS NULL THEN
        RAISE EXCEPTION 'Unknown ticket key: %', p_ticket_key;
    END IF;

    RETURN v_row;
END;
$$;

CREATE OR REPLACE FUNCTION backlog.transition_ticket(
    p_ticket_key text,
    p_to_status text,
    p_changed_by_handle text DEFAULT NULL,
    p_note text DEFAULT NULL,
    p_blocked_reason text DEFAULT NULL,
    p_changed_at timestamptz DEFAULT now()
)
RETURNS backlog.tickets
LANGUAGE plpgsql
AS $$
DECLARE
    v_row backlog.tickets;
BEGIN
    PERFORM backlog.set_change_context(p_changed_by_handle, p_note, p_changed_at);

    UPDATE backlog.tickets
    SET status = p_to_status,
        blocked_reason = CASE
            WHEN p_to_status = 'blocked' THEN COALESCE(p_blocked_reason, p_note, blocked_reason)
            ELSE NULL
        END
    WHERE ticket_key = p_ticket_key
    RETURNING * INTO v_row;

    PERFORM backlog.clear_change_context();

    IF v_row.id IS NULL THEN
        RAISE EXCEPTION 'Unknown ticket key: %', p_ticket_key;
    END IF;

    RETURN v_row;
END;
$$;

CREATE OR REPLACE FUNCTION backlog.log_work(
    p_ticket_key text,
    p_person_handle text,
    p_summary text,
    p_details text DEFAULT NULL,
    p_duration_minutes integer DEFAULT NULL,
    p_logged_at timestamptz DEFAULT now()
)
RETURNS backlog.work_logs
LANGUAGE plpgsql
AS $$
DECLARE
    v_row backlog.work_logs;
BEGIN
    INSERT INTO backlog.work_logs (
        ticket_id,
        person_id,
        logged_at,
        summary,
        details,
        duration_minutes
    )
    VALUES (
        backlog.ticket_id_for_key(p_ticket_key),
        backlog.person_id_for_handle(p_person_handle),
        p_logged_at,
        p_summary,
        p_details,
        p_duration_minutes
    )
    RETURNING * INTO v_row;

    RETURN v_row;
END;
$$;

