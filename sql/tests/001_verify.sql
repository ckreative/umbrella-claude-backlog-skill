\set ON_ERROR_STOP on

BEGIN;

DO $$
DECLARE
    team_count integer;
    person_count integer;
    epic_count integer;
    ticket_count integer;
    history_count integer;
    work_log_count integer;
    alex_current_count integer;
    alex_weekly_count integer;
    blocked_count integer;
    ready_count integer;
    workload_count integer;
    transition_count integer;
    assignment_count integer;
    worklog_inserted integer;
BEGIN
    SELECT count(*) INTO team_count
    FROM backlog.teams
    WHERE slug IN ('platform', 'product');

    IF team_count <> 2 THEN
        RAISE EXCEPTION 'Expected 2 seeded teams, got %', team_count;
    END IF;

    SELECT count(*) INTO person_count
    FROM backlog.people
    WHERE handle IN ('alex', 'sam', 'priya', 'jordan', 'taylor');

    IF person_count <> 5 THEN
        RAISE EXCEPTION 'Expected 5 seeded people, got %', person_count;
    END IF;

    SELECT count(*) INTO epic_count
    FROM backlog.epics
    WHERE slug IN ('platform-reliability', 'onboarding-refresh', 'march-bug-bash');

    IF epic_count <> 3 THEN
        RAISE EXCEPTION 'Expected 3 seeded epics, got %', epic_count;
    END IF;

    SELECT count(*) INTO ticket_count
    FROM backlog.tickets
    WHERE ticket_key BETWEEN 'UMB-101' AND 'UMB-111';

    IF ticket_count <> 11 THEN
        RAISE EXCEPTION 'Expected 11 seeded tickets, got %', ticket_count;
    END IF;

    SELECT count(*) INTO history_count
    FROM backlog.ticket_status_history
    WHERE ticket_id IN (
        SELECT id FROM backlog.tickets WHERE ticket_key IN ('UMB-101', 'UMB-102', 'UMB-103', 'UMB-105', 'UMB-107', 'UMB-109', 'UMB-111')
    );

    IF history_count < 17 THEN
        RAISE EXCEPTION 'Expected at least 17 status history rows, got %', history_count;
    END IF;

    SELECT count(*) INTO work_log_count
    FROM backlog.work_logs
    WHERE ticket_id IN (
        SELECT id FROM backlog.tickets WHERE ticket_key IN ('UMB-101', 'UMB-102', 'UMB-103', 'UMB-105', 'UMB-107', 'UMB-109')
    );

    IF work_log_count < 6 THEN
        RAISE EXCEPTION 'Expected at least 6 work logs, got %', work_log_count;
    END IF;

    SELECT count(*) INTO alex_current_count
    FROM backlog.member_current_work_v
    WHERE handle = 'alex';

    IF alex_current_count <> 2 THEN
        RAISE EXCEPTION 'Expected Alex to have 2 current work tickets, got %', alex_current_count;
    END IF;

    SELECT count(*) INTO alex_weekly_count
    FROM backlog.member_weekly_activity_v
    WHERE handle = 'alex';

    IF alex_weekly_count < 2 THEN
        RAISE EXCEPTION 'Expected Alex to have at least 2 weekly activity rows, got %', alex_weekly_count;
    END IF;

    SELECT count(*) INTO blocked_count
    FROM backlog.blocked_tickets_v
    WHERE ticket_key IN ('UMB-102', 'UMB-111');

    IF blocked_count <> 2 THEN
        RAISE EXCEPTION 'Expected 2 blocked ticket rows, got %', blocked_count;
    END IF;

    SELECT count(*) INTO ready_count
    FROM backlog.product_sync_v
    WHERE product_bucket = 'ready';

    IF ready_count < 3 THEN
        RAISE EXCEPTION 'Expected at least 3 ready tickets, got %', ready_count;
    END IF;

    SELECT count(*) INTO workload_count
    FROM backlog.workload_summary_v
    WHERE handle IN ('alex', 'sam', 'priya');

    IF workload_count <> 3 THEN
        RAISE EXCEPTION 'Expected workload rows for 3 engineers, got %', workload_count;
    END IF;

    PERFORM backlog.create_team('qa', 'Quality Assurance', 'QA team for smoke tests');
    PERFORM backlog.create_person('qa-smoke', 'QA Smoke', 'qa-smoke@umbrella.dev', 'qa', 'qa', 'America/New_York', 4, true);
    PERFORM backlog.create_epic(
        'Smoke Test Epic',
        'smoke-test-epic',
        'Ephemeral epic for function validation.',
        'active',
        'medium',
        'taylor',
        ((now() AT TIME ZONE 'America/New_York')::date + 5),
        ((now() AT TIME ZONE 'America/New_York')::date),
        'EP-SMOKE'
    );
    PERFORM backlog.create_ticket(
        'smoke-test-epic',
        'Validate smoke path',
        'smoke-validate-smoke-path',
        'chore',
        'intake',
        'medium',
        'qa-smoke',
        'taylor',
        'Temporary ticket used to verify function behavior.',
        'Exists only inside the test transaction.',
        NULL,
        ((now() AT TIME ZONE 'America/New_York')::date + 1),
        1,
        '/tmp',
        'test',
        'UMB-SMOKE'
    );
    PERFORM backlog.assign_ticket(
        'UMB-SMOKE',
        'alex',
        'taylor',
        'Shifting the smoke test ticket to Alex.',
        now()
    );
    PERFORM backlog.transition_ticket(
        'UMB-SMOKE',
        'in_progress',
        'alex',
        'Starting the smoke path.',
        NULL,
        now()
    );
    PERFORM backlog.log_work(
        'UMB-SMOKE',
        'alex',
        'Verified create, assign, transition, and log flows.',
        'This row should roll back with the transaction.',
        15,
        now()
    );

    SELECT count(*) INTO transition_count
    FROM backlog.ticket_status_history
    WHERE ticket_id = backlog.ticket_id_for_key('UMB-SMOKE')
      AND to_status = 'in_progress';

    IF transition_count <> 1 THEN
        RAISE EXCEPTION 'Expected 1 in-progress history row for smoke ticket, got %', transition_count;
    END IF;

    SELECT count(*) INTO assignment_count
    FROM backlog.ticket_assignment_history
    WHERE ticket_id = backlog.ticket_id_for_key('UMB-SMOKE')
      AND to_assignee_id = backlog.person_id_for_handle('alex');

    IF assignment_count <> 1 THEN
        RAISE EXCEPTION 'Expected 1 assignment history row for smoke ticket, got %', assignment_count;
    END IF;

    SELECT count(*) INTO worklog_inserted
    FROM backlog.work_logs
    WHERE ticket_id = backlog.ticket_id_for_key('UMB-SMOKE')
      AND person_id = backlog.person_id_for_handle('alex');

    IF worklog_inserted <> 1 THEN
        RAISE EXCEPTION 'Expected 1 work log row for smoke ticket, got %', worklog_inserted;
    END IF;
END
$$;

ROLLBACK;
