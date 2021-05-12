# postgresql-bug-15293-demo

start environment
```bash
$ docker-compose build
$ docker-compose up
```

open listener bash tab , keep query select 1 to get the notifications
```bash
vmbp in ~  > docker run --rm -it --name listen --network postgresql-bug-15293-demo_multiservernet postgres:13 bash
root@dc08bf9754cd:/# PGPASSWORD=abc psql -h db_subscriber -Upostgres test
psql (13.2 (Debian 13.2-1.pgdg100+1))
Type "help" for help.

test=# LISTEN testchannel;
LISTEN
test=# select 1;
 ?column?
----------
        1
(1 row)

Asynchronous notification "testchannel" with payload "asd" received from server process with PID 43.
test=#
```
open sender bash tab to test the channel
```bash
vmbp in ~  > docker run --rm -it --name sender --network postgresql-bug-15293-demo_multiservernet postgres:13 bash
root@0daf29d221d4:/# PGPASSWORD=abc psql -h db_subscriber -Upostgres test -c "select pg_notify('testchannel', 'asd');"
 pg_notify
-----------

(1 row)

root@0daf29d221d4:/#
```

test insert/update operations on sender
```bash
root@0daf29d221d4:/# PGPASSWORD=abc psql -h db_publisher -Upostgres test -c "insert into test values (1, 'a');"
root@0daf29d221d4:/# PGPASSWORD=abc psql -h db_publisher -Upostgres test -c "update test set msg='b' where id=1;"
```

no notification is raised on subscriber until channel is "pinged"
```bash
root@0daf29d221d4:/# PGPASSWORD=abc psql -h db_subscriber -Upostgres test -c "select pg_notify('testchannel', 'asd');"
```

listener tab:
```text
test=# select 1;
 ?column?
----------
        1
(1 row)

Asynchronous notification "testchannel" with payload "Testing" received from server process with PID 94.
Asynchronous notification "testchannel" with payload "asd" received from server process with PID 105.
```