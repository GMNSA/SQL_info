\i utils/umain_helps.sql

--_-_-_-_-_- fn_print_human_readable_transferred_points TEST -_-_-_-_-_-_ --

-- C2_SimpleBashUtils 250
-- C3_StringPlus      500
-- C4_Math        300
-- C5_Decimal     350

BEGIN;
DO $$
DECLARE
    points          INT := 0;
BEGIN
    PERFORM fn_print('-- # -- ------------------------ -- # --');
    PERFORM fn_print('-- # -- ######## PART 3 ######## -- # --');
    PERFORM fn_print('-- # -- ------------------------ -- # --');
    PERFORM fn_print('');
    PERFORM fn_print('');

    PERFORM fn_print('-- # -- START TEST fn_print_human_readable_transferred_points -- # --');
    truncate TransferredPoints;

    INSERT INTO Peers VALUES('A', '2001-01-01');
    INSERT INTO Peers VALUES('B', '2002-01-01');
    INSERT INTO Peers VALUES('C', '2003-01-01');
    INSERT INTO Peers VALUES('D', '2003-01-01');

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'B', 1);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'B', 9);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'B', 8);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'B', 70);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'A' AND Peer2 = 'B';
--     RAISE NOTICE 'RES %', points;
    assert(points = 4);

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'A', 10);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'A', 9);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'A', 8);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'A', 70);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'A' AND Peer2 = 'B';
--     RAISE NOTICE 'RES %', points;
    assert(points = -9);

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'C', 110);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'C', 92);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'C', 0);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'C', 74);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'A' AND Peer2 = 'C';
--     RAISE NOTICE 'RES %', points;
    assert(points = 113);

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'D', 117);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'D', 73);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'D', 64);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'D', 35);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'B' AND Peer2 = 'D';
--     RAISE NOTICE 'RES %', points;
    assert(points = 120);

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'D', 'A', 97);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'D', 'A', 13);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'D', 'A', 14);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'D', 'A', 15);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'D' AND Peer2 = 'A';
--     RAISE NOTICE 'RES %', points;
    assert(points = 100);

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'C', 0);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'C', 73);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'C', 64);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'B' AND Peer2 = 'C';
--     RAISE NOTICE 'RES %', points;
    assert(points = 2);

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'C', 'B', 100);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'C', 'B', 73);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'C', 'B', 64);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'C' AND Peer2 = 'B';
    -- RAISE NOTICE 'RES %', points;
    assert(points = 100);


    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'A' AND Peer2 = 'B';
    --     RAISE NOTICE 'RES %', points;
    assert(points = -9);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'B' AND Peer2 = 'A';
    --     RAISE NOTICE 'RES %', points;
    assert(points = 9);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'A' AND Peer2 = 'C';
    --    RAISE NOTICE 'RES %', points;
    assert(points = 113);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'D' AND Peer2 = 'A';
    --   RAISE NOTICE 'RES %', points;
    assert(points = 100);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'B' AND Peer2 = 'C';
    --   RAISE NOTICE 'RES %', points;
    assert(points = -100);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'C' AND Peer2 = 'B';
    --   RAISE NOTICE 'RES %', points;
    assert(points = 100);

    -- -- -------------------------------------------- --

    truncate TransferredPoints CASCADE;

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'B', 1);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'B', 1);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'B', 1);

    -- RAISE NOTICE '3 * A -> B';

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'A' AND Peer2 = 'B';
    --   RAISE NOTICE 'RES %', points;
    -- RAISE NOTICE 'RES A - B = %', points;
    assert(points = 3);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'B' AND Peer2 = 'A';
    -- RAISE NOTICE 'RES B - A = %', points;
    assert(points is NULL);

    -- -------------------------------------------- --
    -- RAISE NOTICE '----';

    -- RAISE NOTICE 'A -> C';
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'C', 1);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'A' AND Peer2 = 'C';
    assert(points = 1);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'C' AND Peer2 = 'A';
    assert(points IS NULL);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'B' AND Peer2 = 'A';
    assert(points IS NULL);

    -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'C', 1);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'B' AND Peer2 = 'C';
    --   RAISE NOTICE 'RES %', points;
    -- RAISE NOTICE 'RES B - C = %', points;
    assert(points = 1);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'C' AND Peer2 = 'B';
    --   RAISE NOTICE 'RES %', points;
    -- RAISE NOTICE 'RES C - B = %', points;
    assert(points IS NULL);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'B' AND Peer2 = 'A';
    assert(points IS NULL);

    -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'C', 1);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'B' AND Peer2 = 'C';
    assert(points = 2);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'C' AND Peer2 = 'B';
    assert(points IS NULL);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'B' AND Peer2 = 'A';
    assert(points IS NULL);

    -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'A', 1);
    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'B' AND Peer2 = 'A';
    assert(points = -2);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'A' AND Peer2 = 'B';
    assert(points = 2);

    -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'C', 'A', 1);
    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'C' AND Peer2 = 'A';
    assert(points = 0);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'A' AND Peer2 = 'C';
    assert(points = 0);

    -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'C', 'A', 1);
    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'C' AND Peer2 = 'A';
    assert(points = 1);

    SELECT PointsAmount INTO points
    FROM fn_print_human_readable_transferred_points()
    WHERE Peer1 = 'A' AND Peer2 = 'C';
    assert(points = -1);

    -- -------------------------------------------- --

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_- fn_table_success_taks TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    n_count     INT := 0;
    id_check    INT := 0;
    peer        TEXT := '';
    task        TEXT := '';
    xp          BIGINT := 0;
BEGIN
    PERFORM fn_print('-- # -- START TEST fn_print_table_success_task -- # --');

    INSERT INTO Peers VALUES ('A', '1999-01-01');
    INSERT INTO Peers VALUES ('B', '1999-02-02');
    INSERT INTO Peers VALUES ('C', '1999-03-03');
    INSERT INTO Peers VALUES ('D', '1999-04-04');

    n_count = (SELECT COUNT(*) FROM XP);
    id_check = fn_next_id('Checks');
    INSERT INTO Checks VALUES(id_check, 'A', 'C2_SimpleBashUtils', '2022-01-01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), id_check, 'D', 'Start', '10:40:01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), id_check, 'D', 'Success', '11:10:32');
    INSERT INTO XP VALUES(fn_next_id('XP'), id_check, 250);

    SELECT * INTO peer, task, xp FROM fn_print_table_success_task() WHERE
        fn_print_table_success_task.Peer = 'A' AND
        fn_print_table_success_task.Task = 'C2_SimpleBashUtils';
--     RAISE NOTICE 'peer: %', peer;
--     RAISE NOTICE 'task: %', task;
--     RAISE NOTICE 'xp: %', xp;
    assert(peer = 'A');
    assert(task = 'C2_SimpleBashUtils');
    assert(xp = 250);
    assert((SELECT COUNT(*) FROM XP) = n_count + 1);

    -- -------------------------------------------- --

    id_check = fn_next_id('Checks');
    INSERT INTO Checks VALUES(id_check, 'B', 'C2_SimpleBashUtils', '2022-01-01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), id_check, 'D', 'Start', '13:40:01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), id_check, 'D', 'Success', '14:10:32');
    INSERT INTO XP VALUES(fn_next_id('XP'), id_check, 200);

    SELECT * INTO peer, task, xp FROM fn_print_table_success_task() WHERE
        fn_print_table_success_task.Peer = 'B' AND
        fn_print_table_success_task.Task = 'C2_SimpleBashUtils';
--     RAISE NOTICE 'peer: %', peer;
--     RAISE NOTICE 'task: %', task;
--     RAISE NOTICE 'xp: %', xp;
    assert(peer = 'B');
    assert(task = 'C2_SimpleBashUtils');
    assert(xp = 200);
    assert((SELECT COUNT(*) FROM XP) = n_count + 2);

    -- -------------------------------------------- --

    id_check = fn_next_id('Checks');
    INSERT INTO Checks VALUES(id_check, 'C', 'C2_SimpleBashUtils', '2022-01-01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), id_check, 'D', 'Start', '14:40:01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), id_check, 'D', 'Success', '15:10:32');
    INSERT INTO XP VALUES(fn_next_id('XP'), id_check, 180);

    SELECT * INTO peer, task, xp FROM fn_print_table_success_task() WHERE
        fn_print_table_success_task.Peer = 'C' AND
        fn_print_table_success_task.Task = 'C2_SimpleBashUtils';
--     RAISE NOTICE 'peer: %', peer;
--     RAISE NOTICE 'task: %', task;
--     RAISE NOTICE 'xp: %', xp;
    assert(peer = 'C');
    assert(task = 'C2_SimpleBashUtils');
    assert(xp = 180);
    assert((SELECT COUNT(*) FROM XP) = n_count + 3);

    -- -------------------------------------------- --

    id_check = fn_next_id('Checks');
    INSERT INTO Checks VALUES(id_check, 'A', 'C3_StringPlus', '2022-01-03');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), id_check, 'D', 'Start', '10:00:01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), id_check, 'D', 'Success', '11:00:32');
    INSERT INTO XP VALUES(fn_next_id('XP'), id_check, 500);

    SELECT * INTO peer, task, xp FROM fn_print_table_success_task() WHERE
        fn_print_table_success_task.Peer = 'A' AND
        fn_print_table_success_task.Task = 'C3_StringPlus';
    assert(peer = 'A');
    assert(task = 'C3_StringPlus');
    assert(xp = 500);
    assert((SELECT COUNT(*) FROM XP) = n_count + 4);
--     RAISE NOTICE 'peer: %', peer;
--     RAISE NOTICE 'task: %', task;
--     RAISE NOTICE 'xp: %', xp;

    -- -------------------------------------------- --

    id_check = fn_next_id('Checks');
    INSERT INTO Checks VALUES(id_check, 'B', 'C3_StringPlus', '2022-01-01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), id_check, 'D', 'Start', '13:40:01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), id_check, 'D', 'Failure', '14:10:32');
    INSERT INTO XP VALUES(fn_next_id('XP'), id_check, 400);

    SELECT * INTO peer, task, xp FROM fn_print_table_success_task() WHERE
        fn_print_table_success_task.Peer = 'B' AND
        fn_print_table_success_task.Task = 'C3_StringPlus';
--     RAISE NOTICE 'peer: %', peer;
--     RAISE NOTICE 'task: %', task;
--     RAISE NOTICE 'xp: %', xp;
    assert(peer IS NULL);
    assert(task IS NULL);
    assert(xp IS NULL);
    assert((SELECT COUNT(*) FROM XP) = n_count + 4);
    -- -------------------------------------------- --

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;

END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_- fn_peers_not_left_campus TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    peer TEXT := '';
BEGIN
    PERFORM fn_print('-- # -- START TEST fn_peers_not_left_campus -- # --');

    truncate TimeTracking cascade;

    INSERT INTO Peers VALUES ('A', '1999-01-01');
    INSERT INTO Peers VALUES ('B', '1999-02-02');
    INSERT INTO Peers VALUES ('C', '1999-03-03');
    INSERT INTO Peers VALUES ('D', '1999-04-04');

    -- -------------------------------------------- --


    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-01', '10:10:10', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-01', '12:20:10', 2);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-02', '00:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-02', '23:59:59', 2);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-03', '00:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-03', '23:59:58', 2);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-04', '00:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-05', '00:00:00', 2);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'B', '2022-01-05', '13:54:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'B', '2022-01-06', '19:40:55', 2);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-05', '09:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-06', '23:30:00', 2);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'B', '2022-01-07', '18:54:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'B', '2022-01-07', '19:10:55', 2);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-07', '00:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-07', '23:59:59', 2);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-08', '01:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-09', '23:59:59', 2);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'D', '2022-01-10', '00:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'D', '2022-01-10', '23:59:59', 2);


    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-11', '00:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-12', '20:59:59', 2);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'B', '2022-01-11', '02:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'B', '2022-01-12', '03:50:50', 2);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'D', '2022-01-11', '09:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'D', '2022-01-12', '01:09:09', 2);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-11', '23:59:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-12', '03:00:00', 2);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'D', '2022-01-13', '09:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'D', '2022-01-14', '01:09:09', 2);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-13', '23:59:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-14', '03:00:00', 2);

    -- -------------------------------------------- --

    SELECT fn_peers_not_left_campus.Peer INTO peer FROM fn_peers_not_left_campus('2022-01-01');
--     RAISE NOTICE 'RESULT [0] 2022-01-01:   %', peer;
    assert(peer IS NULL);

    SELECT fn_peers_not_left_campus.Peer INTO peer FROM fn_peers_not_left_campus('2022-01-02');
--     RAISE NOTICE 'RESULT [0] 2022-01-02:   %', peer;
    assert(peer IS NULL);

    SELECT fn_peers_not_left_campus.Peer INTO peer FROM fn_peers_not_left_campus('2022-01-03');
--     RAISE NOTICE 'RESULT [0] 2022-01-03:   %', peer;
    assert(peer IS NULL);

    SELECT fn_peers_not_left_campus.Peer INTO peer FROM fn_peers_not_left_campus('2022-01-04');
    -- RAISE NOTICE 'RESULT A [1] 2022-01-04: %', peer;
    assert(peer = 'A');

    SELECT fn_peers_not_left_campus.Peer INTO peer FROM fn_peers_not_left_campus('2022-01-05');
    assert(peer = 'B');

    SELECT fn_peers_not_left_campus.Peer INTO peer FROM fn_peers_not_left_campus('2022-01-07');
    -- RAISE NOTICE 'RESULT [0] 2022-01-06:   %', peer;
    assert(peer IS NULL);

    SELECT fn_peers_not_left_campus.Peer INTO peer FROM fn_peers_not_left_campus('2022-01-07');
    -- RAISE NOTICE 'RESULT [0] 2022-01-07:   %', peer;
    assert(peer IS NULL);

    SELECT fn_peers_not_left_campus.Peer INTO peer FROM fn_peers_not_left_campus('2022-01-08');
    -- RAISE NOTICE 'RESULT C [1] 2022-01-08: %', peer;
     assert(peer = 'C');

    SELECT fn_peers_not_left_campus.Peer INTO peer FROM fn_peers_not_left_campus('2022-01-09');
    -- RAISE NOTICE 'RESULT [0] 2022-01-09:   %', peer;
    assert(peer IS NULL);

    SELECT fn_peers_not_left_campus.Peer INTO peer FROM fn_peers_not_left_campus('2022-01-10');
    -- RAISE NOTICE 'RESULT [0] 2022-01-10:   %', peer;
    assert(peer IS NULL);

    -- RAISE NOTICE 'RESULT B, A [2]:         %', (SELECT COUNT(*) FROM fn_peers_not_left_campus('2022-01-11'));
    assert((SELECT COUNT(*) FROM fn_peers_not_left_campus('2022-01-11')) = 4);

    -- RAISE NOTICE 'RESULT B, A [2]:         %', (SELECT COUNT(*) FROM fn_peers_not_left_campus('2022-01-13'));
    assert((SELECT COUNT(*) FROM fn_peers_not_left_campus('2022-01-13')) = 2);

    -- -------------------------------------------- --

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;

END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_- pr_print_calculate_change_number_of_peer_points TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    ref refcursor := 'cursor';
    rec record;
BEGIN
    PERFORM fn_print('-- # -- START pr_print_calculate_change_number_of_peer_points TEST  -- # --');

    truncate TransferredPoints CASCADE;

    INSERT INTO Peers VALUES('A', '2002-01-01');
    INSERT INTO Peers VALUES('B', '2003-01-01');
    INSERT INTO Peers VALUES('C', '2004-01-01');

    CALL pr_print_calculate_change_number_of_peer_points('cursor');
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;
        assert(false);
    END LOOP;
    CLOSE ref;

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'B', 1);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'B', 1);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'B', 1);


    CALL pr_print_calculate_change_number_of_peer_points('cursor');
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Peer, rec.PointsChange;
        IF (rec.Peer = 'A' AND rec.PointsChange != 3) THEN
            assert(false);
        ELSEIF (rec.Peer = 'B' AND rec.PointsChange != -3) THEN
            assert(false);
        END IF;

    END LOOP;
    CLOSE ref;

    -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'C', 1);

    CALL pr_print_calculate_change_number_of_peer_points('cursor');
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Peer, rec.PointsChange;
        IF (rec.Peer = 'A' AND rec.PointsChange != 4) THEN
            assert(false);
        ELSEIF (rec.Peer = 'B' AND rec.PointsChange != -3) THEN
            assert(false);
        ELSEIF (rec.Peer = 'C' AND rec.PointsChange != -1) THEN
            assert(false);
        END IF;

    END LOOP;
    CLOSE ref;

    -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'C', 1);

    CALL pr_print_calculate_change_number_of_peer_points('cursor');
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Peer, rec.PointsChange;
        IF (rec.Peer = 'A' AND rec.PointsChange != 4) THEN
            assert(false);
        ELSEIF (rec.Peer = 'B' AND rec.PointsChange != -2) THEN
            assert(false);
        ELSEIF (rec.Peer = 'C' AND rec.PointsChange != -2) THEN
            assert(false);
        END IF;

    END LOOP;
    CLOSE ref;

    -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'C', 1);

    CALL pr_print_calculate_change_number_of_peer_points('cursor');
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Peer, rec.PointsChange;
        IF (rec.Peer = 'A' AND rec.PointsChange != 4) THEN
            assert(false);
        ELSEIF (rec.Peer = 'B' AND rec.PointsChange != -1) THEN
            assert(false);
        ELSEIF (rec.Peer = 'C' AND rec.PointsChange != -3) THEN
            assert(false);
        END IF;

    END LOOP;
    CLOSE ref;

    -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'A', 1);

    CALL pr_print_calculate_change_number_of_peer_points('cursor');
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Peer, rec.PointsChange;
        IF (rec.Peer = 'A' AND rec.PointsChange != 3) THEN
            assert(false);
        ELSEIF (rec.Peer = 'B' AND rec.PointsChange != 0) THEN
            assert(false);
        ELSEIF (rec.Peer = 'C' AND rec.PointsChange != -3) THEN
            assert(false);
        END IF;

    END LOOP;
    CLOSE ref;

    -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'C', 'A', 1);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'C', 'A', 1);

    CALL pr_print_calculate_change_number_of_peer_points('cursor');
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Peer, rec.PointsChange;
        IF (rec.Peer = 'A' AND rec.PointsChange != 1) THEN
            assert(false);
        ELSEIF (rec.Peer = 'B' AND rec.PointsChange != 0) THEN
            assert(false);
        ELSEIF (rec.Peer = 'C' AND rec.PointsChange != -1) THEN
            assert(false);
        END IF;

    END LOOP;
    CLOSE ref;


    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_- pr_calculate_change_number_peer_using_table TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    ref refcursor := 'cursor';
    rec record;
BEGIN
    PERFORM fn_print('-- # -- START TEST pr_calculate_change_number_peer_using_table -- # --');

    truncate TransferredPoints CASCADE;

    INSERT INTO Peers VALUES('A', '2002-01-01');
    INSERT INTO Peers VALUES('B', '2003-01-01');
    INSERT INTO Peers VALUES('C', '2004-01-01');

    CALL pr_calculate_change_number_peer_using_table('cursor');
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;
        assert(false);
    END LOOP;
    CLOSE ref;

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'B', 1);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'B', 1);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'B', 1);


    CALL pr_calculate_change_number_peer_using_table('cursor');
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Peer, rec.PointsChange;
        IF (rec.Peer = 'A' AND rec.PointsChange != 3) THEN
            assert(false);
        ELSEIF (rec.Peer = 'B' AND rec.PointsChange != -3) THEN
            assert(false);
        END IF;

    END LOOP;
    CLOSE ref;

    -- -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'A', 'C', 1);

    CALL pr_calculate_change_number_peer_using_table('cursor');
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Peer, rec.PointsChange;
        IF (rec.Peer = 'A' AND rec.PointsChange != 4) THEN
            assert(false);
        ELSEIF (rec.Peer = 'B' AND rec.PointsChange != -3) THEN
            assert(false);
        ELSEIF (rec.Peer = 'C' AND rec.PointsChange != -1) THEN
            assert(false);
        END IF;

    END LOOP;
    CLOSE ref;

    -- -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'C', 1);

    CALL pr_calculate_change_number_peer_using_table('cursor');
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Peer, rec.PointsChange;
        IF (rec.Peer = 'A' AND rec.PointsChange != 4) THEN
            assert(false);
        ELSEIF (rec.Peer = 'B' AND rec.PointsChange != -2) THEN
            assert(false);
        ELSEIF (rec.Peer = 'C' AND rec.PointsChange != -2) THEN
            assert(false);
        END IF;

    END LOOP;
    CLOSE ref;

    -- -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'C', 1);

    CALL pr_calculate_change_number_peer_using_table('cursor');
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Peer, rec.PointsChange;
        IF (rec.Peer = 'A' AND rec.PointsChange != 4) THEN
            assert(false);
        ELSEIF (rec.Peer = 'B' AND rec.PointsChange != -1) THEN
            assert(false);
        ELSEIF (rec.Peer = 'C' AND rec.PointsChange != -3) THEN
            assert(false);
        END IF;

    END LOOP;
    CLOSE ref;

    -- -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'B', 'A', 1);

    CALL pr_calculate_change_number_peer_using_table('cursor');
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Peer, rec.PointsChange;
        IF (rec.Peer = 'A' AND rec.PointsChange != 3) THEN
            assert(false);
        ELSEIF (rec.Peer = 'B' AND rec.PointsChange != 0) THEN
            assert(false);
        ELSEIF (rec.Peer = 'C' AND rec.PointsChange != -3) THEN
            assert(false);
        END IF;

    END LOOP;
    CLOSE ref;

    -- -------------------------------------------- --

    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'C', 'A', 1);
    INSERT INTO TransferredPoints VALUES(fn_next_id('TransferredPoints'), 'C', 'A', 1);

    CALL pr_calculate_change_number_peer_using_table('cursor');
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Peer, rec.PointsChange;
        IF (rec.Peer = 'A' AND rec.PointsChange != 1) THEN
            assert(false);
        ELSEIF (rec.Peer = 'B' AND rec.PointsChange != 0) THEN
            assert(false);
        ELSEIF (rec.Peer = 'C' AND rec.PointsChange != -1) THEN
            assert(false);
        END IF;

    END LOOP;
    CLOSE ref;

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

-- _-_-_-_-_- pr_recommendations_peers_friends TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    ref refcursor := 'cursor';
    rec record;
BEGIN
    PERFORM fn_print('-- # -- START TEST pr_recommendations_peers_friends -- # --');

    truncate Friends         CASCADE;
    truncate Recommendations CASCADE;

    INSERT into Peers VALUES('A', '1990-01-01');
    INSERT into Peers VALUES('B', '1991-01-01');
    INSERT into Peers VALUES('C', '1992-01-01');
    INSERT into Peers VALUES('D', '1993-01-01');
    INSERT into Peers VALUES('E', '1994-01-01');
    INSERT into Peers VALUES('F', '1995-01-01');

    INSERT INTO Friends VALUES (fn_next_id('Friends'), 'A', 'B');
    INSERT INTO Friends VALUES (fn_next_id('Friends'), 'A', 'C');

    CALL pr_recommendations_peers_friends(ref);

    LOOP
        fetch ref INTO rec;
        exit when not found;
        assert(false);
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO Recommendations VALUES(fn_next_id('Recommendations'), 'B', 'D');
    INSERT INTO Recommendations VALUES(fn_next_id('Recommendations'), 'C', 'D');
    INSERT INTO Recommendations VALUES(fn_next_id('Recommendations'), 'C', 'E');

    CALL pr_recommendations_peers_friends(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: Peer [%], RecommendedPeer [%]', rec.Peer, rec.RecommendedPeer;
        IF (rec.Peer = 'A' AND rec.RecommendedPeer = 'D') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO Recommendations VALUES(fn_next_id('Recommendations'), 'B', 'E');


    CALL pr_recommendations_peers_friends(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: Peer [%], RecommendedPeer [%]', rec.Peer, rec.RecommendedPeer;
        IF (rec.Peer = 'A' AND rec.RecommendedPeer = 'D') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO Friends VALUES (fn_next_id('Friends'), 'A', 'F');
    INSERT INTO Recommendations VALUES(fn_next_id('Recommendations'), 'F', 'E');

    CALL pr_recommendations_peers_friends(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: Peer [%], RecommendedPeer [%]', rec.Peer, rec.RecommendedPeer;
        IF (rec.Peer = 'A' AND rec.RecommendedPeer = 'D') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO Recommendations VALUES(fn_next_id('Recommendations'), 'A', 'F');

    CALL pr_recommendations_peers_friends(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: Peer [%], RecommendedPeer [%]', rec.Peer, rec.RecommendedPeer;
        IF (rec.Peer = 'A' AND rec.RecommendedPeer = 'D') THEN
            assert(true);
        ELSEIF (rec.Peer = 'B' AND rec.RecommendedPeer = 'F') THEN
            assert(true);
        ELSEIF (rec.Peer = 'C' AND rec.RecommendedPeer = 'F') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_- pr_peers_percent TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    startedblock1 real := 0;
    startedblock2 real := 0;
    startedbothblock real := 0;
    didntstartanyblock real := 0;
    n_count int := 0;
BEGIN
    PERFORM fn_print('-- # -- START TEST pr_peers_percent -- # --');

    truncate Checks CASCADE;
    truncate P2P CASCADE;
    truncate Peers CASCADE;

    INSERT INTO Peers VALUES('A', '2000-01-01');
    INSERT INTO Peers VALUES('B', '2000-01-02');
    INSERT INTO Peers VALUES('C', '2000-01-03');
    INSERT INTO Peers VALUES('D', '2000-01-04');

    CALL pr_peers_percent('C', 'DO', startedblock1, startedblock2, startedbothblock, didntstartanyblock);
--     RAISE NOTICE 'RESULT: % % % %', startedblock1, startedblock2, startedbothblock, didntstartanyblock;

    assert(startedblock1 = 0);
    assert(startedblock2 = 0);
    assert(startedbothblock = 0);
    assert(didntstartanyblock = 100);

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'B', 'C2_SimpleBashUtils', '2022-01-08');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Start', '11:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Success', '11:12:00');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 250);

    CALL pr_peers_percent('C', 'DO', startedblock1, startedblock2, startedbothblock, didntstartanyblock);

    assert(startedblock1 = 25);
    assert(startedblock2 = 0);
    assert(startedbothblock = 0);
    assert(didntstartanyblock = 75);
--     RAISE NOTICE 'RESULT:a->b c1   % % % %', startedblock1, startedblock2, startedbothblock, didntstartanyblock;

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'C2_SimpleBashUtils', '2022-01-08');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Start', '11:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Success', '11:12:00');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 250);
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'C3_StringPlus', '2022-02-08');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Start', '11:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Success', '11:12:00');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 500);
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    CALL pr_peers_percent('C', 'DO', startedblock1, startedblock2, startedbothblock, didntstartanyblock);
--     RAISE NOTICE 'RESULT:b->a c1   % % % %', startedblock1, startedblock2, startedbothblock, didntstartanyblock;

    assert(startedblock1 = 50);
    assert(startedblock2 = 0);
    assert(startedbothblock = 0);
    assert(didntstartanyblock = 50);

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'DO1_Linux', '2022-01-08');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Start', '10:10:00');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Success', '10:12:00');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    CALL pr_verter_check_add('A', 'DO1_Linux', 'Start', '13:51:11');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    CALL pr_verter_check_add('A', 'DO1_Linux', 'Success', '13:52:11');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 300);
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    CALL pr_peers_percent('C', 'DO', startedblock1, startedblock2, startedbothblock, didntstartanyblock);
--     RAISE NOTICE 'RESULT:b->a d1    % % % %', startedblock1, startedblock2, startedbothblock, didntstartanyblock;

    assert(startedblock1 = 25);
    assert(startedblock2 = 0);
    assert(startedbothblock = 25);
    assert(didntstartanyblock = 50);

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'DO2_LinuxNetwork', '2022-01-08');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Start', '10:10:00');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Success', '10:12:00');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    CALL pr_verter_check_add('A', 'DO2_LinuxNetwork', 'Start', '13:51:11');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    CALL pr_verter_check_add('A', 'DO2_LinuxNetwork', 'Success', '13:52:11');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 250);
    get diagnostics n_count = row_count;
    assert(n_count = 1);


    CALL pr_peers_percent('C', 'DO', startedblock1, startedblock2, startedbothblock, didntstartanyblock);
    -- RAISE NOTICE 'RESULT:b->a d2    % % % %', startedblock1, startedblock2, startedbothblock, didntstartanyblock;

    assert(startedblock1 = 25);
    assert(startedblock2 = 0);
    assert(startedbothblock = 25);
    assert(didntstartanyblock = 50);

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'DO3_LinuxMonitoring_v1.0', '2022-01-08');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Start', '10:10:00');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Success', '10:12:00');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    CALL pr_verter_check_add('A', 'DO3_LinuxMonitoring_v1.0', 'Start', '13:51:11');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    CALL pr_verter_check_add('A', 'DO3_LinuxMonitoring_v1.0', 'Success', '13:52:11');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 350);
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    CALL pr_peers_percent('C', 'DO', startedblock1, startedblock2, startedbothblock, didntstartanyblock);
--     RAISE NOTICE 'RESULT:b->a d3     % % % %', startedblock1, startedblock2, startedbothblock, didntstartanyblock;

    assert(startedblock1 = 25);
    assert(startedblock2 = 0);
    assert(startedbothblock = 25);
    assert(didntstartanyblock = 50);

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'B', 'C3_StringPlus', '2022-02-08');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Start', '11:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Success', '11:12:00');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 500);
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'B', 'DO1_Linux', '2022-01-08');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Start', '10:10:00');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Success', '10:12:00');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    CALL pr_verter_check_add('B', 'DO1_Linux', 'Start', '13:51:11');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    CALL pr_verter_check_add('B', 'DO1_Linux', 'Success', '13:52:11');
    get diagnostics n_count = row_count;
    assert(n_count = 1);
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 300);
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    CALL pr_peers_percent('C', 'DO', startedblock1, startedblock2, startedbothblock, didntstartanyblock);
--     RAISE NOTICE 'RESULT:a->b d1    % % % %', startedblock1, startedblock2, startedbothblock, didntstartanyblock;

    assert(startedblock1 = 0);
    assert(startedblock2 = 0);
    assert(startedbothblock = 50);
    assert(didntstartanyblock = 50);

    -- -------------------------------------------- --

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_- pr_daily_most_checked_task TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    n_count         INT := 0;
    ref refcursor := 'cursor';
    rec record;
BEGIN
    PERFORM fn_print('-- # -- START TEST pr_daily_most_checked_task -- # --');

    truncate Checks CASCADE;

    INSERT INTO Peers VALUES('A', '2000-01-01');
    INSERT INTO Peers VALUES('B', '2000-01-01');
    INSERT INTO Peers VALUES('C', '2000-02-02');
    INSERT INTO Peers VALUES('D', '2000-03-03');

    CALL pr_daily_most_checked_task(ref);

    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;
        assert(false);
    END LOOP;
    CLOSE ref;

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'C2_SimpleBashUtils', '2023-01-01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Start', '10:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Success', '10:12:00');

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'C3_StringPlus', '2023-01-02');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Start', '12:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Success', '12:12:00');

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'B', 'C2_SimpleBashUtils', '2023-01-02');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Start', '18:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Success', '18:12:00');

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'C', 'C2_SimpleBashUtils', '2023-01-02');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Start', '19:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Success', '19:12:00');


    CALL pr_daily_most_checked_task(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;
--
        -- RAISE NOTICE 'RESULT: % %', rec.Day, rec.Task;
        IF (rec.Day = '2023-01-01' AND rec.Task = 'C2_SimpleBashUtils') THEN
            assert(true);
        ELSEIF (rec.Day = '2023-01-02' AND rec.Task = 'C2_SimpleBashUtils') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    CLOSE ref;

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'D', 'C2_SimpleBashUtils', '2023-01-01');
    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'B', 'C3_StringPlus', '2023-01-02');
    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'C', 'C3_StringPlus', '2023-01-02');
    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'D', 'C3_StringPlus', '2023-01-02');
--
    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'D', 'C2_SimpleBashUtils', '2023-01-01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Start', '10:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Success', '10:12:00');

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'B', 'C3_StringPlus', '2023-01-02');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Start', '10:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Success', '10:12:00');

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'C', 'C3_StringPlus', '2023-01-02');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Start', '10:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Success', '10:12:00');

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'D', 'C3_StringPlus', '2023-01-02');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Start', '10:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Success', '10:12:00');


    CALL pr_daily_most_checked_task(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

        -- RAISE NOTICE 'RESULT: % %', rec.Day, rec.Task;
        IF (rec.Day = '2023-01-01' AND rec.Task = 'C2_SimpleBashUtils') THEN
            assert(true);
        ELSEIF (rec.Day = '2023-01-02' AND rec.Task = 'C3_StringPlus') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    CLOSE ref;

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_- pr_peers_completed_block TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    ref refcursor := 'cursor';
    rec record;
    id_check BIGINT := 0;
BEGIN
    PERFORM fn_print('-- # -- START TEST pr_peers_completed_block -- # --');


    truncate P2P CASCADE;
    truncate Checks CASCADE;
    truncate Peers CASCADE;

    INSERT INTO Peers VALUES('A', '2000-01-01');
    INSERT INTO Peers VALUES('B', '2002-02-02');

    CALL pr_peers_completed_block('C2_SimpleBashUtils', ref);

    LOOP
        fetch ref INTO rec;
        exit when not found;
        assert(false);
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'C2_SimpleBashUtils', '2022-01-08');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Start', '10:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Success', '10:12:00');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 250);

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'C3_StringPlus', '2022-01-08');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Start', '11:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Success', '11:12:00');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 250);

    CALL pr_peers_completed_block('C', ref);
    LOOP
        fetch ref INTO rec;
        exit when not found;
        assert(false);
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'B', 'C2_SimpleBashUtils', '2022-01-08');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Start', '11:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Success', '11:12:00');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 250);

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'B', 'C3_StringPlus', '2022-01-08');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Start', '11:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'A', 'Success', '11:12:00');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 250);

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'DO1_Linux', '2022-01-08');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Start', '10:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Success', '10:12:00');
    CALL pr_verter_check_add('A', 'DO2_LinuxNetwork', 'Start', '13:51:11');
    CALL pr_verter_check_add('A', 'DO2_LinuxNetwork', 'Success', '13:52:11');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 300);

    CALL pr_peers_completed_block('DO', ref);
    LOOP
        fetch ref INTO rec;
        exit when not found;
        assert(false);
    END LOOP;
    close ref;

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'DO2_LinuxNetwork', '2022-02-08');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Start', '10:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Success', '10:12:00');
    CALL pr_verter_check_add('A', 'DO2_LinuxNetwork', 'Start', '13:51:11');
    CALL pr_verter_check_add('A', 'DO2_LinuxNetwork', 'Success', '13:52:11');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 350);

    CALL pr_peers_completed_block('DO', ref);
    LOOP
        fetch ref INTO rec;
        exit when not found;
        assert(false);
    END LOOP;
    close ref;
--
    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'DO3_LinuxMonitoring_v1.0', '2022-02-08');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Start', '10:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), fn_max_id('Checks'), 'B', 'Success', '10:12:00');
    CALL pr_verter_check_add('A', 'DO3_LinuxMonitoring_v1.0', 'Start', '13:51:11');
    CALL pr_verter_check_add('A', 'DO3_LinuxMonitoring_v1.0', 'Success', '13:52:11');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 300);

    CALL pr_peers_completed_block('DO', ref);
    LOOP
        fetch ref INTO rec;
        exit when not found;

--         RAISE NOTICE 'RESULT: % %', rec.Peer, rec.Day;
        IF (rec.Peer = 'A' AND rec.Day = '2022-02-08') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_- pr_percentage_peers_have_success_birthday TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    ref refcursor := 'cursor';
    rec record;
    check_id BIGINT := 0;
BEGIN
    PERFORM fn_print('-- # -- START TEST pr_percentage_peers_have_success_birthday -- # --');

    truncate Verter CASCADE;
    truncate P2P CASCADE;
    truncate Checks CASCADE;
    truncate Peers CASCADE;

    INSERT into Peers VALUES('A', '1995-01-01');
    INSERT into Peers VALUES('B', '1996-01-05');
    INSERT into Peers VALUES('C', '1996-01-06');

    check_id = fn_next_id('Checks');
    INSERT INTO Checks VALUES(check_id, 'A', 'C2_SimpleBashUtils', '2023-01-01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), check_id, 'B', 'Start', '10:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), check_id, 'B', 'Failure', '10:12:00');

    check_id = fn_next_id('Checks');
    INSERT INTO Checks VALUES(check_id, 'B', 'C2_SimpleBashUtils', '2023-01-05');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), check_id, 'A', 'Start', '10:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), check_id, 'A', 'Failure', '10:12:00');

    -- -------------------------------------------- --

    CALL pr_percentage_peers_have_success_birthday(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: SuccessfulChecks [%], UnsuccessfulChecks [%]', rec.SuccessfulChecks, rec.UnsuccessfulChecks;
        assert(rec.SuccessfulChecks = 0);
        assert(rec.UnsuccessfulChecks = 100);
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    check_id = fn_next_id('Checks');
    INSERT INTO Checks VALUES(check_id, 'C', 'C2_SimpleBashUtils', '2023-01-06');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), check_id, 'A', 'Start', '10:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), check_id, 'A', 'Success', '10:12:00');

    CALL pr_percentage_peers_have_success_birthday(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: SuccessfulChecks [%], UnsuccessfulChecks [%]', rec.SuccessfulChecks, rec.UnsuccessfulChecks;
        assert(rec.SuccessfulChecks = 33);
        assert(rec.UnsuccessfulChecks = 67);
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    check_id = fn_next_id('Checks');
    INSERT INTO Checks VALUES(check_id, 'C', 'C3_StringPlus', '2023-01-01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), check_id, 'A', 'Start', '10:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), check_id, 'A', 'Failure', '10:12:00');

    CALL pr_percentage_peers_have_success_birthday(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: SuccessfulChecks [%], UnsuccessfulChecks [%]', rec.SuccessfulChecks, rec.UnsuccessfulChecks;
        assert(rec.SuccessfulChecks = 33);
        assert(rec.UnsuccessfulChecks = 67);
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    check_id = fn_next_id('Checks');
    INSERT INTO Checks VALUES(check_id, 'A', 'C2_SimpleBashUtils', '2023-01-01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), check_id, 'B', 'Start', '10:10:00');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), check_id, 'B', 'Success', '10:12:00');

    CALL pr_percentage_peers_have_success_birthday(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: SuccessfulChecks [%], UnsuccessfulChecks [%]', rec.SuccessfulChecks, rec.UnsuccessfulChecks;
        assert(rec.SuccessfulChecks = 50);
        assert(rec.UnsuccessfulChecks = 50);
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_- pr_all_peers_who_did_given_1_2_not_3 TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    ref refcursor := 'cursor';
    rec record;

BEGIN
    PERFORM fn_print('-- # -- START TEST pr_all_peers_who_did_given_1_2_not_3 -- # --');

    truncate Verter CASCADE;
    truncate P2P CASCADE;
    truncate Checks CASCADE;
    truncate Peers CASCADE;

    INSERT into Peers VALUES('A', '1990-01-01');
    INSERT into Peers VALUES('B', '1991-01-01');
    INSERT into Peers VALUES('C', '1992-01-01');
    INSERT into Peers VALUES('D', '1993-01-01');
    INSERT into Peers VALUES('E', '1994-01-01');
    INSERT into Peers VALUES('F', '1995-01-01');

    CALL pr_all_peers_who_did_given_1_2_not_3('C2_SimpleBashUtils',
        'C3_StringPlus',
        'C4_Math',
        ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;
        assert(false);
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'C2_SimpleBashUtils', '2020-01-01');
    CALL pr_all_peers_who_did_given_1_2_not_3('C2_SimpleBashUtils',
        'C3_StringPlus',
        'C4_Math',
        ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;
        assert(false);
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'DO1_Linux', '2020-01-01');
    CALL pr_all_peers_who_did_given_1_2_not_3('C2_SimpleBashUtils',
        'C3_StringPlus',
        'C4_Math',
        ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;
        assert(false);
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'A', 'C3_StringPlus', '2020-01-01');
    CALL pr_all_peers_who_did_given_1_2_not_3('C2_SimpleBashUtils',
        'C3_StringPlus',
        'C4_Math',
        ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: %', rec.Peer;
        IF (rec.Peer = 'A') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'B', 'C2_SimpleBashUtils', '2020-01-01');
    CALL pr_all_peers_who_did_given_1_2_not_3('C2_SimpleBashUtils',
        'C3_StringPlus',
        'C4_Math',
        ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: %', rec.Peer;
        IF (rec.Peer = 'A') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'B', 'C3_StringPlus', '2020-01-01');
    CALL pr_all_peers_who_did_given_1_2_not_3('C2_SimpleBashUtils',
        'C3_StringPlus',
        'C4_Math',
        ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: %', rec.Peer;
        IF (rec.Peer = 'A') THEN
            assert(true);
        ELSEIF (rec.Peer = 'B') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(fn_next_id('Checks'), 'B', 'C4_Math', '2020-01-01');
    CALL pr_all_peers_who_did_given_1_2_not_3('C2_SimpleBashUtils',
        'C3_StringPlus',
        'C4_Math',
        ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: %', rec.Peer;
        IF (rec.Peer = 'A') THEN
            assert(true);
        ELSEIF (rec.Peer = 'B') THEN
            assert(false);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_- pr_num_previous_tasks TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    ref refcursor := 'cursor';
    rec record;
    n_count INT := 0;
BEGIN
    PERFORM fn_print('-- # -- START TEST pr_num_previous_tasks -- # --');

    RAISE NOTICE 'BEGIN';
    CALL pr_num_previous_tasks(ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Title, rec.Max;
        IF (rec.Title = 'C1_SimpleBashUtil' AND rec.Max = '0') THEN
            assert(false);
        ELSEIF (rec.Title = 'DO1_Linux' AND rec.Max != '2') THEN
            assert(false);
        ELSEIF (rec.Title = 'C3_StringPlus' AND rec.Max != '1') THEN
            assert(false);
        ELSEIF (rec.Title = 'C4_Math' AND rec.Max != '2') THEN
            assert(false);
        ELSEIF (rec.Title = 'DO2_LinuxNetwork' AND rec.Max != '3') THEN
            assert(false);
        ELSEIF (rec.Title = 'DO3_LinuxMonitoring_v1.0' AND rec.Max != '4') THEN
            assert(false);
        ELSEIF (rec.Title = 'C5_Decimal' AND rec.Max != '3') THEN
            assert(false);
        ELSEIF (rec.Title = 'C6_Matrix' AND rec.Max != '4') THEN
            assert(false);
        ELSEIF (rec.Title = 'C7_SmartCalc_v1.0' AND rec.Max != '5') THEN
            assert(false);
        ELSEIF (rec.Title = 'C8_3DViewer_v1.0' AND rec.Max != '6') THEN
            assert(false);
        ELSEIF (rec.Title = 'CPP1_MatrixPlus' AND rec.Max != '7') THEN
            assert(false);
        ELSEIF (rec.Title = 'CPP2_Containers' AND rec.Max != '8') THEN
            assert(false);
        ELSEIF (rec.Title = 'CPP3_SmartCalc_v2.0' AND rec.Max != '9') THEN
            assert(false);
        ELSEIF (rec.Title = 'CPP4_3DViewer_v2.0' AND rec.Max != '10') THEN
            assert(false);
        ELSEIF (rec.Title = 'SQL1_SQL_Boot_camp' AND rec.Max != '7') THEN
            assert(false);
        ELSEIF (rec.Title = 'A1_Maze' AND rec.Max != '11') THEN
            assert(false);
        ELSEIF (rec.Title = 'A2_SimpleNavigator_v1.0' AND rec.Max != '12') THEN
            assert(false);
        END IF;

    END LOOP;
    close ref;

    -- -------------------------------------------- --

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_- pr_arrive_earlier_m_times TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    ref refcursor := 'cursor';
    rec record;
    n_count INT := 0;
BEGIN
    PERFORM fn_print('-- # -- START TEST pr_arrive_earlier_m_times -- # --');

    truncate TimeTracking CASCADE;

    INSERT into Peers VALUES('A', '1990-01-01');
    INSERT into Peers VALUES('B', '1991-01-01');
    INSERT into Peers VALUES('C', '1992-01-01');
    INSERT into Peers VALUES('D', '1993-01-01');
    INSERT into Peers VALUES('E', '1994-01-01');
    INSERT into Peers VALUES('F', '1995-01-01');

    CALL pr_arrive_earlier_m_times('12:00:00', 1, ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;
        assert(false);
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-01', '09:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-01', '10:00:00', 2);

    CALL pr_arrive_earlier_m_times('12:00:00', 1, ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: %', rec.Peer;
        IF (rec.Peer = 'A') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    CALL pr_arrive_earlier_m_times('12:00:00', 2, ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;
        assert(false);

    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-02', '09:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-02', '10:00:00', 2);

    CALL pr_arrive_earlier_m_times('12:00:00', 2, ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: %', rec.Peer;
        IF (rec.Peer = 'A') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    -- -------------------------------------------- --
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-02', '09:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-02', '10:00:00', 2);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-02', '11:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-02', '12:00:00', 2);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-02', '13:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-02', '14:00:00', 2);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-02', '15:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-02', '16:00:00', 2);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-02', '17:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-01-02', '18:00:00', 2);

    CALL pr_arrive_earlier_m_times('15:00:00', 3, ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: %', rec.Peer;
        IF (rec.Peer = 'C') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    CALL pr_arrive_earlier_m_times('19:00:00', 5, ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: %', rec.Peer;
        IF (rec.Peer = 'C') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_- pr_lucky_days_for_checks TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    ref refcursor := 'cursor';
    rec record;
    n_count INT := 0;
BEGIN
    PERFORM fn_print('-- # -- START TEST pr_lucky_days_for_checks -- # --');

    -- -------------------------------------------- --

    truncate Peers CASCADE;
    truncate Checks CASCADE;
    truncate Verter CASCADE;
    truncate P2P CASCADE;

    INSERT INTO Peers VALUES('A', '2000-01-01');
    INSERT INTO Peers VALUES('B', '2002-02-02');

    CALL pr_lucky_days_for_checks(1, ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;
        assert(false);
    END LOOP;
    close ref;

    -- -------------------------------------------- --


    INSERT INTO Checks VALUES(1, 'A', 'C2_SimpleBashUtils', '2022-01-01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), 1, 'B', 'Start', '10:40:01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), 1, 'B', 'Success', '11:10:32');

    INSERT INTO XP VALUES (1, 1, 30);


    CALL pr_lucky_days_for_checks(1, ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;
        assert(false);
    END LOOP;
    close ref;

    -- -------------------------------------------- --


    INSERT INTO Checks VALUES(2, 'A', 'C2_SimpleBashUtils', '2022-01-02');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO P2P VALUES(fn_next_id('P2P'), 2, 'B', 'Start', '10:40:01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO P2P VALUES(fn_next_id('P2P'), 2, 'B', 'Success', '11:10:32');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO XP VALUES (2, 2, 250);
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    CALL pr_lucky_days_for_checks(1, ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: %', rec.Data;
        IF (rec.Data = '2022-01-02') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;

    END LOOP;
    close ref;

    -- -------------------------------------------- --
-- C3_StringPlus
-- C4_Math

    INSERT INTO Checks VALUES(3, 'A', 'C3_StringPlus', '2022-01-03');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), 3, 'B', 'Start', '10:40:01');
    INSERT INTO P2P VALUES(fn_next_id('P2P'), 3, 'B', 'Success', '11:10:32');
    INSERT INTO XP VALUES (3, 3, 400);
    get diagnostics n_count = row_count;
    assert(n_count = 1);


    INSERT INTO Checks VALUES(4, 'B', 'C2_SimpleBashUtils', '2022-02-02');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO P2P VALUES(fn_next_id('P2P'), 4, 'A', 'Start', '11:40:01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO P2P VALUES(fn_next_id('P2P'), 4, 'A', 'Success', '12:10:32');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO XP VALUES (4, 4, 250);
    get diagnostics n_count = row_count;
    assert(n_count = 1);


    CALL pr_lucky_days_for_checks(2, ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: %', rec.Data;
        IF (rec.Data = '2022-01-03') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;

    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(5, 'B', 'C3_StringPlus', '2022-04-02');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO P2P VALUES(fn_next_id('P2P'), 5, 'A', 'Start', '11:40:01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO P2P VALUES(fn_next_id('P2P'), 5, 'A', 'Success', '12:10:32');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO XP VALUES (5, 5, 450);
    get diagnostics n_count = row_count;
    assert(n_count = 1);


    CALL pr_lucky_days_for_checks(2, ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: %', rec.Data;
        IF (rec.Data = '2022-01-03') THEN
            assert(true);
        ELSEIF (rec.Data = '2022-04-02') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;

    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO Checks VALUES(6, 'B', 'C4_Math', '2022-04-12');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO P2P VALUES(fn_next_id('P2P'), 6, 'A', 'Start', '11:40:01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO P2P VALUES(fn_next_id('P2P'), 6, 'A', 'Success', '12:10:32');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO XP VALUES (6, 6, 280);
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    CALL pr_lucky_days_for_checks(3, ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: %', rec.Data;
        IF (rec.Data = '2022-04-12') THEN
        ELSE
            assert(false);
        END IF;

    END LOOP;
    close ref;

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_- pr_peer_max_xp TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    ref refcursor := 'cursor';
    rec record;
    n_count INT := 0;
BEGIN
    PERFORM fn_print('-- # -- START TEST pr_peer_max_xp -- # --');

    truncate TransferredPoints CASCADE;
    truncate Checks CASCADE;
    truncate Peers CASCADE;

    INSERT INTO Peers VALUES('A', '2000-01-01');
    INSERT INTO Peers VALUES('B', '2000-02-02');
    INSERT INTO Peers VALUES('C', '2000-03-03');
    INSERT INTO Peers VALUES('D', '2000-04-04');

--     -- -------------------------------------------- --

    CALL pr_p2p_check_add('A', 'B', 'C2_SimpleBashUtils', 'Start', '01:00:00');
    CALL pr_p2p_check_add('A', 'B', 'C2_SimpleBashUtils', 'Success', '01:10:00');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 240);

    CALL pr_p2p_check_add('B', 'A', 'C2_SimpleBashUtils', 'Start', '01:00:00');
    CALL pr_p2p_check_add('B', 'A', 'C2_SimpleBashUtils', 'Success', '01:10:00');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 230);

    CALL pr_p2p_check_add('D', 'C', 'C2_SimpleBashUtils', 'Start', '01:00:00');
    CALL pr_p2p_check_add('D', 'C', 'C2_SimpleBashUtils', 'Success', '01:10:00');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 240);

    CALL pr_peer_max_xp(ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;

        -- RAISE NOTICE 'RESULT: % %', rec.Peer, rec.XP;
        IF (rec.Peer = 'A' AND rec.XP = '240') THEN
            assert(true);
        ELSEIF (rec.Peer = 'D' AND rec.XP = '240') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;

    END LOOP;
    close ref;

    -- -------------------------------------------- --

    CALL pr_p2p_check_add('A', 'B', 'C3_StringPlus', 'Start', '01:00:00');
    CALL pr_p2p_check_add('A', 'B', 'C3_StringPlus', 'Success', '01:10:00');
    CALL pr_verter_check_add('A', 'C3_StringPlus', 'Start', '13:51:11');
    CALL pr_verter_check_add('A', 'C3_StringPlus', 'Success', '13:52:11');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 480);

    CALL pr_peer_max_xp(ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;

        -- RAISE NOTICE 'RESULT: % %', rec.Peer, rec.XP;
        IF (rec.Peer = 'A' AND rec.XP = '720') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;

    END LOOP;
    close ref;

    -- -------------------------------------------- --

    CALL pr_p2p_check_add('B', 'D', 'C3_StringPlus', 'Start', '01:00:00');
    CALL pr_p2p_check_add('B', 'D', 'C3_StringPlus', 'Success', '01:10:00');
    CALL pr_verter_check_add('B', 'C3_StringPlus', 'Start', '13:51:11');
    CALL pr_verter_check_add('B', 'C3_StringPlus', 'Success', '13:52:11');
    INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 500);

    CALL pr_peer_max_xp(ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;

        -- RAISE NOTICE 'RESULT: % %', rec.Peer, rec.XP;
        IF (rec.Peer = 'B' AND rec.XP = '730') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;

    END LOOP;
    close ref;

    -- -------------------------------------------- --

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_- pr_peers_left_campus TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    ref refcursor := 'cursor';
    rec record;
    n_count INT := 0;
BEGIN
    PERFORM fn_print('-- # -- START TEST pr_peers_left_campus -- # --');

    TRUNCATE TimeTracking cascade;

    INSERT INTO Peers VALUES('A', '2000-01-01');
    INSERT INTO Peers VALUES('B', '2000-02-02');
    INSERT INTO Peers VALUES('C', '2000-03-03');
    INSERT INTO Peers VALUES('D', '2000-04-04');

    CALL pr_peers_left_campus(1, 10, ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;
        assert(false);
    END LOOP;
    close ref;

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', CURRENT_DATE - '3 days'::interval, '12:00:00', 1);

    CALL pr_peers_left_campus(3, 1, ref);
    LOOP
        fetch ref INTO rec;
        exit WHEN NOT found;
        assert(false);
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', CURRENT_DATE - '3 days'::interval, '13:11:00', 2);

    CALL pr_peers_left_campus(3, 1, ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'Peer: %', rec.Peer;
        IF (rec.Peer = 'A') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

--     -- -------------------------------------------- --

    CALL pr_peers_left_campus(2, 1, ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;
        assert(false);

    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', CURRENT_DATE - '2 days'::interval, '16:11:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', CURRENT_DATE - '2 days'::interval, '16:31:40', 2);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'B', CURRENT_DATE - '2 days'::interval, '16:11:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'B', CURRENT_DATE - '2 days'::interval, '16:31:40', 2);

    CALL pr_peers_left_campus(2, 1, ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'Peer: %', rec.Peer;
        IF (rec.Peer = 'A') THEN
            assert(true);
        ELSEIF (rec.Peer = 'B') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    CALL pr_peers_left_campus(1, 1, ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'Peer: %', rec.Peer;
        IF (rec.Peer = 'A') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

--     -- -------------------------------------------- --

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', CURRENT_DATE - '5 days'::interval, '16:11:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', CURRENT_DATE - '5 days'::interval, '16:31:40', 2);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'D', CURRENT_DATE - '6 days'::interval, '16:11:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'D', CURRENT_DATE - '6 days'::interval, '16:31:40', 2);

    -- -------------------------------------------- --

    CALL pr_peers_left_campus(6, 1, ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'Peer: %', rec.Peer;
        IF (rec.Peer = 'A') THEN
            assert(true);
        ELSEIF (rec.Peer = 'B') THEN
            assert(true);
        ELSEIF (rec.Peer = 'C') THEN
            assert(true);
        ELSEIF (rec.Peer = 'D') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    CALL pr_peers_left_campus(3, 2, ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'Peer: %', rec.Peer;
        IF (rec.Peer = 'A') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'B', CURRENT_DATE - '3 days'::interval, '18:11:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'B', CURRENT_DATE - '3 days'::interval, '18:31:40', 2);

    CALL pr_peers_left_campus(3, 2, ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'Peer: %', rec.Peer;
        IF (rec.Peer = 'A') THEN
            assert(true);
        ELSEIF (rec.Peer = 'B') THEN
            assert(true);
        ELSE
            assert(false);
        END IF;
    END LOOP;
    close ref;

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;

--_-_-_-_-_- pr_percent_earlier_arrive TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    ref refcursor := 'cursor';
    rec record;
    n_count INT := 0;
BEGIN
    PERFORM fn_print('-- # -- START TEST pr_percent_earlier_arrive -- # --');

    TRUNCATE TimeTracking cascade;

    INSERT INTO Peers VALUES('A', '2000-01-01');
    INSERT INTO Peers VALUES('B', '2000-02-02');
    INSERT INTO Peers VALUES('C', '1991-03-08');
    INSERT INTO Peers VALUES('D', '2000-04-04');

    CALL pr_percent_earlier_arrive(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;
        assert(false);
    END LOOP;
    close ref;

    -- -------------------------------------------- --

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-01', '07:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'A', '2022-01-01', '08:00:00', 1);

    CALL pr_percent_earlier_arrive(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Month, rec.EarlyEntries;
        IF (rec.Month = 'January' AND rec.EarlyEntries = 100) THEN
            assert(true);
        ELSE
            assert(false);
        END IF;

    END LOOP;
    close ref;

--     RAISE NOTICE '---------';

    -- -------------------------------------------- --

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'B', '2022-02-01', '07:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'B', '2022-02-01', '08:00:00', 1);

    CALL pr_percent_earlier_arrive(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Month, rec.EarlyEntries;
        IF (rec.Month = 'January' AND rec.EarlyEntries = 100) THEN
            assert(true);
        ELSEIF (rec.Month = 'February' AND rec.EarlyEntries = 100) THEN
            assert(true);
        ELSE
            assert(false);
        END IF;

    END LOOP;
    close ref;

--     RAISE NOTICE '---------';

    -- -------------------------------------------- --

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-03-01', '07:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'C', '2022-03-01', '08:00:00', 1);

    CALL pr_percent_earlier_arrive(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Month, rec.EarlyEntries;
        IF (rec.Month = 'January' AND rec.EarlyEntries = 100) THEN
            assert(true);
        ELSEIF (rec.Month = 'February' AND rec.EarlyEntries = 100) THEN
            assert(true);
        ELSEIF (rec.Month = 'March' AND rec.EarlyEntries = 100) THEN
            assert(true);
        ELSE
            assert(false);
        END IF;

    END LOOP;
    close ref;

--     RAISE NOTICE '---------';
    -- -------------------------------------------- --

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'D', '2022-04-01', '07:00:00', 1);
    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'D', '2022-04-01', '08:00:00', 1);

    CALL pr_percent_earlier_arrive(ref);
    LOOP
        FETCH ref INTO rec;
        exit WHEN NOT found;

--         RAISE NOTICE 'RESULT: % %', rec.Month, rec.EarlyEntries;
        IF (rec.Month = 'January' AND rec.EarlyEntries = 100) THEN
            assert(true);
        ELSEIF (rec.Month = 'February' AND rec.EarlyEntries = 100) THEN
            assert(true);
        ELSEIF (rec.Month = 'March' AND rec.EarlyEntries = 100) THEN
            assert(true);
        ELSEIF (rec.Month = 'April' AND rec.EarlyEntries = 100) THEN
            assert(true);
        ELSE
            assert(false);
        END IF;

    END LOOP;
    close ref;

    -- -------------------------------------------- --

    PERFORM fn_print('                    -- [ OK ] --');
    RAISE NOTICE '%', CURRENT_TIME;
END;
$$ language plpgsql;
ROLLBACK;
