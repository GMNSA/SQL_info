\i utils/umain_helps.sql

--_-_-_-_-_- trg_timetracking_insert TEST -_-_-_-_-_-_ --

BEGIN;
DO $$
DECLARE
    n_count int := 0;
BEGIN
    PERFORM fn_print('-- # -- ------------------------ -- # --');
    PERFORM fn_print('-- # -- ######## PART 1 ######## -- # --');
    PERFORM fn_print('-- # -- ------------------------ -- # --');
    PERFORM fn_print('');
    PERFORM fn_print('');

    PERFORM fn_print('-- # -- START TEST trg_timetracking_insert -- # --');

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Deghayra', '2023-01-01', '10:10:10', 1);
    get diagnostics n_count = row_count;
--     RAISE NOTICE 'Добавлено % строк', n_count;
    assert(n_count = 1);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Deghayra', '2023-01-01', '10:15:12', 1);
    get diagnostics n_count = row_count;

    assert(n_count = 0);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Deghayra', '2023-01-01', '10:15:12', 2);
    get diagnostics n_count = row_count;

    assert(n_count = 1);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Deghayra', '2023-01-01', '10:15:12', 2);
    get diagnostics n_count = row_count;

    assert(n_count = 0);


    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Deghayra', '2023-01-01', '11:15:12', 2);
    get diagnostics n_count = row_count;

    assert(n_count = 0);

    PERFORM fn_print('                    -- [ OK ] --');
END;
$$ language plpgsql;
ROLLBACK;

-- RECCOMENDATION TEST-------------------------------------------- --

BEGIN;
DO $$
DECLARE
    n_count int := 0;
    user1 TEXT := 'eviadann';
    user2 TEXT := 'jackscan';
BEGIN
    PERFORM fn_print('-- # -- START TEST trg_recommendations_insert -- # --');

    INSERT INTO Peers VALUES(user1, '1998-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO Peers VALUES(user2, '1998-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO Recommendations VALUES(fn_next_id('Recommendations'), user1, user2);
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO Recommendations VALUES(fn_next_id('Recommendations'), user1, user2);
    get diagnostics n_count = row_count;
    assert(n_count = 0);

    INSERT INTO Recommendations VALUES(fn_next_id('Recommendations'), user2, user2);
    get diagnostics n_count = row_count;
    assert(n_count = 0);

    INSERT INTO Recommendations VALUES(fn_next_id('Recommendations'), user2, user1);
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO Recommendations VALUES(fn_next_id('Recommendations'), user1, user1);
    get diagnostics n_count = row_count;
    assert(n_count = 0);


    PERFORM fn_print('                    -- [ OK ] --');
END;
$$ language plpgsql;
ROLLBACK;

-- FRIENDS TEST-------------------------------------------- --

BEGIN;
DO $$
DECLARE
    n_count int := 0;
    user1 TEXT := 'eviadann';
    user2 TEXT := 'jackscan';
BEGIN
    PERFORM fn_print('-- # -- START TEST trg_friends_insert -- # --');

    INSERT INTO Peers VALUES(user1, '1998-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO Peers VALUES(user2, '1998-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO Friends VALUES(fn_next_id('Friends'), user1, user2);
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO Friends VALUES(fn_next_id('Friends'), user2, user1);
    get diagnostics n_count = row_count;
    assert(n_count = 0);

    INSERT INTO Friends VALUES(fn_next_id('Friends'), user1, user2);
    get diagnostics n_count = row_count;
    assert(n_count = 0);
--
    INSERT INTO Friends VALUES(fn_next_id('Friends'), user2, user1);
    get diagnostics n_count = row_count;
    assert(n_count = 0);


    PERFORM fn_print('                    -- [ OK ] --');
END;
$$ language plpgsql;
ROLLBACK;

-- TRANSFERRED_POINTS TEST-------------------------------------------- --

BEGIN;
DO $$
DECLARE
    n_count INT := 0;
    n_points INT := 5;
    checkingP TEXT := 'eviadann';
    checkedP TEXT := 'jackscan';
    userId SMALLINT := fn_next_id('TransferredPoints');

BEGIN
    PERFORM fn_print('-- # -- START TEST trg_transferred_insert -- # --');

    INSERT INTO Peers VALUES(checkingP, '1998-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO Peers VALUES(checkedP, '1998-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO TransferredPoints VALUES(userId, checkingP, checkedP, n_points);
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    assert(
        (
            SELECT PointsAmount FROM TransferredPoints WHERE id = userId
        ) = n_points
    );

    INSERT INTO TransferredPoints VALUES(userId, checkingP, checkedP, n_points);
    get diagnostics n_count = row_count;
    assert(n_count = 0);

    assert(
        (
            SELECT PointsAmount FROM TransferredPoints WHERE id = userId
        ) = n_points + 1
    );


    PERFORM fn_print('                    -- [ OK ] --');
END;
$$ language plpgsql;
ROLLBACK;

-- P2P insert TEST -------------------------------------------- --

BEGIN;
DO $$
DECLARE
    n_count INT := 0;
    n_points INT := 5;
    id_check INT := 0;
BEGIN
    PERFORM fn_print('-- # -- START TEST trg_p2p_insert -- # --');

    INSERT INTO Peers VALUES ('Kolyan', '1991-01-01');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    id_check = fn_next_id('Checks');
    INSERT INTO Checks VALUES (id_check, 'Kolyan', 'C2_SimpleBashUtils', '2023-01-20');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, 'Eileangi', 'Start', '20:20:20');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, 'Deghayra', 'Success', '20:21:20');
    get diagnostics n_count = row_count;
    assert(n_count = 0);

    INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, 'Deghayra', 'Failure', '20:21:20');
    get diagnostics n_count = row_count;
    assert(n_count = 0);

    INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, 'Eileangi', 'Success', '20:20:20');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, 'Eileangi', 'Success', '20:20:20');
    get diagnostics n_count = row_count;
    assert(n_count = 0);

    INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, 'Eileangi', 'Failure', '20:20:20');
    get diagnostics n_count = row_count;
    assert(n_count = 0);

    id_check = fn_next_id('Checks');
    INSERT INTO Checks VALUES (id_check, 'Kolyan', 'C2_SimpleBashUtils', '2023-01-20');
    get diagnostics n_count = row_count;
    assert(n_count = 1);

    PERFORM fn_print('                    -- [ OK ] --');
END;
$$ language plpgsql;
ROLLBACK;

-- VERTER_TEST -------------------------------------------- --

BEGIN;
DO $$
DECLARE
    n_count INT := 0;
    id_check INT := 0;

BEGIN
    PERFORM fn_print('-- # -- START TEST trg_verter_insert -- # --');

  INSERT INTO Peers VALUES ('Kolyan', '1991-01-01');
  get diagnostics n_count = row_count;
  assert(n_count = 1);

  id_check = fn_next_id('Checks');
  INSERT INTO Checks VALUES (id_check, 'Kolyan', 'C2_SimpleBashUtils', '2023-01-20');
  get diagnostics n_count = row_count;
  assert(n_count = 1);

  INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, 'Kolyan', 'Start', '11:00:00');
  get diagnostics n_count = row_count;
  assert(n_count = 1);

  INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, 'Kolyan', 'Start', '11:02:00');
  get diagnostics n_count = row_count;
  assert(n_count = 0);

  INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, 'Kolyan', 'Start', '11:02:00');
  get diagnostics n_count = row_count;
  assert(n_count = 0);

  INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, 'Kolyan', 'Success', '11:11:00');
  get diagnostics n_count = row_count;
  assert(n_count = 1);



  INSERT INTO Verter VALUES (fn_next_id('Verter'), id_check, 'Failure', '11:11:11');
  get diagnostics n_count = row_count;
  assert(n_count = 0);

  INSERT INTO Verter VALUES (fn_next_id('Verter'), id_check, 'Success', '11:11:11');
  get diagnostics n_count = row_count;
  assert(n_count = 0);

  INSERT INTO Verter VALUES (fn_next_id('Verter'), id_check, 'Start', '11:11:11');
  get diagnostics n_count = row_count;
  assert(n_count = 1);

  INSERT INTO Verter VALUES (fn_next_id('Verter'), id_check, 'Start', '11:11:11');
  get diagnostics n_count = row_count;
  assert(n_count = 0);

  INSERT INTO Verter VALUES (fn_next_id('Verter'), id_check, 'Start', '11:11:11');
  get diagnostics n_count = row_count;
  assert(n_count = 0);

  INSERT INTO Verter VALUES (fn_next_id('Verter'), id_check, 'Failure', '11:13:11');
  get diagnostics n_count = row_count;
  assert(n_count = 1);

  INSERT INTO Verter VALUES (fn_next_id('Verter'), id_check, 'Failure', '11:13:11');
  get diagnostics n_count = row_count;
  assert(n_count = 0);

  INSERT INTO Verter VALUES (fn_next_id('Verter'), id_check, 'Success', '11:13:11');
  get diagnostics n_count = row_count;
  assert(n_count = 0);

  INSERT INTO Verter VALUES (fn_next_id('Verter'), id_check, 'Start', '11:13:11');
  get diagnostics n_count = row_count;
  assert(n_count = 0);



  id_check = fn_next_id('Checks');

  INSERT INTO Checks VALUES (id_check, 'Kolyan', 'C2_SimpleBashUtils', '2023-02-20');
  get diagnostics n_count = row_count;
  assert(n_count = 1);

  INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, 'Kolyan', 'Start', '13:12:00');
  get diagnostics n_count = row_count;
  assert(n_count = 1);

  INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, 'Kolyan', 'Success', '13:14:00');
  get diagnostics n_count = row_count;
  assert(n_count = 1);

  INSERT INTO Verter VALUES (fn_next_id('Verter'), id_check, 'Start', '14:13:11');
  get diagnostics n_count = row_count;
  assert(n_count = 1);

  INSERT INTO Verter VALUES (fn_next_id('Verter'), id_check, 'Success', '14:14:11');
  get diagnostics n_count = row_count;
  assert(n_count = 1);



  id_check = fn_next_id('Checks');

  INSERT INTO Checks VALUES (id_check, 'Kolyan', 'C3_StringPlus', '2023-02-20');
  get diagnostics n_count = row_count;
  assert(n_count = 1);

  INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, 'Kolyan', 'Start', '13:12:00');
  get diagnostics n_count = row_count;
  assert(n_count = 1);

  INSERT INTO P2P VALUES (fn_next_id('P2P'), id_check, 'Kolyan', 'Success', '13:14:00');
  get diagnostics n_count = row_count;
  assert(n_count = 1);

  INSERT INTO Verter VALUES (fn_next_id('Verter'), id_check, 'Success', '14:14:11');
  get diagnostics n_count = row_count;
  assert(n_count = 0);

  INSERT INTO Verter VALUES (fn_next_id('Verter'), id_check, 'Start', '14:13:11');
  get diagnostics n_count = row_count;
  assert(n_count = 1);

  INSERT INTO Verter VALUES (fn_next_id('Verter'), id_check, 'Success', '14:14:11');
  get diagnostics n_count = row_count;
  assert(n_count = 1);


   PERFORM fn_print('                    -- [ OK ] --');
END;
$$ language plpgsql;
ROLLBACK;
