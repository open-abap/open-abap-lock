# open-abap-lock

Concurrent/cross session locking for Open ABAP.

Requires and works with PostgreSQL as the database backend, and only on the DEFAULT connection.

## Notes

* [PostgreSQL - Advisory Locks](https://www.postgresql.org/docs/current/explicit-locking.html#ADVISORY-LOCKS)
* [PostgreSQL - Advisory Lock Functions](https://www.postgresql.org/docs/9.1/functions-admin.html#FUNCTIONS-ADVISORY-LOCKS)

wildcards?
scope?
release on crash
table `pg_locks`

1: get advisory lock
2: insert into custom lock table with session id + info

3: delete from custom lock table
4: release advisory lock

on conflict: double check the advisory lock still exists, if not the custom lock table is out of sync, so delete the row and try again

new db table for custom locks with:

* username
* datetime, utc
* hostname
* lock mode
* lock name
* table name
* lock key

## TODO

* _scope
* wait flag
* mode
* relase at commit work if update task
