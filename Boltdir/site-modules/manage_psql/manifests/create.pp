# Creates a Postgres Database & Username.
define manage_psql::create(
  String  $new_db,
  String  $new_db_username,
  String  $new_db_password,
  String  $psql_server,
  String  $psql_username,
  String  $registry_url,
){
  # Run the command to create the Postgres DB and Creation
  exec{"create_new_db_${new_db}_psql":
    command => "/usr/bin/docker run -d --rm \
    -e 'NEWDBNAME=${new_db}' \
    -e 'NEWDBUSER=${new_db_username}' \
    -e 'NEWDBPASS=${new_db_password}' \
    -e 'PGHOST=${psql_server}' \
    -e 'PGROOTUSER=${psql_username}' \
    ${registry_url}"
  }
}
