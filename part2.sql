/**
* @file part2.sql
* @brief -> Create a part2.sql script, in which, in addition to what is described below, add test queries/calls for each item.
*
* 1) Write a procedure for adding P2P check
* Parameters: nickname of the person being checked, checker's nickname, task name, P2P check status, time.
*
* If the status is "start", add a record in the Checks table (use today's date).
* Add a record in the P2P table.
* If the status is "start", specify the record just added as a check, otherwise specify the check with the unfinished P2P step.
*
* 2) Write a procedure for adding checking by Verter
* Parameters: nickname of the person being checked, task name, Verter check status, time.
* Add a record to the Verter table (as a check specify the check of the corresponding task with the latest (by time) successful P2P step)
*
* 3) Write a trigger: after adding a record with the "start" status to the P2P table, change the corresponding record in the TransferredPoints table
*
* 4) Write a trigger: before adding a record to the XP table, check if it is correct
* The record is considered correct if:
*
* The number of XP does not exceed the maximum available for the task being checked
* The Check field refers to a successful check
* If the record does not pass the check, do not add it to the table.

*/


/**
* @brief 1) Write a procedure for adding P2P check
*       Parameters: nickname of the person being checked, checker's nickname, task name, P2P check status, time.
*       If the status is "start", add a record in the Checks table (use today's date).
*       Add a record in the P2P table.
*       If the status is "start", specify the record just added as a check,
*                   otherwise specify the check with the unfinished P2P step.
*/

-- nickaname_checked - ник проверяемого
-- nickaname_checker - ник проверяющего
CREATE OR REPLACE PROCEDURE pr_p2p_check_add(
    IN nickname_checked   TEXT,
    IN nickname_checker   TEXT,
    IN task_name          TEXT,
    IN status             check_status,
    IN n_time             TIME
) AS $$
DECLARE
    n_count  INT := 0;
    id_check INT := 0;
BEGIN

    IF status = 'Start' THEN

        IF (SELECT COUNT(*) FROM P2P
                JOIN Checks ON P2P."Check" = Checks.ID
            WHERE P2P.CheckingPeer = nickname_checker AND
                  Checks.Task = task_name) = 1 THEN
            RAISE DEBUG 'This peer incomplete check.';
        ELSE
            id_check = fn_next_id('Checks');
            INSERT INTO Checks VALUES (
                id_check,
                nickname_checked,
                task_name,
                CURRENT_DATE);

            get diagnostics n_count = row_count;

            IF n_count = 1 THEN
                INSERT INTO P2P VALUES (
                    fn_next_id('P2P'),
                    id_check,
                    nickname_checker,
                    status,
                    n_time);
            END IF;
        END IF;
    ELSE
        id_check = (SELECT "Check" FROM P2P
            JOIN Checks ON Checks.ID = P2P."Check"    AND
            Checks.Task = task_name                   AND
            Checks.Peer = nickname_checked
            WHERE P2P.CheckingPeer = nickname_checker AND
            P2P.State = 'Start'
            ORDER BY Checks.ID DESC
            LIMIT 1);


        IF id_check IS NULL THEN
            RAISE DEBUG 'ID CHECK IS NOT FIND';
        ELSE
            INSERT INTO P2P VALUES (
                fn_next_id('P2P'),
                id_check,
                nickname_checker,
                status,
                n_time
            );
        END IF;
    END IF;


END;
$$ LANGUAGE plpgsql;

-- select * FROM p2p where p2p.CheckingPeer = 'Dima';
-- CALL pr_p2p_check_add('Kostic', 'Dima', 'DO3_LinuxMonitoring_v1.0', 'Start', '01:00:00'); -- ERROR
-- select * FROM p2p where p2p.CheckingPeer = 'Dima';
--
-- CALL pr_p2p_check_add('Kostic', 'Dima', 'C2_SimpleBashUtils', 'Start', '01:00:00'); -- OK
-- CALL pr_p2p_check_add('Kostic', 'Dima', 'C2_SimpleBashUtils', 'Success', '01:00:00'); -- OK
-- select * FROM p2p where p2p.CheckingPeer = 'Dima';
--
-- -------------------------------------------- --

--  2) Write a procedure for adding checking by Verter
--  Parameters: nickname of the person being checked, task name, Verter check status, time.
--  Add a record to the Verter table (as a check specify the check of the corresponding task with the latest (by time) successful P2P step)

CREATE OR REPLACE PROCEDURE pr_verter_check_add(
    IN nickname_checked TEXT,
    IN task_name        TEXT,
    IN status           check_status,
    IN n_time           TIME
) AS $$
DECLARE
    check_id INT := (
        SELECT Checks.ID FROM Checks
        JOIN P2P ON P2P."Check" = Checks.ID
        WHERE P2P.State = 'Success'   AND
              Checks.Task = task_name AND
              Checks.Peer = nickname_checked
              ORDER BY Checks."Date" DESC, P2P."Time" DESC
            -- ORDER BY P2P."Time" DESC, Checks."Date" DESC
            LIMIT 1
    );
BEGIN
    IF COALESCE(check_id, 0) != 0 THEN
        INSERT INTO Verter VALUES (
            fn_next_id('Verter'),
            check_id,
            status,
            n_time
        );
    ELSE
        RAISE DEBUG 'This peer incompleted task or has a `Failure` status.';
    END IF;

END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------- --

-- CALL pr_verter_check_add('Kostic', 'C5_Decimal', 'Success', '19:11:11');     -- ERROR
-- SELECT * FROM Verter ORDER BY 1 DESC LIMIT 2;
--
-- CALL pr_verter_check_add('Kostic', 'C2_SimpleBashUtils', 'Start', '11:11:11');     -- OK
-- CALL pr_verter_check_add('Kostic', 'C2_SimpleBashUtils', 'Success', '11:21:11');   -- OK
-- SELECT * FROM Verter ORDER BY 1 DESC LIMIT 2;


/**
* @brief 3) Write a trigger: after adding a record with the "start" status to the P2P table,
*                   change the corresponding record in the TransferredPoints table
*/
CREATE OR REPLACE FUNCTION fn_trg_p2p_transferred_points_insert()
RETURNS TRIGGER AS $$
DECLARE
    points INT := 1;
BEGIN

    IF NEW.State = 'Start' THEN
        INSERT INTO TransferredPoints VALUES(
            fn_next_id('TransferredPoints'),
            NEW.CheckingPeer,
            (SELECT Peer FROM Checks WHERE NEW."Check" = Checks.ID),
            points
        );
    END IF;
    return NEW;
END;
$$ LANGUAGE plpgsql;
-- -------------------------------------------- --
CREATE TRIGGER trg_p2p_transferred_points_insert
AFTER INSERT ON P2P
FOR EACH ROW
EXECUTE PROCEDURE fn_trg_p2p_transferred_points_insert();

-- SELECT * FROM TransferredPoints WHERE  CheckedPeer = 'Kostic';
-- CALL pr_p2p_check_add('Kostic', 'Dima', 'C3_StringPlus', 'Start', '01:00:00');
-- CALL pr_p2p_check_add('Kostic', 'Dima', 'C3_StringPlus', 'Success', '01:00:00');
-- CALL pr_verter_check_add('Kostic', 'C2_SimpleBashUtils', 'Start', '11:11:11');
-- CALL pr_verter_check_add('Kostic', 'C2_SimpleBashUtils', 'Success', '11:21:11');
-- SELECT * FROM TransferredPoints WHERE  CheckedPeer = 'Kostic';

-- -------------------------------------------- --

/**
* @brief 4. Before adding an entry to the xp tabl, checks the correctness of the
*       added entry.
*   - The amount of xp does not exceed the maximum available for the task being checked.
*   - The "Check" field refers to a successful check.
*   - If the record has not passed validation, do not add it to the table.
*
* @return
*/
CREATE OR REPLACE FUNCTION fn_trg_xp_check_add()
RETURNS TRIGGER AS $$
DECLARE
    is_xp_success BOOL := (SELECT Tasks.MaxXP FROM Tasks
        JOIN Checks ON Checks.ID      = NEW."Check"
        JOIN P2P    ON P2P."Check"    = Checks.ID
        FULL JOIN Verter ON Verter."Check" = Checks.ID
        WHERE Checks.Task = Tasks.title   AND
              NEW.XPAmount <= Tasks.MaxXP AND
              P2P.State = 'Success'       AND
              (Verter.State = 'Success' OR Verter.State IS NULL)
    ) > 0;
BEGIN
    IF is_xp_success THEN
        return NEW;
    else
        return NULL;
    END IF;

    return NEW;
END;
$$ LANGUAGE plpgsql;
-- -------------------------------------------- --
CREATE TRIGGER trg_xp_check_add
BEFORE INSERT ON XP
FOR EACH ROW
EXECUTE PROCEDURE fn_trg_xp_check_add();
-- -------------------------------------------- --

-- SELECT * FROM XP ORDER BY 1 DESC LIMIT 3;
-- INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 850); -- ERROR
-- SELECT * FROM XP ORDER BY 1 DESC LIMIT 4;
--
-- SELECT * FROM XP ORDER BY 1 DESC LIMIT 3;
-- INSERT INTO XP VALUES (fn_next_id('XP'), fn_max_id('Checks'), 250); -- OK
-- SELECT * FROM XP ORDER BY 1 DESC LIMIT 4;
