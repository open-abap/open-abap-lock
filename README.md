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

## Todo

* `_scope`
* `wait` flag
* `mode`
* release at commit work if update task
