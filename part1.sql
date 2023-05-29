DROP FUNCTION IF EXISTS fn_import_data_from_csv ;
DROP FUNCTION IF EXISTS fn_trg_timetracking_insert CASCADE;

DROP TABLE IF EXISTS TimeTracking;
DROP TABLE IF EXISTS XP;
DROP TABLE IF EXISTS Recommendations;
DROP TABLE IF EXISTS Friends;
DROP TABLE IF EXISTS TransferredPoints;
DROP TABLE IF EXISTS Verter;
DROP TABLE IF EXISTS P2P;
DROP TABLE IF EXISTS Checks;
DROP TABLE IF EXISTS Tasks;
DROP TABLE IF EXISTS Peers;

-- # --------------- # TYPES # --------------# --

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'check_status') THEN
    CREATE TYPE check_status AS ENUM ('Start', 'Success', 'Failure');
  ELSE
    RAISE DEBUG 'Type check_status already exists';
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

CREATE OR REPLACE FUNCTION fn_import_data_from_csv(
    tablename TEXT,
    filepath  TEXT,
    sep       CHAR(1) DEFAULT ';'
) RETURNS VOID AS $$
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
    RAISE DEBUG 'Data import from csv file %s', filepath;
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


-- # --------------- # TRIGGERS  # --------------# --

CREATE TRIGGER trg_timetracking_insert
BEFORE INSERT ON TimeTracking
FOR EACH ROW
EXECUTE PROCEDURE fn_trg_timetracking_insert();
-- -------------------------------------------- --
-- Таблица Tasks
-- Название задания
-- Название задания, являющегося условием входа
-- Максимальное количество XP
-- Чтобы получить доступ к заданию, нужно выполнить задание, являющееся его условием входа. Для упрощения будем считать, что у каждого задания всего одно условие входа. В таблице должно быть одно задание, у которого нет условия входа (т.е. поле ParentTask равно null).

-- CREATE OR REPLACE FUNCTION fnc_trg_check_insert_tasks()
-- RETURNS trigger AS
-- $$
-- DECLARE
--     PT TEXT := (SELECT ParentTask) From Tasks WHERE Title = NEW.Task
-- BEGIN
--
--     IF NOT EXISTS (PT) THEN
--         RETURN NEW;
--     ELSE
--         RETURN NULL;
--     END IF
--
--
-- RETURN N;
--
-- END $$
-- LANGUAGE 'plpgsql';

-- # --------------- # USE FUNCTIONS # --------------- # --

do
$create_tables$
BEGIN

PERFORM fn_import_data_from_csv('Peers',
    '/var/lib/postgres/SQL_info/csv/peers_date.csv',
    ';'
);

PERFORM fn_import_data_from_csv('Tasks',
    '/var/lib/postgres/SQL_info/csv/tasks_date.csv',
    ';'
);

PERFORM fn_import_data_from_csv('Checks',
    '/var/lib/postgres/SQL_info/csv/checks_date.csv',
    ';'
);

PERFORM fn_import_data_from_csv('P2P',
    '/var/lib/postgres/SQL_info/csv/p2p_date.csv',
    ';'
);

PERFORM fn_import_data_from_csv('Verter',
    '/var/lib/postgres/SQL_info/csv/verter_date.csv',
    ';'
);

PERFORM fn_import_data_from_csv('TransferredPoints',
    '/var/lib/postgres/SQL_info/csv/transferredpoints_date.csv',
    ';'
);

PERFORM fn_import_data_from_csv('Friends',
    '/var/lib/postgres/SQL_info/csv/friends_date.csv',
    ';'
);

PERFORM fn_import_data_from_csv('Recommendations',
    '/var/lib/postgres/SQL_info/csv/recommendations_date.csv',
    ';'
);

PERFORM fn_import_data_from_csv('XP',
    '/var/lib/postgres/SQL_info/csv/xp_date.csv',
    ';'
);

PERFORM fn_import_data_from_csv('TimeTracking',
    '/var/lib/postgres/SQL_info/csv/timetracking_date.csv',
    ';'
);

END;
$create_tables$;


-- SELECT * FROM Peers             LIMIT 20;
-- SELECT * FROM Tasks             LIMIT 20;
-- SELECT * FROM Checks            LIMIT 20;
-- SELECT * FROM P2P               LIMIT 20;
-- SELECT * FROM P2P               LIMIT 20;
-- SELECT * FROM Verter            LIMIT 20;
-- SELECT * FROM TransferredPoints LIMIT 20;
-- SELECT * FROM Friends           LIMIT 20;
-- SELECT * FROM Friends           LIMIT 19;
-- SELECT * FROM Recommendations   LIMIT 20;
-- SELECT * FROM XP                LIMIT 20;
-- SELECT * FROM TimeTracking      LIMIT 20;
