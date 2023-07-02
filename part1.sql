DROP PROCEDURE IF EXISTS pr_import_data_from_csv;
DROP PROCEDURE IF EXISTS pr_export_data_from_csv;

DROP TABLE IF EXISTS TimeTracking CASCADE;
DROP TABLE IF EXISTS XP CASCADE;
DROP TABLE IF EXISTS Recommendations CASCADE;
DROP TABLE IF EXISTS Friends CASCADE;
DROP TABLE IF EXISTS TransferredPoints CASCADE;
DROP TABLE IF EXISTS Verter CASCADE;
DROP TABLE IF EXISTS P2P CASCADE;
DROP TABLE IF EXISTS Checks CASCADE;
DROP TABLE IF EXISTS Tasks CASCADE;
DROP TABLE IF EXISTS Peers CASCADE;

-- SET client_min_messages = 'debug';
SET client_min_messages = 'notice';

-- # --------------- # TYPES # --------------# --

/**
* @brief Type for checking the status.
*
* @param 'Start'   -> The check starts.
* @param 'Success' -> Successful completion of the check.
* @param 'Failure' -> Unsuccessful completion of the check.
*
* @return          -> ENUMERATION TYPE
*/
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'check_status') THEN
    CREATE TYPE check_status AS ENUM ('Start', 'Success', 'Failure');
  ELSE
    RAISE DEBUG 'Type check_status already exists\n';
  END IF;
END $$;

-- # --------------- # TABLES # --------------# --

CREATE TABLE IF NOT EXISTS Peers (
    Nickname TEXT PRIMARY KEY NOT NULL,
    Birthday DATE             NOT NULL
);
-- -------------------------------------------- --
CREATE TABLE IF NOT EXISTS Tasks (
    Title      TEXT PRIMARY KEY NOT NULL,
    ParentTask TEXT,
    MaxXP      BIGINT           NOT NULL,
    FOREIGN KEY (ParentTask) REFERENCES Tasks (Title)
);
-- -------------------------------------------- --
CREATE TABLE IF NOT EXISTS Checks (
    ID     BIGINT PRIMARY KEY NOT NULL,
    Peer   TEXT               NOT NULL,
    Task   TEXT               NOT NULL,
    "Date" DATE               NOT NULL,
    FOREIGN KEY (Task) REFERENCES Tasks (Title)
);
-- -------------------------------------------- --
CREATE TABLE IF NOT EXISTS P2P (
    ID              BIGINT PRIMARY KEY NOT NULL,
    "Check"         BIGINT             NOT NULL,
    CheckingPeer    TEXT               NOT NULL,
    State           check_status       NOT NULL,
    "Time"          TIME               NOT NULL,
    FOREIGN KEY ("Check")        REFERENCES Checks (ID),
    FOREIGN KEY (CheckingPeer)   REFERENCES Peers (Nickname)
);
-- -------------------------------------------- --
CREATE TABLE IF NOT EXISTS Verter (
    ID      BIGINT PRIMARY KEY NOT NULL,
    "Check" BIGINT             NOT NULL,
    State   check_status       NOT NULL,
    "Time"  TIME               NOT NULL,
    FOREIGN KEY ("Check") REFERENCES Checks (ID)
);
-- -------------------------------------------- --
CREATE TABLE IF NOT EXISTS TransferredPoints (
    ID           BIGINT PRIMARY KEY NOT NULL,
    CheckingPeer TEXT               NOT NULL,
    CheckedPeer  TEXT               NOT NULL,
    PointsAmount BIGINT             NOT NULL,
    FOREIGN KEY (CheckingPeer) REFERENCES Peers (Nickname),
    FOREIGN KEY (CheckedPeer)  REFERENCES Peers (Nickname)
);
-- -------------------------------------------- --
CREATE TABLE IF NOT EXISTS Friends (
    ID    BIGINT PRIMARY KEY NOT NULL,
    Peer1 TEXT,
    Peer2 TEXT,
    FOREIGN KEY (Peer1) REFERENCES Peers (Nickname),
    FOREIGN KEY (Peer2) REFERENCES Peers (Nickname)
);
-- -------------------------------------------- --
CREATE TABLE IF NOT EXISTS Recommendations (
    ID BIGINT PRIMARY KEY NOT NULL,
    Peer TEXT             NOT NULL,
    RecommendedPeer TEXT,
    FOREIGN KEY (Peer) REFERENCES Peers (Nickname),
    FOREIGN KEY (RecommendedPeer) REFERENCES Peers (Nickname)
);
-- -------------------------------------------- --
CREATE TABLE IF NOT EXISTS XP (
    ID       BIGINT PRIMARY KEY NOT NULL,
    "Check"  BIGINT             NOT NULL,
    XPAmount BIGINT,
    FOREIGN KEY (ID) REFERENCES Checks (ID)
);
-- -------------------------------------------- --
CREATE TABLE IF NOT EXISTS TimeTracking (
    ID     BIGINT PRIMARY KEY        NOT NULL,
    Peer   TEXT                      NOT NULL,
    "Date" DATE DEFAULT CURRENT_DATE NOT NULL,
    "Time" TIME DEFAULT CURRENT_TIME NOT NULL,
    State  SMALLINT                  NOT NULL CHECK (State IN (1, 2)),
    FOREIGN KEY (Peer) REFERENCES Peers (Nickname)
);

-- # --------------- # FUNCTIONS # --------------- # --

CREATE OR REPLACE PROCEDURE pr_import_data_from_csv(
    tablename TEXT,
    filepath  TEXT,
    sep       CHAR(1) DEFAULT ';'
) AS $$
DECLARE
    sql_query TEXT;
BEGIN
    sql_query := FORMAT(
            'COPY %s FROM %L WITH (FORMAT CSV, HEADER, DELIMITER %L)',
            tablename,
            filepath,
            sep
         );
    EXECUTE sql_query;
    RAISE DEBUG 'Data import from csv file %s\n', filepath;
END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------- --

CREATE OR REPLACE PROCEDURE pr_export_data_from_csv(
    tablename TEXT,
    filepath  TEXT DEFAULT '/var/lib/postgres/WORK/SQL2_Info21_v1.0-0/src/export_csv/',
    sep       CHAR(1) DEFAULT ';'
) AS $$
DECLARE
    sql_query TEXT;
BEGIN
    sql_query := FORMAT(
            'COPY %s TO %L WITH (FORMAT CSV, HEADER, DELIMITER %L)',
            tablename,
            filepath,
            sep
         );
    EXECUTE sql_query;
    RAISE DEBUG 'Data exported from csv file %s', filepath;
END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------- --

CREATE OR REPLACE FUNCTION fn_trg_timetracking_insert()
RETURNS TRIGGER AS $$
DECLARE
    stat int := (SELECT State FROM TimeTracking
                    WHERE TimeTracking.Peer = NEW.Peer
                    ORDER BY "Date" DESC, "Time" DESC LIMIT 1);

BEGIN
    IF (stat = NEW.State) THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;

END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------- --

CREATE OR REPLACE FUNCTION fn_trg_recommendations_insert()
RETURNS TRIGGER AS $$
DECLARE
    is_find_except_peer BOOL := ((SELECT COUNT(*) FROM Recommendations
            WHERE NEW.Peer = Recommendations.Peer AND
                  NEW.RecommendedPeer = Recommendations.RecommendedPeer) > 0);
BEGIN
    IF (NEW.Peer = NEW.RecommendedPeer OR is_find_except_peer) THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------- --

CREATE OR REPLACE FUNCTION fn_trg_friends_insert()
RETURNS TRIGGER AS $$
DECLARE
    is_find_except_friend BOOL := (SELECT COUNT(*) FROM Friends
                        WHERE ((NEW.Peer1 = Peer2 AND NEW.Peer2 = Peer1) OR
                              (Peer1 = NEW.Peer1  AND Peer2 = NEW.Peer2))
                     ) > 0;

BEGIN
    IF (NEW.Peer1 = NEW.Peer2 OR is_find_except_friend) THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;

END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------- --

CREATE OR REPLACE FUNCTION fn_trg_transferred_points_insert()
RETURNS TRIGGER AS $$
DECLARE

BEGIN
    UPDATE TransferredPoints SET PointsAmount = (PointsAmount + 1) WHERE
        TransferredPoints.CheckedPeer = NEW.CheckedPeer AND
        TransferredPoints.CheckingPeer = NEW.CheckingPeer;

    IF FOUND THEN
        return NULL;
    ELSE
        return NEW;
    END IF;

END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------- --

CREATE OR REPLACE FUNCTION fn_trg_p2p_insert1()
RETURNS TRIGGER AS $$
DECLARE
    is_not_finded_checking_start BOOL := (SELECT CheckingPeer FROM P2P
        WHERE P2P."Check" = new."Check" AND P2P.State = 'Start'
        ORDER BY 1 DESC LIMIT 1
    ) != new.CheckingPeer;
BEGIN
    IF NEW.State = 'Start' THEN
            return NEW;
    ELSE
        IF is_not_finded_checking_start THEN
            return NULL;
        ELSE
            return NEW;
        END IF;
    END IF;

END;
$$ LANGUAGE plpgsql;
-- -------------------------------------------- --
CREATE OR REPLACE FUNCTION fn_trg_p2p_insert2()
RETURNS TRIGGER AS $$
DECLARE
    n_1 INT := (SELECT COUNT(*) FROM P2P
                JOIN Checks ON P2P."Check" = Checks.ID
                WHERE NEW."Check" = Checks.ID AND NEW.CheckingPeer = P2P.CheckingPeer
            );
    n_2 INT := (SELECT COUNT(*) FROM P2P
                JOIN Checks ON P2P."Check" = Checks.ID
                WHERE NEW."Check" = Checks.ID
            );
BEGIN
    IF ((n_1 % 2 != 0) AND NEW.State = 'Start') OR
       ((n_1 % 2 = 0) AND NEW.State != 'Start') THEN
        return NULL;
    ELSEIF n_2 >= 2 THEN
        return NULL;
    ELSE
        return NEW;
    END IF;

END;
$$ LANGUAGE plpgsql;
-- -------------------------------------------- --

CREATE OR REPLACE FUNCTION fn_trg_verter_insert()
RETURNS TRIGGER AS $$
DECLARE
    n_success_p2p BOOL := (SELECT COUNT(*) FROM P2P
        WHERE P2P.State = 'Success' AND
              P2P."Check" = NEW."Check"
    ) > 0;

    n_check_ver INT := (SELECT COUNT(*) FROM Verter
        JOIN P2P ON NEW."Check" = P2P."Check"
        WHERE NEW."Check" = Verter."Check"
    );

BEGIN
    IF n_success_p2p IS FALSE THEN
        return NULL;
    ELSEIF n_check_ver = 0 THEN
        IF NEW.State = 'Start' THEN
            return NEW;
        ELSE
            return NULL;
        END IF;
    ELSEIF n_check_ver <= 2 AND NEW.State != 'Start' THEN
        return NEW;
    ELSE
        return NULL;
    END IF;

END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------- --

CREATE OR REPLACE FUNCTION fn_trg_checks_insert()
RETURNS TRIGGER AS $$
DECLARE
    ptask TEXT := (SELECT ParentTask FROM Tasks WHERE Tasks.Title = NEW.Task);

    is_success BOOL := (
        SELECT COUNT(*) FROM P2P
            FULL JOIN Checks ON P2P."Check" = Checks.ID
            FULL JOIN Verter ON Verter."Check" = Checks.ID
        WHERE
            Checks.Peer = NEW.Peer   AND
            Checks.Task = ptask      AND
            P2P.State = 'Success'    AND
            (Verter.State = 'Success' OR Verter.State IS NULL)
    ) = 0;

BEGIN

    IF ptask IS NULL THEN
        return NEW;
    ELSEIF is_success THEN
        return NULL;
    ELSE
        return NEW;
    END IF;

END;
$$ LANGUAGE plpgsql;


-- # --------------- # USE PROCEDURES (IMPORT data) # --------------- # --

do
$create_tables$
BEGIN

CALL pr_import_data_from_csv('Peers',
    'TESTINGpeers_date.csv',
    ';'
);

CALL pr_import_data_from_csv('Tasks',
    'TESTINGtasks_date.csv',
    ';'
);

CALL pr_import_data_from_csv('Checks',
    'TESTINGchecks_date.csv',
    ';'
);

CALL pr_import_data_from_csv('P2P',
    'TESTINGp2p_date.csv',
    ';'
);

CALL pr_import_data_from_csv('Verter',
    'TESTINGverter_date.csv',
    ';'
);

CALL pr_import_data_from_csv('TransferredPoints',
    'TESTINGtransferredpoints_date.csv',
    ';'
);

CALL pr_import_data_from_csv('Friends',
    'TESTINGfriends_date.csv',
    ';'
);

CALL pr_import_data_from_csv('Recommendations',
    'TESTINGrecommendations_date.csv',
    ';'
);

CALL pr_import_data_from_csv('XP',
    'TESTINGxp_date.csv',
    ';'
);

CALL pr_import_data_from_csv('TimeTracking',
    'TESTINGtimetracking_date.csv',
    ';'
);

END;
$create_tables$;

-- do
-- $create_tables$
-- BEGIN
--
-- CALL pr_export_data_from_csv('Peers',
--     'TROLOLOpeers_date.csv',
--     ';'
-- );
--
-- CALL pr_export_data_from_csv('Tasks',
--     'TROLOLOtasks_date.csv',
--     ';'
-- );
--
-- CALL pr_export_data_from_csv('Checks',
--     'TROLOLOchecks_date.csv',
--     ';'
-- );
--
-- CALL pr_export_data_from_csv('P2P',
--     'TROLOLOp2p_date.csv',
--     ';'
-- );
--
-- CALL pr_export_data_from_csv('Verter',
--     'TROLOLOverter_date.csv',
--     ';'
-- );
--
-- CALL pr_export_data_from_csv('TransferredPoints',
--     'TROLOLOtransferredpoints_date.csv',
--     ';'
-- );
--
-- CALL pr_export_data_from_csv('Friends',
--     'TROLOLOfriends_date.csv',
--     ';'
-- );
--
-- CALL pr_export_data_from_csv('Recommendations',
--     'TROLOLOrecommendations_date.csv',
--     ';'
-- );
--
-- CALL pr_export_data_from_csv('XP',
--     'TROLOLOxp_date.csv',
--     ';'
-- );
--
-- CALL pr_export_data_from_csv('TimeTracking',
--     'TROLOLOtimetracking_date.csv',
--     ';'
-- );
--
-- END;
-- $create_tables$;

-- # --------------- # TRIGGERS  # --------------# --

CREATE TRIGGER trg_timetracking_insert
BEFORE INSERT ON TimeTracking
FOR EACH ROW
EXECUTE PROCEDURE fn_trg_timetracking_insert();
-- -------------------------------------------- --
CREATE TRIGGER trg_recommendations_insert
BEFORE INSERT ON Recommendations
FOR EACH ROW
EXECUTE PROCEDURE fn_trg_recommendations_insert();
-- -------------------------------------------- --
CREATE TRIGGER trg_friends_insert
BEFORE INSERT ON Friends
FOR EACH ROW
EXECUTE PROCEDURE fn_trg_friends_insert();
-- -------------------------------------------- --
CREATE TRIGGER trg_transferred_points_insert
BEFORE INSERT ON TransferredPoints
FOR EACH ROW
EXECUTE PROCEDURE fn_trg_transferred_points_insert();
-- -------------------------------------------- --
CREATE TRIGGER trg_p2p_insert1
BEFORE INSERT ON P2P
FOR EACH ROW
EXECUTE PROCEDURE fn_trg_p2p_insert1();
-- -------------------------------------------- --
CREATE TRIGGER trg_p2p_insert2
BEFORE INSERT ON P2P
FOR EACH ROW
EXECUTE PROCEDURE fn_trg_p2p_insert2();
-- -------------------------------------------- --
CREATE TRIGGER trg_verter_insert
BEFORE INSERT ON Verter
FOR EACH ROW
EXECUTE PROCEDURE fn_trg_verter_insert();
-- -------------------------------------------- --
CREATE TRIGGER trg_checks_insert
BEFORE INSERT ON Checks
FOR EACH ROW
EXECUTE PROCEDURE fn_trg_checks_insert();

-- # --------------- # OUTPUT TABLES # --------------- # --

--  SELECT * FROM Tasks            LIMIT 20;
-- SELECT * FROM Checks            LIMIT 20;
-- SELECT * FROM P2P ORDER BY "Check" LIMIT 20;
-- SELECT * FROM Verter            LIMIT 20;
-- SELECT * FROM TransferredPoints LIMIT 20;
-- SELECT * FROM Friends           LIMIT 20;
-- SELECT * FROM Recommendations   LIMIT 20;
-- SELECT * FROM XP                LIMIT 20;
-- SELECT * FROM TimeTracking      LIMIT 20;


