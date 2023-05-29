-- -------------------------------------------- --
BEGIN;
DO $$
DECLARE
    rows_count int;
BEGIN
    PERFORM fn_print('-- # -- START TEST fn_trg_timetracking_insert -- # --');

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Bonk', '2023-01-01', '10:10:10', 1);
    get diagnostics rows_count = row_count;
--     RAISE NOTICE 'Добавлено % строк', rows_count;
    assert(rows_count = 1);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Bonk', '2023-01-01', '10:15:12', 1);
    get diagnostics rows_count = row_count;

    assert(rows_count = 0);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Bonk', '2023-01-01', '10:15:12', 2);
    get diagnostics rows_count = row_count;

    assert(rows_count = 1);

    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Bonk', '2023-01-01', '10:15:12', 2);
    get diagnostics rows_count = row_count;

    assert(rows_count = 0);


    INSERT INTO TimeTracking VALUES(fn_next_id('TimeTracking'), 'Bonk', '2023-01-01', '11:15:12', 2);
    get diagnostics rows_count = row_count;

    assert(rows_count = 0);

    PERFORM fn_print('                    -- [ OK ] --');
--     RAISE NOTICE 'Добавлено % строк', rows_count;
END;
$$ language plpgsql;
rollback;

SELECT * FROM TimeTracking;

