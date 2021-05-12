ALTER SYSTEM SET wal_level = 'logical';

CREATE TABLE test
(
    id  SERIAL PRIMARY KEY,
    msg TEXT NOT NULL
);

CREATE PUBLICATION testpub FOR TABLE test;
