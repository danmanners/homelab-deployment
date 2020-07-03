# PostgreSQL Management Container

This container will create a database, new user, and assign the user to the database.

The required environment variables are:

```yaml
PGHOST: Postgres Host
PGDEFDEB: Postgres Default Database
PGROOTUSER: Postgres Default Username
PGPASSWORD:  Postgres Default Password
NEWDBNAME: New Database Name
NEWDBUSER: New Database Username
NEWDBPASS: New Database Password
```
