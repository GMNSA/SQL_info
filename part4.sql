-- 1) Создать хранимую процедуру, которая, не уничтожая базу данных, уничтожает все те таблицы текущей базы данных, имена которых начинаются с фразы 'TableName'.

-- 1) Create a stored procedure that, without destroying the database, destroys all those tables in the current database whose names begin with the phrase 'TableName'.

-- CREATE TABLE TableName_TEST1 (
--     name1 TEXT,
--     name2 TEXT
-- );
--
-- CREATE TABLE TableName_TEST2 (
--     name1 TEXT,
--     name2 TEXT
-- );
--
-- CREATE TABLE TableName_TEST3 (
--     name1 TEXT,
--     name2 TEXT
-- );
--
-- CREATE TABLE Testing_Table1 (
--     name1 TEXT,
--     name2 TEXT
-- );
--
-- CREATE TABLE Testing_Table2 (
--     name1 TEXT,
--     name2 TEXT
-- );
--
-- CREATE TABLE Testing_Table3 (
--     name1 TEXT,
--     name2 TEXT
-- );

DROP PROCEDURE IF EXISTS pr_drop_tables CASCADE;

CREATE OR REPLACE PROCEDURE pr_drop_tables(
    IN TableName TEXT DEFAULT 'TableName'
) AS $$
DECLARE
BEGIN

    FOR TableName IN (SELECT table_name
                        FROM information_schema.tables
                        WHERE table_name ~* ('^' || LOWER(TableName))
                        AND table_schema LIKE 'public')

    LOOP
        RAISE NOTICE 'DROP: %', TableName;
        EXECUTE 'DROP TABLE IF EXISTS ' || TableName || ' CASCADE';
    END LOOP;
--
END;
$$ LANGUAGE plpgsql;

-- CALL pr_drop_tables('TableName');
-- CALL pr_drop_tables('Testing_table');

-- -------------------------------------------- --

-- 2) Создать хранимую процедуру с выходным параметром, которая выводит список имен и параметров всех скалярных SQL функций пользователя в текущей базе данных. Имена функций без параметров не выводить. Имена и список параметров должны выводиться в одну строку. Выходной параметр возвращает количество найденных функций.

-- 2) Create a stored procedure with an output parameter that outputs a list of names and parameters of all scalar user's SQL functions in the current database. Do not output function names without parameters. The names and the list of parameters must be in one string. The output parameter returns the number of functions found.

-- 1. list_name of
-- 2. parameters all scalar sql functions

DROP PROCEDURE IF EXISTS pr_get_functions_scalar CASCADE;

CREATE OR REPLACE PROCEDURE pr_get_functions_scalar(
    num_functions OUT INT,
    function_list OUT TEXT

) AS $$
DECLARE
    f_name TEXT;
    f_param TEXT;
    rec RECORD;
BEGIN
    num_functions := 0;
    function_list := '';

    FOR rec IN
        SELECT pg_proc.proname AS function_name, pg_get_function_arguments(pg_proc.oid) AS function_params
        FROM pg_proc
                 JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE pg_namespace.nspname = 'public'
          AND pg_proc.proargtypes = ''
        LOOP
            f_name := rec.function_name;
            f_param := rec.function_params;

            -- Only include functions with parameters
            IF f_param != '' THEN
                num_functions := num_functions + 1;
                function_list := function_list || f_name || '(' || f_param || '), ';
            END IF;
        END LOOP;

    -- Remove trailing comma and space from function list
    function_list := SUBSTRING(function_list, 1, LENGTH(function_list) - 2);

END;
$$ LANGUAGE plpgsql;

-- DO
-- $$
--     DECLARE
--         num_functions INT;
--         function_list TEXT;
--     BEGIN
--         CALL pr_get_functions_scalar(num_functions, function_list);
--         RAISE NOTICE 'Found % scalar functions: %', num_functions, function_list;
--     END
-- $$;
--

-- -------------------------------------------- --

/*
3) Создать хранимую процедуру с выходным параметром, которая уничтожает все SQL DML триггеры в текущей базе данных.
Выходной параметр возвращает количество уничтоженных триггеров.
*/
DROP PROCEDURE IF EXISTS pr_remove_triggers CASCADE;

CREATE OR REPLACE PROCEDURE pr_remove_triggers(OUT count bigint)
LANGUAGE plpgsql
AS $$
DECLARE name_of_trigger varchar; table_of_trigger varchar;
BEGIN
    SELECT DISTINCT COUNT(trigger_name)
    INTO count
    FROM information_schema.triggers;
    FOR name_of_trigger, table_of_trigger IN
        (SELECT DISTINCT trigger_name, event_object_table FROM information_schema.triggers)
    LOOP
        EXECUTE CONCAT('DROP TRIGGER ', name_of_trigger, ' ON ', table_of_trigger);
    END LOOP;
END
$$;

-- CALL pr_remove_triggers(NULL);
-- SELECT trigger_name FROM information_schema.triggers;


-- -------------------------------------------- --

/*
4) Создать хранимую процедуру с входным параметром, которая выводит имена и описания типа объектов
(только хранимых процедур и скалярных функций), в тексте которых на языке SQL встречается строка, задаваемая параметром процедуры.
*/

-- DROP PROCEDURE IF EXISTS pr_proc_name_and_type CASCADE;
CREATE OR REPLACE PROCEDURE pr_proc_name_and_type(
    IN name TEXT,
    IN cursor refcursor DEFAULT 'cursor'
) AS $$
BEGIN
    OPEN cursor FOR
        SELECT routine_name, routine_type
        FROM information_schema.routines
        WHERE routines.specific_schema = 'public' AND routine_definition LIKE CONCAT('%', name, '%');
END;
$$ LANGUAGE plpgsql;

-- BEGIN;
--     CALL pr_proc_name_and_type('peer', 'cursor');
--     FETCH ALL IN "cursor";
-- END;
