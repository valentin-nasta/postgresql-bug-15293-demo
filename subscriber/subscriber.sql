CREATE TABLE test
(
    id  SERIAL PRIMARY KEY,
    msg TEXT NOT NULL
);
-- noinspection SqlResolve @ publication/"testpub"

CREATE SUBSCRIPTION testsub CONNECTION 'host=db_publisher port=5432 dbname=test user=postgres password=abc' PUBLICATION testpub;

CREATE OR REPLACE FUNCTION notify_channel() RETURNS trigger AS
$$
BEGIN
    RAISE LOG 'Notify Triggered, %', tg_op;
    PERFORM pg_notify('testchannel', 'Testing');
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS trig_test_changed ON TEST;
CREATE TRIGGER trig_test_changed
    AFTER INSERT OR UPDATE OR DELETE
    ON test
    FOR EACH ROW
EXECUTE
    PROCEDURE notify_channel();

ALTER TABLE test
    ENABLE ALWAYS TRIGGER trig_test_changed;

-- noinspection SqlResolve @ database/"test"

ALTER DATABASE test SET log_statement = 'all';

LISTEN testchannel;
