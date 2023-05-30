-- -------------------------------------------- --
BEGIN;
DO $$
DECLARE
    n_count int;
BEGIN
    PERFORM fn_print('-- # -- START TEST trg_timetracking_insert -- # --');

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Bonk', '2023-01-01', '10:10:10', 1);
    get diagnostics n_count = row_count;
--     RAISE NOTICE 'Добавлено % строк', n_count;
    assert(n_count = 1);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Bonk', '2023-01-01', '10:15:12', 1);
    get diagnostics n_count = row_count;

    assert(n_count = 0);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Bonk', '2023-01-01', '10:15:12', 2);
    get diagnostics n_count = row_count;

    assert(n_count = 1);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Bonk', '2023-01-01', '10:15:12', 2);
    get diagnostics n_count = row_count;

    assert(n_count = 0);


    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Bonk', '2023-01-01', '11:15:12', 2);
    get diagnostics n_count = row_count;

    assert(n_count = 0);

    PERFORM fn_print('                    -- [ OK ] --');
--     RAISE NOTICE 'Добавлено % строк', n_count;
END;
$$ language plpgsql;
ROLLBACK;

-- RECCOMENDATION TEST-------------------------------------------- --

BEGIN;
DO $$
DECLARE
    n_count int;
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
--     RAISE NOTICE 'Добавлено % строк', n_count;
END;
$$ language plpgsql;
ROLLBACK;

-- SELECT * FROM TimeTracking;

