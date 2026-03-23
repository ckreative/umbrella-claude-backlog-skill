CREATE SCHEMA IF NOT EXISTS backlog;

CREATE SEQUENCE IF NOT EXISTS backlog.epic_key_seq START WITH 1000;
CREATE SEQUENCE IF NOT EXISTS backlog.ticket_key_seq START WITH 1000;

CREATE OR REPLACE FUNCTION backlog.slugify(input_text text)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT trim(both '-' FROM regexp_replace(lower(coalesce(input_text, '')), '[^a-z0-9]+', '-', 'g'));
$$;

CREATE OR REPLACE FUNCTION backlog.next_epic_key()
RETURNS text
LANGUAGE sql
AS $$
    SELECT 'EP-' || nextval('backlog.epic_key_seq');
$$;

CREATE OR REPLACE FUNCTION backlog.next_ticket_key()
RETURNS text
LANGUAGE sql
AS $$
    SELECT 'UMB-' || nextval('backlog.ticket_key_seq');
$$;

CREATE TABLE IF NOT EXISTS backlog.teams (
    id uuid PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
    slug text NOT NULL UNIQUE,
    name text NOT NULL,
    summary text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS backlog.people (
    id uuid PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
    handle text NOT NULL UNIQUE,
    name text NOT NULL,
    email text NOT NULL UNIQUE,
    role text NOT NULL CHECK (role IN ('engineer', 'product', 'manager', 'designer', 'qa', 'other')),
    team_id uuid REFERENCES backlog.teams(id) ON DELETE SET NULL,
    timezone text NOT NULL DEFAULT 'America/New_York',
    capacity_points integer NOT NULL DEFAULT 8 CHECK (capacity_points >= 0),
    active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS backlog.epics (
    id uuid PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
    epic_key text NOT NULL UNIQUE,
    slug text NOT NULL UNIQUE,
    title text NOT NULL,
    summary text,
    status text NOT NULL CHECK (status IN ('proposed', 'active', 'paused', 'done', 'canceled')),
    priority text NOT NULL CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    owner_id uuid REFERENCES backlog.people(id) ON DELETE SET NULL,
    start_date date,
    target_date date,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS backlog.tags (
    id uuid PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
    slug text NOT NULL UNIQUE,
    label text NOT NULL UNIQUE,
    color text,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS backlog.tickets (
    id uuid PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
    ticket_key text NOT NULL UNIQUE,
    slug text NOT NULL UNIQUE,
    epic_id uuid NOT NULL REFERENCES backlog.epics(id) ON DELETE CASCADE,
    title text NOT NULL,
    summary text,
    acceptance_criteria text,
    ticket_type text NOT NULL CHECK (ticket_type IN ('feature', 'bug', 'chore', 'spike', 'support')),
    status text NOT NULL CHECK (status IN ('intake', 'ready', 'in_progress', 'blocked', 'review', 'done', 'canceled')),
    priority text NOT NULL CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    current_assignee_id uuid REFERENCES backlog.people(id) ON DELETE SET NULL,
    reporter_id uuid REFERENCES backlog.people(id) ON DELETE SET NULL,
    blocked_reason text,
    due_date date,
    estimate_points numeric(6,2),
    repo_path text,
    environment text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS backlog.ticket_tags (
    ticket_id uuid NOT NULL REFERENCES backlog.tickets(id) ON DELETE CASCADE,
    tag_id uuid NOT NULL REFERENCES backlog.tags(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (ticket_id, tag_id)
);

CREATE TABLE IF NOT EXISTS backlog.ticket_links (
    id uuid PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
    source_ticket_id uuid NOT NULL REFERENCES backlog.tickets(id) ON DELETE CASCADE,
    target_ticket_id uuid NOT NULL REFERENCES backlog.tickets(id) ON DELETE CASCADE,
    link_type text NOT NULL CHECK (link_type IN ('blocks', 'relates_to', 'duplicate_of')),
    created_at timestamptz NOT NULL DEFAULT now(),
    CHECK (source_ticket_id <> target_ticket_id),
    UNIQUE (source_ticket_id, target_ticket_id, link_type)
);

CREATE TABLE IF NOT EXISTS backlog.ticket_status_history (
    id uuid PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
    ticket_id uuid NOT NULL REFERENCES backlog.tickets(id) ON DELETE CASCADE,
    changed_at timestamptz NOT NULL DEFAULT now(),
    changed_by_person_id uuid REFERENCES backlog.people(id) ON DELETE SET NULL,
    from_status text CHECK (from_status IN ('intake', 'ready', 'in_progress', 'blocked', 'review', 'done', 'canceled')),
    to_status text NOT NULL CHECK (to_status IN ('intake', 'ready', 'in_progress', 'blocked', 'review', 'done', 'canceled')),
    note text
);

CREATE TABLE IF NOT EXISTS backlog.ticket_assignment_history (
    id uuid PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
    ticket_id uuid NOT NULL REFERENCES backlog.tickets(id) ON DELETE CASCADE,
    changed_at timestamptz NOT NULL DEFAULT now(),
    changed_by_person_id uuid REFERENCES backlog.people(id) ON DELETE SET NULL,
    from_assignee_id uuid REFERENCES backlog.people(id) ON DELETE SET NULL,
    to_assignee_id uuid REFERENCES backlog.people(id) ON DELETE SET NULL,
    note text
);

CREATE TABLE IF NOT EXISTS backlog.work_logs (
    id uuid PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
    ticket_id uuid NOT NULL REFERENCES backlog.tickets(id) ON DELETE CASCADE,
    person_id uuid NOT NULL REFERENCES backlog.people(id) ON DELETE CASCADE,
    logged_at timestamptz NOT NULL DEFAULT now(),
    summary text NOT NULL,
    details text,
    duration_minutes integer CHECK (duration_minutes IS NULL OR duration_minutes > 0),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_backlog_people_team_id ON backlog.people(team_id);
CREATE INDEX IF NOT EXISTS idx_backlog_people_role ON backlog.people(role);
CREATE INDEX IF NOT EXISTS idx_backlog_epics_status ON backlog.epics(status);
CREATE INDEX IF NOT EXISTS idx_backlog_epics_owner_id ON backlog.epics(owner_id);
CREATE INDEX IF NOT EXISTS idx_backlog_tickets_epic_id ON backlog.tickets(epic_id);
CREATE INDEX IF NOT EXISTS idx_backlog_tickets_status ON backlog.tickets(status);
CREATE INDEX IF NOT EXISTS idx_backlog_tickets_assignee_id ON backlog.tickets(current_assignee_id);
CREATE INDEX IF NOT EXISTS idx_backlog_tickets_due_date ON backlog.tickets(due_date);
CREATE INDEX IF NOT EXISTS idx_backlog_ticket_links_source ON backlog.ticket_links(source_ticket_id);
CREATE INDEX IF NOT EXISTS idx_backlog_ticket_links_target ON backlog.ticket_links(target_ticket_id);
CREATE INDEX IF NOT EXISTS idx_backlog_status_history_ticket_id ON backlog.ticket_status_history(ticket_id, changed_at DESC);
CREATE INDEX IF NOT EXISTS idx_backlog_assignment_history_ticket_id ON backlog.ticket_assignment_history(ticket_id, changed_at DESC);
CREATE INDEX IF NOT EXISTS idx_backlog_work_logs_ticket_id ON backlog.work_logs(ticket_id, logged_at DESC);
CREATE INDEX IF NOT EXISTS idx_backlog_work_logs_person_id ON backlog.work_logs(person_id, logged_at DESC);

CREATE OR REPLACE FUNCTION backlog.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION backlog.capture_ticket_history()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    actor_id uuid;
    note_text text;
    changed_at_value timestamptz;
BEGIN
    actor_id = NULLIF(current_setting('backlog.actor_person_id', true), '')::uuid;
    note_text = NULLIF(current_setting('backlog.change_note', true), '');
    changed_at_value = COALESCE(NULLIF(current_setting('backlog.changed_at', true), '')::timestamptz, now());

    IF TG_OP = 'INSERT' THEN
        INSERT INTO backlog.ticket_status_history (
            ticket_id,
            changed_at,
            changed_by_person_id,
            from_status,
            to_status,
            note
        )
        VALUES (
            NEW.id,
            COALESCE(NEW.created_at, changed_at_value),
            actor_id,
            NULL,
            NEW.status,
            note_text
        );

        IF NEW.current_assignee_id IS NOT NULL THEN
            INSERT INTO backlog.ticket_assignment_history (
                ticket_id,
                changed_at,
                changed_by_person_id,
                from_assignee_id,
                to_assignee_id,
                note
            )
            VALUES (
                NEW.id,
                COALESCE(NEW.created_at, changed_at_value),
                actor_id,
                NULL,
                NEW.current_assignee_id,
                note_text
            );
        END IF;

        RETURN NEW;
    END IF;

    IF NEW.status IS DISTINCT FROM OLD.status THEN
        INSERT INTO backlog.ticket_status_history (
            ticket_id,
            changed_at,
            changed_by_person_id,
            from_status,
            to_status,
            note
        )
        VALUES (
            NEW.id,
            changed_at_value,
            actor_id,
            OLD.status,
            NEW.status,
            note_text
        );
    END IF;

    IF NEW.current_assignee_id IS DISTINCT FROM OLD.current_assignee_id THEN
        INSERT INTO backlog.ticket_assignment_history (
            ticket_id,
            changed_at,
            changed_by_person_id,
            from_assignee_id,
            to_assignee_id,
            note
        )
        VALUES (
            NEW.id,
            changed_at_value,
            actor_id,
            OLD.current_assignee_id,
            NEW.current_assignee_id,
            note_text
        );
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_backlog_teams_updated_at ON backlog.teams;
CREATE TRIGGER trg_backlog_teams_updated_at
BEFORE UPDATE ON backlog.teams
FOR EACH ROW
EXECUTE FUNCTION backlog.set_updated_at();

DROP TRIGGER IF EXISTS trg_backlog_people_updated_at ON backlog.people;
CREATE TRIGGER trg_backlog_people_updated_at
BEFORE UPDATE ON backlog.people
FOR EACH ROW
EXECUTE FUNCTION backlog.set_updated_at();

DROP TRIGGER IF EXISTS trg_backlog_epics_updated_at ON backlog.epics;
CREATE TRIGGER trg_backlog_epics_updated_at
BEFORE UPDATE ON backlog.epics
FOR EACH ROW
EXECUTE FUNCTION backlog.set_updated_at();

DROP TRIGGER IF EXISTS trg_backlog_tickets_updated_at ON backlog.tickets;
CREATE TRIGGER trg_backlog_tickets_updated_at
BEFORE UPDATE ON backlog.tickets
FOR EACH ROW
EXECUTE FUNCTION backlog.set_updated_at();

DROP TRIGGER IF EXISTS trg_backlog_tickets_history ON backlog.tickets;
CREATE TRIGGER trg_backlog_tickets_history
AFTER INSERT OR UPDATE OF status, current_assignee_id ON backlog.tickets
FOR EACH ROW
EXECUTE FUNCTION backlog.capture_ticket_history();

