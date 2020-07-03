#!/bin/ash
# This script creates the requested database and user on a remote Postgres Database.
cat <<EOF > creation.sql
create database $NEWDBNAME;
create user $NEWDBUSER with encrypted password '$NEWDBPASS';
alter role $NEWDBUSER with encrypted password '$NEWDBPASS';
grant all privileges on database $NEWDBNAME to $NEWDBUSER;
EOF
# Logic taken directly from here: https://medium.com/coding-blocks/creating-user-database-and-adding-access-on-postgresql-8bfcd2f4a91e
# Log into the Postgres database and run the commands.
psql -h "$PGHOST" -p "5432" -U $PGROOTUSER -d postgres -f creation.sql
