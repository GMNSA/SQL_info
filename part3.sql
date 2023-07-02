/**
* @brief 1. Function that returns the TransferredPoints table in a more human-readable form.
*   - Peer's nickname 1.
*   - Peer's nickname 2
*   - Number of transferred peer points.
*/
CREATE OR REPLACE FUNCTION fn_print_human_readable_transferred_points()
RETURNS TABLE(Peer1 TEXT, Peer2 TEXT, PointsAmount BIGINT) AS
$$ BEGIN
return QUERY(
    SELECT
        tp1.CheckingPeer                    AS Peer1,
        tp1.CheckedPeer                     AS Peer2,
        CASE
        WHEN tp2.ID IS NOT NULL THEN
            (tp1.PointsAmount - tp2.PointsAmount)
        ELSE
            tp1.PointsAmount
        END AS PointsAmount
    FROM TransferredPoints AS tp1
    LEFT JOIN TransferredPoints AS tp2 ON tp1.ID != tp2.ID AND
        tp1.CheckingPeer = tp2.CheckedPeer AND
        tp1.CheckedPeer = tp2.CheckingPeer
);
END $$
LANGUAGE 'plpgsql';

-- SELECT * FROM fn_print_human_readable_transferred_points();

-- -------------------------------------------- --

/**
* @brief 2. function that returns a table of the following form: user name,
*               name of the checked task, number of XP received.
*
*    Include in the table only tasks that have successfully passed the check
*       (according to the Checks table).
*    One task can be completed successfully several times.
*       In this case, include all successful checks in the table.
*/
CREATE OR REPLACE FUNCTION fn_print_table_success_task()
RETURNS TABLE(Peer TEXT, Task TEXT, XP BIGINT) AS
$$ BEGIN
return QUERY(
    SELECT * FROM (
        SELECT Checks.Peer, Checks.Task, XP.XPAmount FROM Checks
        JOIN XP     ON XP."Check"     = Checks.ID
        JOIN P2P    ON P2P."Check"    = Checks.ID AND P2P.State = 'Success'
        FULL JOIN Verter ON Verter."Check" = Checks.ID AND
        (Verter.State = 'Success' OR Verter.State IS NULL)
    ) AS tmp
    WHERE tmp.Peer != ''
);
END $$
LANGUAGE 'plpgsql';

-- SELECT * FROM fn_print_table_success_task();

-- -------------------------------------------- --

/**
* @brief 3. Function that finds the peers who have not left campus for the whole day.
*       Function parameters: day, for example 12.05.2022.
*       The function returns only a list of peers.
*
* @param Peer TEXT
*/

CREATE OR REPLACE FUNCTION fn_peers_not_left_campus(IN dt DATE)
RETURNS TABLE(Peer TEXT) AS
$$
DECLARE
BEGIN
    return QUERY(
        WITH f1 AS (
            SELECT tm1.ID,
            tm1.Peer,
            tm1.State,
            COUNT(*) AS count
            FROM TimeTracking AS tm1
            WHERE tm1."Date" = dt AND tm1.State = 1
            GROUP BY tm1.ID, tm1.Peer, tm1.State
        ), f2 AS (
            SELECT tm2.ID,
            tm2.Peer,
            tm2.State,
            COUNT(*) AS count
            FROM TimeTracking AS tm2
            WHERE tm2."Date" = dt AND tm2.State = 2
            GROUP BY tm2.ID, tm2.Peer, tm2.State
        )

        SELECT f1.Peer FROM f1
        LEFT JOIN f2 ON f1.Peer = f2.Peer
        WHERE f2.Peer IS NULL
    );
END $$
LANGUAGE 'plpgsql';

-- SELECT * FROM fn_peers_not_left_campus('2023-03-11');

-- -------------------------------------------- --

/**
* @brief 4. Calculate the change in the number of peer points of each peer using the TransferredPoints table
*             - Output the result sorted by the change in the number of points.
*             - Output format: peer's nickname, change in the number of peer points
*/

CREATE OR REPLACE PROCEDURE pr_print_calculate_change_number_of_peer_points(
    IN cursor refcursor DEFAULT 'cursor'
) AS $$
DECLARE

BEGIN
    OPEN cursor FOR

    WITH Checking_tab AS (
        SELECT
        tp1.CheckingPeer       AS Peer,
        SUM(tp1.PointsAmount)  AS PointsChange
        FROM TransferredPoints AS tp1
        GROUP BY CheckingPeer
    ), Checked_tab AS (
        SELECT
        tp2.CheckedPeer        AS Peer,
        SUM(tp2.PointsAmount)  AS PointsChange
        FROM TransferredPoints AS tp2
        GROUP BY CheckedPeer
    )

    SELECT
        Peer,
        (COALESCE(Checking_tab.PointsChange, 0) -
        COALESCE(Checked_tab.PointsChange, 0)) AS PointsChange
    FROM Checked_tab
        FULL JOIN Checking_tab USING(Peer)
    ORDER BY PointsChange DESC;

END;
$$ LANGUAGE plpgsql;

-- BEGIN;
--     CALL pr_print_calculate_change_number_of_peer_points();
--     FETCH ALL IN "cursor";
-- END;

-- -------------------------------------------- --

/**
* @brief 5. Calculate the change in the number of peer points of each peer using the table returned by the
*               first function from fn_print_human_readable_transferred_points
*
*/


CREATE OR REPLACE PROCEDURE pr_calculate_change_number_peer_using_table(
    IN cursor refcursor DEFAULT 'cursor'
) AS $$
DECLARE
BEGIN
   OPEN cursor FOR
        WITH w_checking AS (
            SELECT
                CheckingPeer AS Peer,
                SUM(PointsAmount) AS n_plus
            FROM TransferredPoints
            GROUP BY CheckingPeer
            ORDER BY Peer
        ), w_res AS (
            SELECT c.Peer,
                (COALESCE(n_plus, 0)
                    - COALESCE(n_min, 0)) as PointsChange
            FROM w_checking
                FULL JOIN (
                    SELECT
                        CheckedPeer as Peer,
                        sum(PointsAmount) as n_min
                    FROM TransferredPoints
                    GROUP BY CheckedPeer
                    ORDER BY Peer
                ) AS c ON w_checking.Peer = c.Peer
        )

        SELECT * FROM w_res WHERE Peer != '';

END;
$$ LANGUAGE plpgsql;

-- BEGIN;
--     CALL pr_calculate_change_number_peer_using_table();
--     FETCH ALL IN "cursor";
-- END;

-- -------------------------------------------- --

/*
6) Определить самое часто проверяемое задание за каждый день
При одинаковом количестве проверок каких-то заданий в определенный день, вывести их все.
Формат вывода: день, название задания
*/

CREATE OR REPLACE PROCEDURE pr_daily_most_checked_task(
    IN cursor refcursor DEFAULT 'cursor'
) AS $$
DECLARE
BEGIN
   OPEN cursor FOR
         WITH count_task_list AS (
             SELECT checks."Date", Task, Count(Task) AS count_task
             FROM Checks
             GROUP BY "Date", Task
             ORDER BY Count(Task) DESC)
         SELECT t1."Date" AS Day, t1.Task AS Task
         FROM count_task_list AS t1
         WHERE t1.count_task = (SELECT MAX(t2.count_task)
                                FROM count_task_list AS t2
                                WHERE t1."Date" = t2."Date")
         ORDER BY t1."Date", t1.Task;

END;
$$ LANGUAGE plpgsql;

-- BEGIN;
--     CALL pr_daily_most_checked_task();
--     FETCH ALL IN "cursor";
-- END;

-- -------------------------------------------- --

/**
* @brief 7. Find all peers who have completed the whole given block of tasks
*                           and the completion date of the last task
*/

CREATE OR REPLACE PROCEDURE pr_peers_completed_block(
    IN block_name TEXT,
    IN cursor refcursor DEFAULT 'cursor'
) AS $$
DECLARE
BEGIN
   OPEN cursor FOR
        WITH block_task AS (
            SELECT *
            FROM tasks
            WHERE title SIMILAR TO concat(block_name, '[0-9]%')),
        last_task AS (
            SELECT MAX(title) AS max_title
            FROM block_task),
        successfull_check AS (
            SELECT checks.peer, checks.task, checks."Date"
            FROM checks
            JOIN p2p ON checks.id = p2p."Check"
            WHERE p2p.State = 'Success'
            GROUP by checks.id)
        SELECT successfull_check.peer AS Peer, successfull_check."Date" AS Day
        FROM successfull_check
        JOIN last_task ON successfull_check.task = last_task.max_title;

END;
$$ LANGUAGE plpgsql;

-- BEGIN;
--     CALL pr_peers_completed_block('DO');
--     FETCH ALL IN "cursor";
-- END;

-- -------------------------------------------- --


/**
* @brief 8. Determine which peer each student should go to for a check.
*/

CREATE OR REPLACE PROCEDURE pr_recommendations_peers_friends(
    IN cursor refcursor DEFAULT 'cursor'
) AS $$
DECLARE
BEGIN
   OPEN cursor FOR
    WITH p_f AS (
        SELECT
        Peers.Nickname AS Target,
        (CASE
        WHEN Friends.Peer1 = Nickname THEN
                Friends.Peer2
            ELSE
                Friends.Peer1
            END
        ) AS Friend
        FROM Peers
        JOIN Friends ON (Friends.Peer1 = Peers.Nickname OR
            Friends.Peer2 = Peers.Nickname
        )
        ORDER BY Peers.Nickname
    )

    SELECT DISTINCT ON (s.Target) s.Target AS Peer,
        s.RecommendedPeer AS RecommendedPeer FROM (
            SELECT
                p_f.Target,
                Recommendations.RecommendedPeer,
                COUNT(Recommendations.RecommendedPeer)
            FROM p_f
                JOIN Recommendations ON Recommendations.Peer = p_f.Friend
                    WHERE p_f.Target != Recommendations.RecommendedPeer
                    GROUP BY p_f.Target, Recommendations.RecommendedPeer
    ) as s
    ORDER BY s.Target;

END;
$$ LANGUAGE plpgsql;

-- BEGIN;
--     CALL pr_recommendations_peers_friends();
--     FETCH ALL IN "cursor";
-- END;

-- -------------------------------------------- --


/**
* @brief 9. Determine the percentage of peers who:
*
*  Started only block 1
*  Started only block 2
*  Started both
*  Have not started any of them
*
* A peer is considered to have started a block if he has at least
            one check of any task from this block (according to the Checks table)
* Procedure parameters: name of block 1, for example SQL, name of block 2, for example A.
* Output format: percentage of those who started only the first block,
*           percentage of those who started only the second block,
*           percentage of those who started both blocks, percentage of those who did not started any of them
*/

CREATE OR REPLACE PROCEDURE pr_peers_percent(IN name1 text,
											 IN name2 text,
											 OUT startedblock1 real,
											 OUT startedblock2 real,
											 OUT startedbothblock real,
											 OUT didntstartanyblock real
) AS $$
DECLARE
BEGIN

    CREATE TABLE IF NOT EXISTS temp(name1_temp varchar, name2_temp varchar);
    INSERT INTO temp VALUES (name1, name2);
    CREATE OR REPLACE VIEW temp1 AS (
        WITH first_parameter AS (
            SELECT DISTINCT peer
            FROM checks
            WHERE checks.task SIMILAR TO CONCAT((SELECT name1_temp FROM temp), '[0-9]%')),
        second_parameter AS (
            SELECT DISTINCT peer
            FROM checks
            WHERE checks.task SIMILAR TO CONCAT((SELECT name2_temp FROM temp), '[0-9]%')),
        started_block1 AS (
            SELECT peer FROM first_parameter
            EXCEPT
            SELECT peer FROM second_parameter),
        started_block2 AS (
            SELECT peer FROM second_parameter
            EXCEPT
            SELECT peer FROM first_parameter),
        started_both_block AS (
            SELECT peer FROM first_parameter
            INTERSECT
            SELECT peer FROM second_parameter),
        didnt_start_any_block AS (
            SELECT Nickname
            FROM peers
            LEFT JOIN checks ON peers.nickname = checks.peer
            EXCEPT
            SELECT peer FROM started_block1
            EXCEPT
            SELECT peer FROM started_block2
            EXCEPT
            SELECT peer FROM started_both_block),
        didnt_start_any_block2 AS (
            SELECT nickname
            FROM peers
            JOIN Checks ON peers.Nickname = Checks.peer
            WHERE peer IS NULL)
        SELECT (((SELECT COUNT(*) FROM started_block1)::real * 100) / (SELECT COUNT(peers.nickname) FROM peers)::real) AS tempvar1,
        (((SELECT COUNT(*) FROM started_block2)::real * 100) / (SELECT COUNT(peers.nickname) FROM peers)::real) AS tempvar2,
        (((SELECT COUNT(*) FROM started_both_block)::real * 100) / (SELECT COUNT(peers.nickname) FROM peers)::real) AS tempvar3,
        (((SELECT COUNT(*) FROM didnt_start_any_block)::real * 100) / (SELECT COUNT(peers.nickname) FROM peers)::real) AS tempvar4,
        (((SELECT COUNT(*) FROM didnt_start_any_block2)::real * 100) / (SELECT COUNT(peers.nickname) FROM peers)::real) AS tempvar5);
    startedblock1 = (SELECT tempvar1 FROM temp1);
    startedblock2 = (SELECT tempvar2 FROM temp1);
    startedbothblock = (SELECT tempvar3 FROM temp1);
    didntstartanyblock = (SELECT tempvar4 + tempvar5 FROM temp1);
    DROP VIEW temp1 CASCADE;
    DROP TABLE temp CASCADE;

END;
$$ LANGUAGE plpgsql;

-- DO $$
-- DECLARE
--     startedblock1 real := 0;
--     startedblock2 real := 0;
--     startedbothblock real := 0;
--     didntstartanyblock real := 0;
-- BEGIN
--     CALL pr_peers_percent('С', 'DO', startedblock1, startedblock2, startedbothblock, didntstartanyblock);
--     RAISE NOTICE 'RESULT: % % % %', startedblock1, startedblock2, startedbothblock, didntstartanyblock;
--     CALL pr_peers_percent('СPP', 'C', startedblock1, startedblock2, startedbothblock, didntstartanyblock);
--     RAISE NOTICE 'RESULT: % % % %', startedblock1, startedblock2, startedbothblock, didntstartanyblock;
--     CALL pr_peers_percent('A', 'C', startedblock1, startedblock2, startedbothblock, didntstartanyblock);
--     RAISE NOTICE 'RESULT: % % % %', startedblock1, startedblock2, startedbothblock, didntstartanyblock;
--     CALL pr_peers_percent('SQL', 'C', startedblock1, startedblock2, startedbothblock, didntstartanyblock);
--     RAISE NOTICE 'RESULT: % % % %', startedblock1, startedblock2, startedbothblock, didntstartanyblock;
-- END
-- $$;


-- -------------------------------------------- --

/**
* @brief 10. Determine the percentage of peers who have ever successfully passed a check on their birthday.
*               Also determine the percentage of peers who have ever failed a check on their birthday.
*
*/

CREATE OR REPLACE PROCEDURE pr_percentage_peers_have_success_birthday(
    IN cursor refcursor DEFAULT 'cursor'
) AS $$
DECLARE
BEGIN
   OPEN cursor FOR

    WITH w_all_check_info AS (
        SELECT Checks.ID AS ID,
               P2P.CheckingPeer AS Checking_Peer,
               Checks.Peer AS Checked_Peer,
               Checks."Date" AS Data,
               Checks.Task AS Task,
               P2P.State AS P2P_State,
               Verter.State AS Verter_State,
                (CASE
                    WHEN  Verter.State = 'Failure' OR P2P.State = 'Failure' THEN 'F'
                    WHEN  Verter.State = 'Success' OR P2P.State = 'Success' THEN 'S'
                    END
                ) as res
        FROM Checks
        LEFT JOIN P2P ON P2P."Check" = Checks.ID AND P2P.State != 'Start'
        LEFT JOIN Verter ON Verter."Check" = Checks.ID AND Verter.State != 'Start'
        WHERE P2P.CheckingPeer IS NOT NULL
    ), w_get_check_birtdh AS (
        SELECT *
        FROM w_all_check_info
        JOIN Peers  ON Peers.Nickname = w_all_check_info.Checked_Peer
                    AND EXTRACT(month FROM Peers.Birthday) = EXTRACT(month FROM w_all_check_info.Data)
                    AND EXTRACT(day FROM Peers.Birthday) = EXTRACT(day FROM w_all_check_info.Data)
    ), w_n_count AS (
        SELECT
            w1.res AS State,
            COUNT(*) AS n
        FROM w_get_check_birtdh AS w1
            JOIN w_get_check_birtdh AS w2 ON w1.ID = w2.ID
        GROUP BY w1.res
    ) , w_res AS (
        SELECT *
            FROM w_n_count
        UNION ALL
        SELECT 'S', 0 WHERE NOT EXISTS (
            SELECT State, n FROM w_n_count
            WHERE State = 'S'
        )
        UNION ALL
        SELECT 'F', 0 WHERE NOT EXISTS (
            SELECT State, n FROM w_n_count
            WHERE State = 'F'
        )
    )

    SELECT (CASE w1.State
                WHEN 'S' THEN
                    ROUND(((w1.n * 100) / (w1.n + w2.n)::numeric), 0)
                ELSE
                    ROUND(((w2.n * 100) / (w1.n + w2.n)::numeric), 0)
                END
            ) AS SuccessfulChecks,
            (CASE w2.State
                WHEN 'S' THEN
                    ROUND(((w1.n * 100) / (w1.n + w2.n)::numeric), 0)
                ELSE
                    ROUND(((w2.n * 100) / (w1.n + w2.n)::numeric), 0)
                END
            ) AS UnsuccessfulChecks
    FROM w_res AS w1
    JOIN w_res AS w2 ON w2.State != w1.State
    LIMIT 1;

END;
$$ LANGUAGE plpgsql;

-- BEGIN;
--     CALL pr_percentage_peers_have_success_birthday('cursor');
--     FETCH ALL IN "cursor";
-- END;

-- -------------------------------------------- --

/**
* @brief 11. Determine all peers who did the given tasks 1 and 2, but did not do task 3
*
*/
CREATE OR REPLACE PROCEDURE pr_all_peers_who_did_given_1_2_not_3(
    IN task1 TEXT,
    IN task2 TEXT,
    IN task3 TEXt,
    IN cursor refcursor DEFAULT 'cursor'
) AS $$
DECLARE
BEGIN
   OPEN cursor FOR
    WITH w_peers_task AS (
        SELECT Peer, Task
        FROM Checks
        GROUP BY Peer, Task
        ORDER BY Peer
    )

    SELECT * FROM (SELECT wpt1.Peer,
                               wpt2.Task,
                               COUNT(wpt1.Peer) OVER (partition BY wpt1.Peer)
                        FROM  w_peers_task AS wpt1
                        JOIN w_peers_task AS wpt2 ON wpt2.Peer = wpt1.Peer AND
                             wpt2.Task = wpt1.Task) AS t1
    WHERE t1.Task = task2 AND t1.Peer NOT IN (
        SELECT t2.Peer FROM (
            SELECT wpt1.Peer,
                   wpt2.Task,
                   COUNT(wpt1.Peer) OVER (partition BY wpt1.Peer)
                   FROM  w_peers_task AS wpt1
            JOIN w_peers_task AS wpt2 ON wpt2.Peer = wpt1.Peer AND
                 wpt2.Task = wpt1.Task
        ) as t2
        WHERE t2.Task = task3);

END;
$$ LANGUAGE plpgsql;

-- BEGIN;
--     CALL pr_all_peers_who_did_given_1_2_not_3('C2_SimpleBashUtils',
--         'C3_StringPlus',
--         'C4_Math'
--     );
--     FETCH ALL IN "cursor";
-- END;

-- BEGIN;
--     CALL pr_all_peers_who_did_given_1_2_not_3('DO1_Linux',
--         'DO2_LinuxNetwork',
--         'DO3_LinuxMonitoring_v1_0'
--     );
--     FETCH ALL IN "cursor";
-- END;

-- -------------------------------------------- --

/**
* @brief 12. Using recursive common table expression, output the number of preceding tasks for each task
*
*       I. e. How many tasks have to be done, based on entry conditions, to get access to the current one.
*           Output format: task name, number of preceding tasks
*
*/


CREATE OR REPLACE PROCEDURE pr_num_previous_tasks(
    IN cursor refcursor DEFAULT 'cursor'
) AS $$
DECLARE
BEGIN
   OPEN cursor FOR
	WITH RECURSIVE recurs AS (
		SELECT (CASE WHEN tasks.parenttask IS NULL THEN 0
				ELSE 1
				END) AS task_count, Tasks.title, Tasks.parenttask, tasks.parenttask
		FROM Tasks
		UNION ALL
		SELECT (CASE WHEN tasks.parenttask IS NOT NULL THEN task_count + 1
				ELSE task_count
				END) AS task_count, tasks.Title, tasks.parenttask, recurs.title
		FROM tasks
		CROSS JOIN recurs
		WHERE recurs.Title LIKE Tasks.ParentTask)
	SELECT title, MAX(task_count)
	FROM recurs
	GROUP BY title
	ORDER BY MAX(task_count);
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
--     CALL pr_num_previous_tasks();
--     FETCH ALL IN "cursor";
-- END;

-- -------------------------------------------- --

/**
* @brief 13.  Find "lucky" days for checks. A day is considered "lucky" if it has at least N consecutive successful checks.
*
* Parameters of the procedure: the N number of consecutive successful checks .
* The time of the check is the start time of the P2P step.
* Successful consecutive checks are the checks with no unsuccessful checks in between.
* The amount of XP for each of these checks must be at least 80% of the maximum.
* Output format: list of days
*
*/
CREATE OR REPLACE PROCEDURE pr_lucky_days_for_checks(
    IN N INT,
    IN cursor refcursor DEFAULT 'cursor'
) AS $$
DECLARE
BEGIN
   OPEN cursor FOR
    WITH w_all_check_info AS (
        SELECT Checks.ID AS ID,
               P2P.CheckingPeer AS Checking_Peer,
               Checks.Peer AS Checked_Peer,
               Checks."Date" AS Data,
               Checks.Task AS Task,
               P2P.State AS P2P_State,
               Verter.State AS Verter_State,
                (CASE
                    WHEN  Verter.State = 'Failure' OR P2P.State = 'Failure' THEN 'F'
                    WHEN  Verter.State = 'Success' OR P2P.State = 'Success' THEN 'S'
                    END
                ) as res
        FROM Checks
        LEFT JOIN P2P ON P2P."Check" = Checks.ID AND P2P.State != 'Start'
        LEFT JOIN Verter ON Verter."Check" = Checks.ID AND Verter.State != 'Start'
        WHERE P2P.CheckingPeer IS NOT NULL
    ), w_prev_state AS (
        SELECT *,
            LAG(w_all_check_info.res, 1, '-') OVER
                    (partition BY w_all_check_info.Data ORDER BY w_all_check_info.ID) AS lg
        FROM w_all_check_info
        ORDER BY Data DESC
    ), w_n_success AS (
        SELECT Data, COUNT(*) OVER (partition BY Data)
        FROM w_prev_state
            JOIN Tasks ON w_prev_state.Task = Tasks.Title
            JOIN XP ON w_prev_state.ID = XP."Check"
            WHERE res = 'S' AND (lg = 'S' OR lg = '-') AND
                XP.XPAmount >= Tasks.MaxXP * 0.8
    ), w_res AS (
        SELECT DATA FROM (SELECT DATA, COUNT(*)
                FROM w_n_success
                GROUP BY Data
        ) as fc
        WHERE COUNT > (N - 1)
    )

    SELECT * FROM w_res;
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
--     CALL pr_lucky_days_for_checks(1);
--     FETCH ALL IN "cursor";
-- END;

-- -------------------------------------------- --

/**
* @brief 14.  Find the peer with the highest amount of XP
*
*/
CREATE OR REPLACE PROCEDURE pr_peer_max_xp(
    IN cursor refcursor DEFAULT 'cursor'
) AS $$
DECLARE
BEGIN
   OPEN cursor FOR
        WITH sum_list AS (
            SELECT peers.nickname, SUM(xp.xpamount) AS sum_xp
            FROM peers
                LEFT JOIN Checks ON Checks.peer = peers.nickname
                    LEFT JOIN XP ON XP."Check" = Checks.ID
            GROUP BY peers.nickname)
        SELECT nickname AS peer, sum_XP AS XP
        FROM sum_list
        WHERE sum_XP = (SELECT MAX(sum_XP) FROM sum_list);
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
--     CALL pr_peer_max_xp();
--     FETCH ALL IN "cursor";
-- END;

-- -------------------------------------------- --

/**
* @brief  15. Determine the peers that came before the given time at least N times during the whole time
*               Procedure parameters: time, N number of times .
*               Output format: list of peers
*
*/
CREATE OR REPLACE PROCEDURE pr_arrive_earlier_m_times(
    IN set_time TIME,
    IN m_time INT,
    IN cursor refcursor DEFAULT 'cursor'
) AS $$
DECLARE
BEGIN
   OPEN cursor FOR
        SELECT peer
        FROM timetracking
        WHERE State = 1 AND "Time" < set_time
        GROUP BY Peer
        HAVING COUNT(Peer) >= m_time;
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
--     CALL pr_arrive_earlier_m_times('10:00:00', 1);
--     FETCH ALL IN "cursor";
-- END;


-- -------------------------------------------- --

/**
* @brief 16. Determine the peers who left the campus more than M times during the last N days
*
* Procedure parameters: N number of days , M number of times .
* Output format: list of peers
*/
CREATE OR REPLACE PROCEDURE pr_peers_left_campus(
    IN N INT,
    IN M INT,
    IN cursor refcursor DEFAULT 'cursor'
) AS $$
DECLARE
BEGIN
   OPEN cursor FOR
    SELECT Peer
    FROM (SELECT *
          FROM TimeTracking
          WHERE state = 2
            AND "Date" >= (CURRENT_DATE - (N  || ' days')::INTERVAL)::DATE
            AND "Date" <= CURRENT_DATE
        ) AS q1
    GROUP BY Peer
    HAVING count(State) >= M;

END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------- --

/**
* @brief 17.  Determine for each month the percentage of early entries.
*
* For each month, count how many times people born in that month came to campus during the whole time
*   (we'll call this the total number of entries).
* For each month, count the number of times people born in that month have come to campus before 12:00 in all time
*       (we'll call this the number of early entries).
* For each month, count the percentage of early entries to campus relative to the total number of entries.
* Output format: month, percentage of early entries
*
*/
CREATE OR REPLACE PROCEDURE pr_percent_earlier_arrive(
    IN cursor refcursor DEFAULT 'cursor'
) AS $$
DECLARE
BEGIN
   OPEN cursor FOR
    WITH birthmonth_list AS (
        SELECT nickname, EXTRACT(month FROM birthday) AS birthmonth
        FROM peers),
    early_entry AS (
        SELECT COUNT(*) AS num, birthmonth
        FROM (SELECT peer, "Date", birthmonth
            FROM timetracking
            JOIN birthmonth_list ON timetracking.peer = birthmonth_list.nickname
            WHERE State = 1 AND EXTRACT(month FROM "Date") = birthmonth
            GROUP BY peer, "Date", birthmonth) AS num_bithmonth
        GROUP BY birthmonth),
    all_early_entry_before_12 AS (
        SELECT COUNT(*) AS all_num, birthmonth
        FROM (SELECT peer, "Date", birthmonth
            FROM timetracking
            JOIN birthmonth_list ON timetracking.peer = birthmonth_list.nickname
            WHERE State = 1 AND
            EXTRACT(month FROM "Date") = birthmonth AND
            "Time" < '12:00:00'
            GROUP BY peer, "Date", birthmonth) AS all_num_birthmonth
        GROUP BY birthmonth)
    SELECT (
        CASE WHEN early_entry.birthmonth = 1 THEN 'January'
        WHEN early_entry.birthmonth = 2 THEN 'February'
        WHEN early_entry.birthmonth = 3 THEN 'March'
        WHEN early_entry.birthmonth = 4 THEN 'April'
        WHEN early_entry.birthmonth = 5 THEN 'May'
        WHEN early_entry.birthmonth = 6 THEN 'June'
        WHEN early_entry.birthmonth = 7 THEN 'July'
        WHEN early_entry.birthmonth = 8 THEN 'August'
        WHEN early_entry.birthmonth = 9 THEN 'September'
        WHEN early_entry.birthmonth = 10 THEN 'October'
        WHEN early_entry.birthmonth = 11 THEN 'November'
        ELSE 'December'
        END) AS Month, ((all_early_entry_before_12.all_num * 100) / early_entry.num)::real AS EarlyEntries
    FROM early_entry
    JOIN all_early_entry_before_12 ON early_entry.birthmonth = all_early_entry_before_12.birthmonth
    GROUP BY early_entry.birthmonth, all_early_entry_before_12.all_num, early_entry.num;
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
--     CALL pr_percent_earlier_arrive();
--     FETCH ALL IN "cursor";
-- END;

