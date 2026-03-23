BEGIN;

DELETE FROM backlog.tickets
WHERE ticket_key IN (
    'NAV-01', 'NAV-02', 'NAV-03', 'NAV-04', 'NAV-05',
    'WS-01', 'WS-02', 'WS-03', 'WS-04', 'WS-05',
    'ORG-01', 'ORG-02', 'ORG-03', 'ORG-04',
    'INV-01', 'INV-02', 'INV-03', 'INV-04', 'INV-05',
    'PROJ-01', 'PROJ-02', 'PROJ-03', 'PROJ-04', 'PROJ-05', 'PROJ-06',
    'CS-01', 'CS-02', 'CS-03', 'CS-04', 'CS-05', 'CS-06', 'CS-07', 'CS-08', 'CS-09', 'CS-10', 'CS-11',
    'DOC-01', 'DOC-02', 'DOC-03', 'DOC-04',
    'AIR-01', 'AIR-02', 'AIR-03', 'AIR-04',
    'OB-01', 'OB-02', 'OB-03'
);

DELETE FROM backlog.epics
WHERE slug IN (
    'three-view-navigation-system',
    'workspace-grid-org-color-identity',
    'unified-org-identity-no-switcher',
    'invite-onboarding-flow-redux',
    'project-creation-redux-drop-a-doc',
    'umbra-call-sheet-intelligence-read',
    'umbra-call-sheet-intelligence-create',
    'document-triggered-thread-creation-universal',
    'ai-requirements-new-capabilities-gap',
    'phone-first-onboarding'
);

SELECT backlog.create_epic(
    p_title => 'Three-View Navigation System',
    p_slug => 'three-view-navigation-system',
    p_summary => 'Replace current bottom nav with unified Chats / Spaces / Home toggle. Imported from Engineering Epics Wave 2.',
    p_status => 'active',
    p_priority => 'critical',
    p_epic_key => 'W2-E1'
);

SELECT backlog.create_epic(
    p_title => 'Workspace Grid & Org Color Identity',
    p_slug => 'workspace-grid-org-color-identity',
    p_summary => 'Replace identical placeholder tiles with live workspace dashboards showing real stats, activity, presence, and mode. Imported from Engineering Epics Wave 2.',
    p_status => 'active',
    p_priority => 'critical',
    p_epic_key => 'W2-E2'
);

SELECT backlog.create_epic(
    p_title => 'Unified Org Identity — No Switcher',
    p_slug => 'unified-org-identity-no-switcher',
    p_summary => 'All orgs visible in one unified view with org stripes and no workspace switcher. Imported from Engineering Epics Wave 2.',
    p_status => 'active',
    p_priority => 'critical',
    p_epic_key => 'W2-E3'
);

SELECT backlog.create_epic(
    p_title => 'Invite & Onboarding Flow Redux',
    p_slug => 'invite-onboarding-flow-redux',
    p_summary => 'Bulk invite with Umbra-generated personalized welcome briefings across thread, folder, and workspace scopes. Imported from Engineering Epics Wave 2.',
    p_status => 'active',
    p_priority => 'high',
    p_epic_key => 'W2-E4'
);

SELECT backlog.create_epic(
    p_title => 'Project Creation Redux — Drop a Doc',
    p_slug => 'project-creation-redux-drop-a-doc',
    p_summary => 'Drop any document, have Umbra read it, scaffold the workspace, assemble the team, and brief everyone. Imported from Engineering Epics Wave 2.',
    p_status => 'active',
    p_priority => 'critical',
    p_epic_key => 'W2-E5'
);

SELECT backlog.create_epic(
    p_title => 'Umbra Call Sheet Intelligence — Read',
    p_slug => 'umbra-call-sheet-intelligence-read',
    p_summary => 'Upload any call sheet, extract all fields, create department threads, and notify crew with personalized updates. Imported from Engineering Epics Wave 2.',
    p_status => 'active',
    p_priority => 'critical',
    p_epic_key => 'W2-E6'
);

SELECT backlog.create_epic(
    p_title => 'Umbra Call Sheet Intelligence — Create',
    p_slug => 'umbra-call-sheet-intelligence-create',
    p_summary => 'Move call sheet creation into Umbra with upload, continuation, and generate-from-scratch flows. Imported from Engineering Epics Wave 2.',
    p_status => 'active',
    p_priority => 'critical',
    p_epic_key => 'W2-E7'
);

SELECT backlog.create_epic(
    p_title => 'Document-Triggered Thread Creation — Universal',
    p_slug => 'document-triggered-thread-creation-universal',
    p_summary => 'Generalize the call-sheet proof of concept so any document can create threads, assemble teams, and brief participants. Imported from Engineering Epics Wave 2.',
    p_status => 'active',
    p_priority => 'critical',
    p_epic_key => 'W2-E8'
);

SELECT backlog.create_epic(
    p_title => 'AI Requirements — New Capabilities Gap',
    p_slug => 'ai-requirements-new-capabilities-gap',
    p_summary => 'Capture new AI capability gaps discovered in the call-sheet session and add them to the build scope. Imported from Engineering Epics Wave 2.',
    p_status => 'active',
    p_priority => 'high',
    p_epic_key => 'W2-E9'
);

SELECT backlog.create_epic(
    p_title => 'Phone-First Onboarding',
    p_slug => 'phone-first-onboarding',
    p_summary => 'Phone number first, immediate messaging, and tools-always-running onboarding. Imported from Engineering Epics Wave 2.',
    p_status => 'active',
    p_priority => 'critical',
    p_epic_key => 'W2-E10'
);

SELECT backlog.create_tag('mobile', 'Mobile', '#2563eb');
SELECT backlog.create_tag('desktop', 'Desktop', '#0f766e');
SELECT backlog.create_tag('cross-platform', 'Cross-Platform', '#475569');
SELECT backlog.create_tag('backend', 'Backend', '#ea580c');
SELECT backlog.create_tag('ai', 'AI', '#7c3aed');
SELECT backlog.create_tag('domain-navigation', 'Domain: Navigation', '#1d4ed8');
SELECT backlog.create_tag('domain-workspaces', 'Domain: Workspaces', '#0f766e');
SELECT backlog.create_tag('domain-org-identity', 'Domain: Org Identity', '#4338ca');
SELECT backlog.create_tag('domain-invites', 'Domain: Invites', '#b45309');
SELECT backlog.create_tag('domain-project-creation', 'Domain: Project Creation', '#15803d');
SELECT backlog.create_tag('domain-call-sheet-read', 'Domain: Call Sheet Read', '#dc2626');
SELECT backlog.create_tag('domain-call-sheet-create', 'Domain: Call Sheet Create', '#be123c');
SELECT backlog.create_tag('domain-document-automation', 'Domain: Document Automation', '#7c3aed');
SELECT backlog.create_tag('domain-ai-requirements', 'Domain: AI Requirements', '#6d28d9');
SELECT backlog.create_tag('domain-onboarding', 'Domain: Onboarding', '#0369a1');

SELECT backlog.create_ticket(p_epic_slug => 'three-view-navigation-system', p_title => 'Three-view toggle pill — mobile header', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Center pill in top header: Chats · Spaces · Home with instant view switching and highlighted active state.', p_estimate_points => 3, p_ticket_key => 'NAV-01');
SELECT backlog.create_ticket(p_epic_slug => 'three-view-navigation-system', p_title => 'Bottom nav restructure — mobile', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Chats · Spaces · Umbra FAB · Activity · Home. Remove the current Work/Chat/AI/Activity/Tools structure.', p_estimate_points => 3, p_ticket_key => 'NAV-02');
SELECT backlog.create_ticket(p_epic_slug => 'three-view-navigation-system', p_title => 'Desktop icon rail + collapsible sidebar', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'high', p_summary => 'Build a 52px left rail with a 240px collapsible sidebar, workspace list, org stripes, and unread badges.', p_estimate_points => 5, p_ticket_key => 'NAV-03');
SELECT backlog.create_ticket(p_epic_slug => 'three-view-navigation-system', p_title => 'Chats as default landing screen', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Open the app to Chats with unified inbox, org filter pills, and a chat list with stripe indicators per org.', p_estimate_points => 3, p_ticket_key => 'NAV-04');
SELECT backlog.create_ticket(p_epic_slug => 'three-view-navigation-system', p_title => 'View state persistence', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'medium', p_summary => 'Remember the last active view and the last active thread per view, then restore both on app open.', p_estimate_points => 1, p_ticket_key => 'NAV-05');

SELECT backlog.create_ticket(p_epic_slug => 'workspace-grid-org-color-identity', p_title => 'Org color identity system', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Assign each org a unique color and use it for chat stripes, workspace tile bars, avatar backgrounds, and notification accents.', p_estimate_points => 1, p_ticket_key => 'WS-01');
SELECT backlog.create_ticket(p_epic_slug => 'workspace-grid-org-color-identity', p_title => 'Workspace tile redesign — live dashboard', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Redesign workspace tiles to show colored top strips, org monograms, live stats, previews, member avatars, and mode indicators.', p_estimate_points => 5, p_ticket_key => 'WS-02');
SELECT backlog.create_ticket(p_epic_slug => 'workspace-grid-org-color-identity', p_title => 'Workspace grid sort + filter', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'medium', p_summary => 'Support sorting by last viewed, most active, and alphabetical with filter pills for all, workspaces, folders, and tools.', p_estimate_points => 1, p_ticket_key => 'WS-03');
SELECT backlog.create_ticket(p_epic_slug => 'workspace-grid-org-color-identity', p_title => 'Urgent / action badges on tiles', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'high', p_summary => 'Add Action, Secure, and Active badges to tiles using thread activity and AI flags.', p_estimate_points => 3, p_ticket_key => 'WS-04');
SELECT backlog.create_ticket(p_epic_slug => 'workspace-grid-org-color-identity', p_title => 'Workspace tile → thread entry', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Tapping a tile opens the workspace thread list with org stripe, unread count, last message preview, and timestamp.', p_estimate_points => 3, p_ticket_key => 'WS-05');

SELECT backlog.create_ticket(p_epic_slug => 'unified-org-identity-no-switcher', p_title => 'Unified chat list — all orgs in one view', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Show threads from all connected orgs in one list with colored left stripes and org filter pills, with no switcher.', p_estimate_points => 5, p_ticket_key => 'ORG-01');
SELECT backlog.create_ticket(p_epic_slug => 'unified-org-identity-no-switcher', p_title => 'Auto identity selection per thread', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Auto-select the correct org identity for each thread and surface the identity badge in the thread header.', p_estimate_points => 5, p_ticket_key => 'ORG-02');
SELECT backlog.create_ticket(p_epic_slug => 'unified-org-identity-no-switcher', p_title => 'Org stripe system — thread list + tiles', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Keep 3px thread stripes and 4px workspace tile bars consistent across mobile and desktop.', p_estimate_points => 1, p_ticket_key => 'ORG-03');
SELECT backlog.create_ticket(p_epic_slug => 'unified-org-identity-no-switcher', p_title => 'Org context in thread header', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'high', p_summary => 'Add org name, colored dot, and cross-org boundary flagging in the thread header.', p_estimate_points => 1, p_ticket_key => 'ORG-04');

SELECT backlog.create_ticket(p_epic_slug => 'invite-onboarding-flow-redux', p_title => 'Bulk invite — upload roster or paste names', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Accept pasted names or numbers, CSV or Excel uploads, and contact selection while detecting existing users vs new invites.', p_estimate_points => 5, p_ticket_key => 'INV-01');
SELECT backlog.create_ticket(p_epic_slug => 'invite-onboarding-flow-redux', p_title => 'Invitee type selection', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'high', p_summary => 'Let the sender choose Team Member, Talent/Athlete, External Client, or Guest to drive permissions and welcome tone.', p_estimate_points => 3, p_ticket_key => 'INV-02');
SELECT backlog.create_ticket(p_epic_slug => 'invite-onboarding-flow-redux', p_title => 'Umbra-generated welcome briefing per invitee', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'high', p_summary => 'Post a personalized welcome briefing on join based on invitee type and project context.', p_estimate_points => 5, p_ticket_key => 'INV-03');
SELECT backlog.create_ticket(p_epic_slug => 'invite-onboarding-flow-redux', p_title => 'Invite level — thread / folder / workspace', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Support invite scoping to a single thread, folder, or full workspace with cascading permissions.', p_estimate_points => 3, p_ticket_key => 'INV-04');
SELECT backlog.create_ticket(p_epic_slug => 'invite-onboarding-flow-redux', p_title => 'SMS bridge for non-Umbrella contacts', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'high', p_summary => 'Send non-users an SMS join link with context and land them directly in the invited thread.', p_estimate_points => 5, p_ticket_key => 'INV-05');

SELECT backlog.create_ticket(p_epic_slug => 'project-creation-redux-drop-a-doc', p_title => 'Universal document drop — project creation entry point', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Replace the workspace naming form with a universal document-drop entry point that accepts PDFs, spreadsheets, docs, Movie Magic files, and screenshots.', p_estimate_points => 3, p_ticket_key => 'PROJ-01');
SELECT backlog.create_ticket(p_epic_slug => 'project-creation-redux-drop-a-doc', p_title => 'Document type detection + routing', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Detect call sheets, briefs, contracts, rosters, SOWs, scripts, and sprint plans, then route to the right flow with a confirmation step.', p_estimate_points => 5, p_ticket_key => 'PROJ-02');
SELECT backlog.create_ticket(p_epic_slug => 'project-creation-redux-drop-a-doc', p_title => 'Workspace scaffold from document output', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Auto-create workspace name, org color, and default thread structure from the document output.', p_estimate_points => 8, p_ticket_key => 'PROJ-03');
SELECT backlog.create_ticket(p_epic_slug => 'project-creation-redux-drop-a-doc', p_title => 'Auto team assembly from document', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Match names in the document to existing Umbrella users, queue invites for non-users, and support one-tap invite sending.', p_estimate_points => 8, p_ticket_key => 'PROJ-04');
SELECT backlog.create_ticket(p_epic_slug => 'project-creation-redux-drop-a-doc', p_title => 'Document-informed thread defaults', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'high', p_summary => 'Use document type to create the right thread model, such as department threads, deliverable threads, or a deal room.', p_estimate_points => 5, p_ticket_key => 'PROJ-05');
SELECT backlog.create_ticket(p_epic_slug => 'project-creation-redux-drop-a-doc', p_title => 'Start fresh fallback — Umbra Q&A creation', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'medium', p_summary => 'Fallback flow where Umbra asks project setup questions and scaffolds the workspace from answers.', p_estimate_points => 3, p_ticket_key => 'PROJ-06');

SELECT backlog.create_ticket(p_epic_slug => 'umbra-call-sheet-intelligence-read', p_title => 'Call sheet ingestion pipeline', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Support upload for PDF, XLSX, Movie Magic, DOCX, and images, run OCR where needed, and pass the file to extraction returning structured JSON.', p_estimate_points => 8, p_ticket_key => 'CS-01');
SELECT backlog.create_ticket(p_epic_slug => 'umbra-call-sheet-intelligence-read', p_title => 'Universal field extraction — Claude prompt', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Extract call sheet header, scenes, cast times, crew by department, background groups, stunts, SPFX, vehicles, meals, and safety bulletins.', p_estimate_points => 5, p_ticket_key => 'CS-02');
SELECT backlog.create_ticket(p_epic_slug => 'umbra-call-sheet-intelligence-read', p_title => 'Entity matching — doc names to Umbrella users', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Match extracted names to users by name, phone, or email, then queue invites for unmatched people with coordinator confirmation.', p_estimate_points => 8, p_ticket_key => 'CS-03');
SELECT backlog.create_ticket(p_epic_slug => 'umbra-call-sheet-intelligence-read', p_title => 'Auto department thread creation from call sheet', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Create department, all-crew, and cast threads from the call sheet and post the department brief as the first message.', p_estimate_points => 8, p_ticket_key => 'CS-04');
SELECT backlog.create_ticket(p_epic_slug => 'umbra-call-sheet-intelligence-read', p_title => 'Personalized notification generation + delivery', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Generate personalized notifications with call time, location, scenes, meals, weather, safety, and hospital info, then pin them in department threads.', p_estimate_points => 5, p_ticket_key => 'CS-05');
SELECT backlog.create_ticket(p_epic_slug => 'umbra-call-sheet-intelligence-read', p_title => 'Change detection + targeted re-notification', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'high', p_summary => 'Diff coordinator updates, identify affected crew only, send targeted notifications, and track read receipts.', p_estimate_points => 5, p_ticket_key => 'CS-06');

SELECT backlog.create_ticket(p_epic_slug => 'umbra-call-sheet-intelligence-create', p_title => 'Three-tier upload entry points', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Present upload call sheet, continue from yesterday, and start from scratch as three entry points on one screen.', p_estimate_points => 3, p_ticket_key => 'CS-07');
SELECT backlog.create_ticket(p_epic_slug => 'umbra-call-sheet-intelligence-create', p_title => 'Day continuation — generate Day N from Day N-1', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Use what rolled, what wrapped, and coordinator changes to generate the next day call sheet in about 20 minutes.', p_estimate_points => 8, p_ticket_key => 'CS-08');
SELECT backlog.create_ticket(p_epic_slug => 'umbra-call-sheet-intelligence-create', p_title => 'Generate from script breakdown + roster inputs', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'high', p_summary => 'Accept a script, crew roster, and location list, then generate the preliminary schedule and Day 1 call sheet draft with chat-based adjustment.', p_estimate_points => 8, p_ticket_key => 'CS-09');
SELECT backlog.create_ticket(p_epic_slug => 'umbra-call-sheet-intelligence-create', p_title => 'Coordinator review + approval UI', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Provide a full edit and approval interface for scenes, cast times, crew by department, background groups, and flags before sending to all crew.', p_estimate_points => 5, p_ticket_key => 'CS-10');
SELECT backlog.create_ticket(p_epic_slug => 'umbra-call-sheet-intelligence-create', p_title => 'Conflict + anomaly detection', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'high', p_summary => 'Flag overlapping scenes, insufficient turnaround, risky combinations, and duplicate entries before coordinator approval.', p_estimate_points => 3, p_ticket_key => 'CS-11');

SELECT backlog.create_ticket(p_epic_slug => 'document-triggered-thread-creation-universal', p_title => 'Document type → thread template mapping', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Map document types such as call sheet, brief, contract, and SOW into the correct thread template model.', p_estimate_points => 8, p_ticket_key => 'DOC-01');
SELECT backlog.create_ticket(p_epic_slug => 'document-triggered-thread-creation-universal', p_title => 'People extraction → team assembly for any doc type', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Extract names and roles from any document type and place each person in the right thread with coordinator confirmation before invite send.', p_estimate_points => 5, p_ticket_key => 'DOC-02');
SELECT backlog.create_ticket(p_epic_slug => 'document-triggered-thread-creation-universal', p_title => 'Umbra first message — doc-informed thread briefing', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'high', p_summary => 'Generate the first Umbra briefing message for every auto-created thread with purpose, participants, dates, and first action.', p_estimate_points => 5, p_ticket_key => 'DOC-03');
SELECT backlog.create_ticket(p_epic_slug => 'document-triggered-thread-creation-universal', p_title => 'Drop any doc as primary create-project CTA', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Make “Drop a doc to get started” the main create-project call to action and demote the old form to a fallback path.', p_estimate_points => 3, p_ticket_key => 'DOC-04');

SELECT backlog.create_ticket(p_epic_slug => 'ai-requirements-new-capabilities-gap', p_title => 'Document-triggered workspace generation — AI spec', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Define AI output for workspace generation: workspace name, thread structure, first messages, people list with role tags, and flags as structured JSON.', p_estimate_points => 5, p_ticket_key => 'AIR-01');
SELECT backlog.create_ticket(p_epic_slug => 'ai-requirements-new-capabilities-gap', p_title => 'Personalized notification content generation', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Specify how Umbra generates person-specific briefings for named people in any document.', p_estimate_points => 5, p_ticket_key => 'AIR-02');
SELECT backlog.create_ticket(p_epic_slug => 'ai-requirements-new-capabilities-gap', p_title => 'Change diff + targeted re-notification', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'high', p_summary => 'Describe semantic document comparison, affected-person detection, and targeted update generation for changed documents.', p_estimate_points => 8, p_ticket_key => 'AIR-03');
SELECT backlog.create_ticket(p_epic_slug => 'ai-requirements-new-capabilities-gap', p_title => 'Multi-vertical document vocabulary', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'high', p_summary => 'Expand AI understanding across film, theater, commercial, tech, and construction document vocabularies.', p_estimate_points => 5, p_ticket_key => 'AIR-04');

SELECT backlog.create_ticket(p_epic_slug => 'phone-first-onboarding', p_title => 'Phone number as primary identity', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Sign up with phone only, verify with OTP, and defer profile completion until after the first message.', p_estimate_points => 5, p_ticket_key => 'OB-01');
SELECT backlog.create_ticket(p_epic_slug => 'phone-first-onboarding', p_title => 'Contact discovery + immediate messaging', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'After verification, show Umbrella contacts already on the platform and push immediate first-message creation.', p_estimate_points => 5, p_ticket_key => 'OB-02');
SELECT backlog.create_ticket(p_epic_slug => 'phone-first-onboarding', p_title => 'Tools-always-running model — no upgrade gate', p_ticket_type => 'feature', p_status => 'ready', p_priority => 'critical', p_summary => 'Make AI, tasks, calendar, and files available in every thread from creation without any upgrade-to-project gate.', p_estimate_points => 3, p_ticket_key => 'OB-03');

WITH platform_tag_map(ticket_key, tag_slug) AS (
    VALUES
        ('NAV-01', 'mobile'),
        ('NAV-02', 'mobile'),
        ('NAV-03', 'desktop'),
        ('NAV-04', 'cross-platform'),
        ('NAV-05', 'cross-platform'),
        ('WS-01', 'cross-platform'),
        ('WS-02', 'desktop'),
        ('WS-03', 'desktop'),
        ('WS-04', 'cross-platform'),
        ('WS-05', 'desktop'),
        ('ORG-01', 'cross-platform'),
        ('ORG-02', 'cross-platform'),
        ('ORG-02', 'backend'),
        ('ORG-03', 'cross-platform'),
        ('ORG-04', 'cross-platform'),
        ('INV-01', 'cross-platform'),
        ('INV-01', 'backend'),
        ('INV-02', 'cross-platform'),
        ('INV-03', 'ai'),
        ('INV-03', 'backend'),
        ('INV-04', 'cross-platform'),
        ('INV-04', 'backend'),
        ('INV-05', 'mobile'),
        ('INV-05', 'backend'),
        ('PROJ-01', 'mobile'),
        ('PROJ-01', 'cross-platform'),
        ('PROJ-02', 'ai'),
        ('PROJ-02', 'backend'),
        ('PROJ-03', 'backend'),
        ('PROJ-04', 'backend'),
        ('PROJ-05', 'ai'),
        ('PROJ-05', 'backend'),
        ('PROJ-06', 'ai'),
        ('PROJ-06', 'cross-platform'),
        ('CS-01', 'ai'),
        ('CS-01', 'backend'),
        ('CS-02', 'ai'),
        ('CS-03', 'backend'),
        ('CS-04', 'backend'),
        ('CS-05', 'ai'),
        ('CS-05', 'backend'),
        ('CS-06', 'ai'),
        ('CS-06', 'backend'),
        ('CS-07', 'mobile'),
        ('CS-08', 'ai'),
        ('CS-08', 'backend'),
        ('CS-09', 'ai'),
        ('CS-09', 'backend'),
        ('CS-10', 'desktop'),
        ('CS-11', 'ai'),
        ('CS-11', 'backend'),
        ('DOC-01', 'ai'),
        ('DOC-01', 'backend'),
        ('DOC-02', 'ai'),
        ('DOC-02', 'backend'),
        ('DOC-03', 'ai'),
        ('DOC-04', 'cross-platform'),
        ('AIR-01', 'ai'),
        ('AIR-02', 'ai'),
        ('AIR-03', 'ai'),
        ('AIR-04', 'ai'),
        ('OB-01', 'mobile'),
        ('OB-01', 'backend'),
        ('OB-02', 'mobile'),
        ('OB-03', 'cross-platform')
)
INSERT INTO backlog.ticket_tags (ticket_id, tag_id)
SELECT
    backlog.ticket_id_for_key(ticket_key),
    backlog.tag_id_for_slug(tag_slug)
FROM platform_tag_map
ON CONFLICT (ticket_id, tag_id) DO NOTHING;

WITH domain_tag_map(ticket_key, tag_slug) AS (
    VALUES
        ('NAV-01', 'domain-navigation'),
        ('NAV-02', 'domain-navigation'),
        ('NAV-03', 'domain-navigation'),
        ('NAV-04', 'domain-navigation'),
        ('NAV-05', 'domain-navigation'),
        ('WS-01', 'domain-workspaces'),
        ('WS-02', 'domain-workspaces'),
        ('WS-03', 'domain-workspaces'),
        ('WS-04', 'domain-workspaces'),
        ('WS-05', 'domain-workspaces'),
        ('ORG-01', 'domain-org-identity'),
        ('ORG-02', 'domain-org-identity'),
        ('ORG-03', 'domain-org-identity'),
        ('ORG-04', 'domain-org-identity'),
        ('INV-01', 'domain-invites'),
        ('INV-02', 'domain-invites'),
        ('INV-03', 'domain-invites'),
        ('INV-04', 'domain-invites'),
        ('INV-05', 'domain-invites'),
        ('PROJ-01', 'domain-project-creation'),
        ('PROJ-02', 'domain-project-creation'),
        ('PROJ-03', 'domain-project-creation'),
        ('PROJ-04', 'domain-project-creation'),
        ('PROJ-05', 'domain-project-creation'),
        ('PROJ-06', 'domain-project-creation'),
        ('CS-01', 'domain-call-sheet-read'),
        ('CS-02', 'domain-call-sheet-read'),
        ('CS-03', 'domain-call-sheet-read'),
        ('CS-04', 'domain-call-sheet-read'),
        ('CS-05', 'domain-call-sheet-read'),
        ('CS-06', 'domain-call-sheet-read'),
        ('CS-07', 'domain-call-sheet-create'),
        ('CS-08', 'domain-call-sheet-create'),
        ('CS-09', 'domain-call-sheet-create'),
        ('CS-10', 'domain-call-sheet-create'),
        ('CS-11', 'domain-call-sheet-create'),
        ('DOC-01', 'domain-document-automation'),
        ('DOC-02', 'domain-document-automation'),
        ('DOC-03', 'domain-document-automation'),
        ('DOC-04', 'domain-document-automation'),
        ('AIR-01', 'domain-ai-requirements'),
        ('AIR-02', 'domain-ai-requirements'),
        ('AIR-03', 'domain-ai-requirements'),
        ('AIR-04', 'domain-ai-requirements'),
        ('OB-01', 'domain-onboarding'),
        ('OB-02', 'domain-onboarding'),
        ('OB-03', 'domain-onboarding')
)
INSERT INTO backlog.ticket_tags (ticket_id, tag_id)
SELECT
    backlog.ticket_id_for_key(ticket_key),
    backlog.tag_id_for_slug(tag_slug)
FROM domain_tag_map
ON CONFLICT (ticket_id, tag_id) DO NOTHING;

COMMIT;
