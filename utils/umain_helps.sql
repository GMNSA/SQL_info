-- # --------------- # FOR TEST # --------------# --
CREATE OR REPLACE FUNCTION fn_print(text)
RETURNS void AS
$$
BEGIN
  RAISE INFO '%', $1;
END;
$$
LANGUAGE plpgsql;
-- -------------------------------------------- --
CREATE OR REPLACE FUNCTION fn_next_id(table_name TEXT, OUT id BIGINT) AS
$$
BEGIN
    EXECUTE format('SELECT COALESCE(MAX(ID) + 1, 1) FROM %s', table_name)
    INTO id;
END;
$$ language plpgsql;
-- -------------------------------------------- --
CREATE OR REPLACE FUNCTION fn_max_id(table_name TEXT, OUT id BIGINT) AS
$$
BEGIN
    EXECUTE format('SELECT MAX(ID) FROM %s', table_name)
    INTO id;
END;
$$ language plpgsql;
