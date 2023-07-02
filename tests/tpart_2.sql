\i utils/umain_helps.sql

--_-_-_-_-_- pr_p2p_check_add TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    n_count         INT := 0;
    n_p2p           INT := (SELECT COUNT(*) FROM P2P);
    n_checks        INT := (SELECT COUNT(*) FROM Checks);
    p2p_max_id      INT := fn_max_id('P2P');
    checks_max_id   INT := fn_max_id('Checks');
    checked_user    TEXT := 'A';
    checker_user    TEXT := 'B';
    p2p_row         P2P%rowtype;
    check_row       Checks%rowtype;
BEGIN
    PERFORM fn_print('-- # -- ------------------------ -- # --');
    PERFORM fn_print('-- # -- ######## PART 2 ######## -- # --');
    PERFORM fn_print('-- # -- ------------------------ -- # --');
    PERFORM fn_print('');
    PERFORM fn_print('');

    PERFORM fn_print('-- # -- START TEST pr_p2p_check_add -- # --');


    INSERT INTO Peers VALUES (checker_user, '1991-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO Peers VALUES (checked_user, '1991-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);


    CALL pr_p2p_check_add(checked_user, checker_user, 'DO3_LinuxMonitoring_v1.0', 'Start', '01:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p);
    assert((SELECT COUNT(*) FROM Checks) = n_checks);

    CALL pr_p2p_check_add(checked_user, checker_user, 'C3_StringPlus', 'Failure', '01:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p);
    assert((SELECT COUNT(*) FROM Checks) = n_checks);

    CALL pr_p2p_check_add(checked_user, checker_user, 'C3_StringPlus', 'Start', '01:00:00');
    CALL pr_p2p_check_add('A', 'B', 'C3_StringPlus', 'Start', '01:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p);
    assert((SELECT COUNT(*) FROM Checks) = n_checks);

    CALL pr_p2p_check_add(checked_user, checker_user, 'C2_SimpleBashUtils', 'Success', '01:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p);
    assert((SELECT COUNT(*) FROM Checks) = n_checks);

    CALL pr_p2p_check_add('A', 'B', 'C2_SimpleBashUtils', 'Start', '01:00:00');
    CALL pr_p2p_check_add(checked_user, checker_user, 'C2_SimpleBashUtils', 'Start', '01:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p + 1);
    assert((SELECT COUNT(*) FROM Checks) = n_checks + 1);

    CALL pr_p2p_check_add(checked_user, checker_user, 'C2_SimpleBashUtils', 'Start', '01:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p + 1);
    assert((SELECT COUNT(*) FROM Checks) = n_checks + 1);

    SELECT id, "Check", CheckingPeer, State, "Time" INTO p2p_row FROM P2P ORDER BY ID DESC LIMIT 1;
    assert(p2p_row.id = p2p_max_id + 1);
    assert(p2p_row."Check" = checks_max_id + 1);
    assert(p2p_row.CheckingPeer = checker_user);
    assert(p2p_row.State = 'Start');
    assert(p2p_row."Time" = '01:00:00');

    SELECT id, Peer, Task INTO check_row FROM Checks ORDER BY ID DESC LIMIT 1;
    assert(check_row.id = checks_max_id + 1);
    assert(check_row.Peer = checked_user);
    assert(check_row.Task = 'C2_SimpleBashUtils');

    CALL pr_p2p_check_add(checked_user, checker_user, 'C2_SimpleBashUtils', 'Start', '01:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p + 1);
    assert((SELECT COUNT(*) FROM Checks) = n_checks + 1);

    CALL pr_p2p_check_add(checked_user, checker_user, 'C2_SimpleBashUtils', 'Success', '01:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p + 2);
    assert((SELECT COUNT(*) FROM Checks) = n_checks + 1);

    CALL pr_p2p_check_add(checked_user, checker_user, 'DO3_LinuxMonitoring_v1.0', 'Failure', '11:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p + 2);
    assert((SELECT COUNT(*) FROM Checks) = n_checks + 1);

    CALL pr_p2p_check_add(checked_user, checker_user, 'DO3_LinuxMonitoring_v1.0', 'Success', '11:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p + 2);
    assert((SELECT COUNT(*) FROM Checks) = n_checks + 1);

    CALL pr_p2p_check_add(checked_user, checker_user, 'DO3_LinuxMonitoring_v1.0', 'Start', '11:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p + 2);
    assert((SELECT COUNT(*) FROM Checks) = n_checks + 1);

    CALL pr_p2p_check_add(checked_user, checker_user, 'C4_Math', 'Start', '11:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p + 2);
    assert((SELECT COUNT(*) FROM Checks) = n_checks + 1);

    CALL pr_p2p_check_add(checked_user, checker_user, 'C4_Math', 'Success', '11:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p + 2);
    assert((SELECT COUNT(*) FROM Checks) = n_checks + 1);

    CALL pr_p2p_check_add(checked_user, checker_user, 'C3_StringPlus', 'Success', '11:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p + 2);
    assert((SELECT COUNT(*) FROM Checks) = n_checks + 1);

    CALL pr_p2p_check_add(checked_user, checker_user, 'C3_StringPlus', 'Start', '11:00:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p + 3);
    assert((SELECT COUNT(*) FROM Checks) = n_checks + 2);

    CALL pr_p2p_check_add(checked_user, checker_user, 'C3_StringPlus', 'Start', '13:40:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p + 3);
    assert((SELECT COUNT(*) FROM Checks) = n_checks + 2);

    CALL pr_p2p_check_add(checked_user, checker_user, 'C3_StringPlus', 'Failure', '14:10:00');
    assert((SELECT COUNT(*) FROM P2P) = n_p2p + 4);
    assert((SELECT COUNT(*) FROM Checks) = n_checks + 2);

    SELECT id, "Check", CheckingPeer, State, "Time" INTO p2p_row FROM P2P ORDER BY ID DESC LIMIT 1;
    assert(p2p_row.id = p2p_max_id + 4);
    assert(p2p_row."Check" = checks_max_id + 2);
    assert(p2p_row.CheckingPeer = checker_user);
    assert(p2p_row.State = 'Failure');
    assert(p2p_row."Time" = '14:10:00');

    SELECT id, Peer, Task INTO check_row FROM Checks ORDER BY ID DESC LIMIT 1;
    assert(check_row.id = checks_max_id + 2);
    assert(check_row.Peer = checked_user);
    assert(check_row.Task = 'C3_StringPlus');

    PERFORM fn_print('                    -- [ OK ] --');
END;
$$ language plpgsql;
ROLLBACK;

-- -_-_-_-_-_- pr_verter_check_add TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    n_count             INT := 0;
    n_ver_new           INT := 0;
    n_ver_old           INT := 0;
    checked_user1       TEXT := 'A';
    checked_user2       TEXT := 'B';
    checker_user1       TEXT := 'Deghayra';
    checker_user2       TEXT := 'Jecugrrl';
    check_max_id_user1  BIGINT := 0;
    check_max_id_user2  BIGINT := 0;
    check_row           Checks%rowtype;
    verter_row          Verter%rowtype;
    n_start_vector      INT := 0;
    n_end_vector        INT := 0;
BEGIN
    PERFORM fn_print('-- # -- START TEST pr_verter_check_add -- # --');

    INSERT INTO Peers VALUES (checked_user1, '1991-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO Peers VALUES (checked_user2, '1995-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    check_max_id_user1 = fn_next_id('Checks');
    CALL pr_p2p_check_add(checked_user1, checker_user1, 'C2_SimpleBashUtils', 'Start', '01:00:00');
    assert(fn_max_id('Checks') = check_max_id_user1);

    CALL pr_p2p_check_add(checked_user1, checker_user1, 'C2_SimpleBashUtils', 'Success', '01:20:00');
    SELECT id, Peer, Task INTO check_row FROM Checks ORDER BY ID DESC LIMIT 1;
    assert(check_row.id = check_max_id_user1);
    assert(check_row.Peer = checked_user1);
    assert(check_row.Task = 'C2_SimpleBashUtils');


    check_max_id_user2 = fn_next_id('Checks');
    CALL pr_p2p_check_add(checked_user2, checker_user2, 'C2_SimpleBashUtils', 'Start', '01:10:00');
    assert(fn_max_id('Checks') = check_max_id_user2);

    CALL pr_p2p_check_add(checked_user2, checker_user2, 'C2_SimpleBashUtils', 'Success', '01:30:00');
    SELECT id, Peer, Task INTO check_row FROM Checks ORDER BY ID DESC LIMIT 1;
    assert(check_row.id = check_max_id_user2);
    assert(check_row.Peer = checked_user2);
    assert(check_row.Task = 'C2_SimpleBashUtils');


    n_ver_old = (SELECT COUNT(*) FROM Verter);
    CALL pr_verter_check_add(checked_user1, 'C2_SimpleBashUtils', 'Failure', '11:11:11');
    assert(n_ver_old = (SELECT COUNT(*) FROM Verter));

    CALL pr_verter_check_add(checked_user1, 'C2_SimpleBashUtils', 'Start', '11:11:11');
    n_ver_new = (SELECT COUNT(*) FROM Verter);
    assert((n_ver_old + 1) = n_ver_new);

    n_ver_old = (SELECT COUNT(*) FROM Verter);
    CALL pr_verter_check_add(checked_user2, 'C2_SimpleBashUtils', 'Start', '11:11:12');
    n_ver_new = (SELECT COUNT(*) FROM Verter);
    assert((n_ver_old + 1) = n_ver_new);

    n_ver_old = (SELECT COUNT(*) FROM Verter);
    CALL pr_verter_check_add(checked_user1, 'C2_SimpleBashUtils', 'Success', '11:18:11');
    n_ver_new = (SELECT COUNT(*) FROM Verter);
    assert((n_ver_old + 1) = n_ver_new);

    SELECT id, "Check", State, "Time" INTO verter_row FROM Verter ORDER BY ID DESC LIMIT 1;
    assert(verter_row."Check" = check_max_id_user1);
    assert(verter_row.State = 'Success');
    assert(verter_row."Time" = '11:18:11');

    n_ver_old = (SELECT COUNT(*) FROM Verter);
    CALL pr_verter_check_add(checked_user2, 'C2_SimpleBashUtils', 'Success', '11:19:11');
    n_ver_new = (SELECT COUNT(*) FROM Verter);
    assert((n_ver_old + 1) = n_ver_new);

    SELECT id, "Check", State, "Time" INTO verter_row FROM Verter ORDER BY ID DESC LIMIT 1;
    assert(verter_row."Check" = check_max_id_user2);
    assert(verter_row.State = 'Success');
    assert(verter_row."Time" = '11:19:11');


    PERFORM fn_print('                    -- [ OK ] --');
END;
$$ language plpgsql;
ROLLBACK;

-- -_-_-_-_-_-fn_trg_p2p_transferred_points_insert TEST-_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    n_count         INT := 0;
    n_p2p           INT := (SELECT COUNT(*) FROM P2P);
    n_checks        INT := (SELECT COUNT(*) FROM Checks);
    id_check        INT := 0;
    p2p_max_id      INT := fn_max_id('P2P');
    checks_max_id   INT := fn_max_id('Checks');
    checked_user1   TEXT := 'A';
    checked_user2   TEXT := 'B';
    checker_user1   TEXT := 'Tereraya';
    checker_user2   TEXT := 'Katemede';
    tranferred_row  TransferredPoints%rowtype;

    n_points_old INT := 0;
    n_points_new INT := 0;
BEGIN
    PERFORM fn_print('-- # -- START TEST fn_trg_p2p_transferred_points_insert -- # --');

    INSERT INTO Peers VALUES (checked_user1, '1991-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO Peers VALUES (checked_user2, '1995-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    -- -------------------------------------------- --

    CALL pr_p2p_check_add(checked_user1, checker_user1, 'C2_SimpleBashUtils', 'Start', '01:00:00');
    CALL pr_p2p_check_add(checked_user1, checker_user1, 'C2_SimpleBashUtils', 'Failure', '01:20:00');

    n_points_old = (SELECT pointsamount FROM TransferredPoints WHERE CheckingPeer = checker_user1
        AND CheckedPeer = checked_user1);
    CALL pr_p2p_check_add(checked_user1, checker_user1, 'C2_SimpleBashUtils', 'Start', '01:00:00');
    n_points_new = (SELECT pointsamount FROM TransferredPoints WHERE CheckingPeer = checker_user1
        AND CheckedPeer = checked_user1);

    CALL pr_p2p_check_add(checked_user1, checker_user1, 'C2_SimpleBashUtils', 'Success', '01:20:00');
    assert((n_points_old + 1) = n_points_new);

    -- -------------------------------------------- --
    id_check = fn_next_id('Checks');
    INSERT INTO Checks VALUES (id_check, checked_user2, 'C2_SimpleBashUtils', '2023-02-20');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, checker_user2, 'Start', '13:12:00');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, checker_user2, 'Failure', '13:22:00');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    -- -------------------------------------------- --
    id_check = fn_next_id('Checks');
    INSERT INTO Checks VALUES (id_check, checked_user2, 'C2_SimpleBashUtils', '2023-02-20');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    n_points_old = (SELECT pointsamount FROM TransferredPoints WHERE CheckingPeer = checker_user2
        AND CheckedPeer = checked_user2);
    INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, checker_user2, 'Start', '18:12:00');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, checker_user2, 'Failure', '18:22:00');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    n_points_new = (SELECT pointsamount FROM TransferredPoints WHERE CheckingPeer = checker_user2
        AND CheckedPeer = checked_user2);
    assert((n_points_old + 1) = n_points_new);

    -- -------------------------------------------- --
    n_points_old = (SELECT pointsamount FROM TransferredPoints WHERE CheckingPeer = checker_user1
        AND CheckedPeer = checked_user1);

    CALL pr_p2p_check_add(checked_user1, checker_user1, 'C3_StringPlus', 'Start', '01:00:00');
    n_points_new = (SELECT pointsamount FROM TransferredPoints WHERE CheckingPeer = checker_user1
        AND CheckedPeer = checked_user1);
    assert((n_points_old + 1) = n_points_new);

    -- -------------------------------------------- --
    n_points_old = (SELECT pointsamount FROM TransferredPoints WHERE CheckingPeer = checker_user1
        AND CheckedPeer = checked_user1);
    CALL pr_p2p_check_add(checked_user1, checker_user1, 'C3_StringPlus', 'Failure', '01:20:00');
    n_points_new = (SELECT pointsamount FROM TransferredPoints WHERE CheckingPeer = checker_user1
        AND CheckedPeer = checked_user1);
    assert((n_points_old) = n_points_new);

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_-fn_trg_xp_check_add TEST-_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    n_count         INT := 0;
    checked_user    TEXT := 'A';
    checker_user    TEXT := 'B';
    id_check        BIGINT := 0;
    id_xp           BIGINT := fn_next_id('XP');
    id_verter       BIGINT := 0;
    check_row       Checks%rowtype;
    verter_row      Verter%rowtype;
    p2p_row         P2P%rowtype;
BEGIN
    PERFORM fn_print('-- # -- START TEST fn_trg_xp_check_add  -- # --');
    -- -------------------------------------------- --

    INSERT INTO Peers VALUES (checked_user, '1998-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO Peers VALUES (checker_user, '1996-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    CALL pr_p2p_check_add(checked_user, checker_user, 'C2_SimpleBashUtils', 'Start', '11:00:00');
    CALL pr_p2p_check_add(checked_user, checker_user, 'C2_SimpleBashUtils', 'Success', '11:40:00');

    id_verter = fn_max_id('Verter');
    id_check = fn_max_id('Checks');
    CALL pr_verter_check_add(checked_user, 'C2_SimpleBashUtils', 'Start', '12:50:11');
    SELECT * INTO verter_row FROM Verter ORDER BY ID DESC LIMIT 1;
--     RAISE NOTICE 'RESULT: %', id_verter;
--     RAISE NOTICE 'RESULT: %', verter_row.id;
    assert(verter_row.id = (id_verter + 1));
    assert(verter_row."Check" = id_check);
    assert(verter_row."Time" = '12:50:11');


    CALL pr_verter_check_add(checked_user, 'C2_SimpleBashUtils', 'Success', '12:51:11');

    SELECT * INTO verter_row FROM Verter ORDER BY ID DESC LIMIT 1;
--     RAISE NOTICE 'RESULT: %', id_verter;
--     RAISE NOTICE 'RESULT: %', verter_row.id;
    assert(verter_row.id = (id_verter + 2));
    assert(verter_row."Check" = id_check);
    assert(verter_row."Time" = '12:51:11');

    INSERT INTO XP VALUES (id_xp, id_check, 250);
    assert((SELECT xpamount FROM  XP WHERE XP."Check" = id_check) = 250);

    -- -------------------------------------------- --
    id_check = fn_max_id('Checks');
    CALL pr_p2p_check_add(checked_user, checker_user, 'C3_StringPlus', 'Start', '12:00:00');

    SELECT * INTO p2p_row FROM P2P ORDER BY ID DESC LIMIT 1;
    assert(p2p_row."Check" = id_check + 1);
    assert(p2p_row.CheckingPeer = checker_user);
    assert(p2p_row.State = 'Start');
    assert(p2p_row."Time" = '12:00:00');

    id_check = fn_max_id('Checks');
    CALL pr_p2p_check_add(checked_user, checker_user, 'C3_StringPlus', 'Success', '12:30:00');

    SELECT * INTO p2p_row FROM P2P ORDER BY ID DESC LIMIT 1;
    assert(p2p_row."Check" = id_check);
    assert(p2p_row.CheckingPeer = checker_user);
    assert(p2p_row.State = 'Success');
    assert(p2p_row."Time" = '12:30:00');

    -- id_verter = fn_max_id('Verter');
    CALL pr_verter_check_add(checked_user, 'C3_StringPlus', 'Start', '13:10:11');
    SELECT * INTO verter_row FROM Verter ORDER BY ID DESC LIMIT 1;
--     RAISE NOTICE 'RESULT: %', id_verter;
--     RAISE NOTICE 'RESULT: %', verter_row.id;
    assert(verter_row.id = (id_verter + 3));
    assert(verter_row."Check" = id_check);
    assert(verter_row."Time" = '13:10:11');

    CALL pr_verter_check_add(checked_user, 'C3_StringPlus', 'Failure', '13:11:21');
    SELECT * INTO verter_row FROM Verter ORDER BY ID DESC LIMIT 1;
    -- RAISE NOTICE 'RESULT: %', id_verter;
    -- RAISE NOTICE 'RESULT: %', verter_row.id;
    assert(verter_row.id = (id_verter + 4));
    assert(verter_row."Check" = id_check);
    assert(verter_row."Time" = '13:11:21');

    SELECT * INTO check_row FROM Checks ORDER BY ID DESC LIMIT 1;
    assert(check_row.ID = id_check);
    assert(check_row.Peer = checked_user);
    assert(check_row.Task = 'C3_StringPlus');

    id_xp = fn_next_id('XP');
    INSERT INTO XP VALUES (id_xp, id_check, 500);
    assert((SELECT xpamount FROM  XP WHERE XP."Check" = id_check) IS NULL);

    -- -------------------------------------------- --
    CALL pr_p2p_check_add(checked_user, checker_user, 'C3_StringPlus', 'Start', '13:00:00');

    SELECT * INTO p2p_row FROM P2P ORDER BY ID DESC LIMIT 1;
    assert(p2p_row."Check" = id_check + 1);
    assert(p2p_row.CheckingPeer = checker_user);
    assert(p2p_row.State = 'Start');
    assert(p2p_row."Time" = '13:00:00');

    -- id_check = fn_max_id('Checks');
    CALL pr_p2p_check_add(checked_user, checker_user, 'C3_StringPlus', 'Success', '13:30:00');

    SELECT * INTO p2p_row FROM P2P ORDER BY ID DESC LIMIT 1;
    assert(p2p_row."Check" = id_check + 1);
    assert(p2p_row.CheckingPeer = checker_user);
    assert(p2p_row.State = 'Success');
    assert(p2p_row."Time" = '13:30:00');


    -- RAISE NOTICE 'BEFORE VERTER: %', fn_max_id('Verter');
    CALL pr_verter_check_add(checked_user, 'C3_StringPlus', 'Start', '14:10:11');
    SELECT * INTO verter_row FROM Verter ORDER BY ID DESC LIMIT 1;
    -- RAISE NOTICE 'RESULT: %', id_verter;
    -- RAISE NOTICE 'RESULT: %', verter_row.id;
    assert(verter_row.id = (id_verter + 5));
    assert(verter_row."Check" = id_check + 1);
    assert(verter_row."Time" = '14:10:11');

    CALL pr_verter_check_add(checked_user, 'C3_StringPlus', 'Success', '14:13:11');
    SELECT * INTO verter_row FROM Verter ORDER BY ID DESC LIMIT 1;
    -- RAISE NOTICE 'RESULT: %', id_verter;
    -- RAISE NOTICE 'RESULT: %', verter_row.id;
    assert(verter_row.id = (id_verter + 6));
    assert(verter_row."Check" = id_check + 1);
    assert(verter_row."Time" = '14:13:11');

    id_xp = fn_next_id('XP');
    INSERT INTO XP VALUES (id_xp, id_check + 1, 500);
    assert((SELECT xpamount FROM  XP WHERE XP."Check" = id_check + 1) = 500);

    -- -------------------------------------------- --

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;
