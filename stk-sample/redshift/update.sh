#!/bin/bash


export PGHOST=$DB_HOST
export PGPASSWORD=$DB_PASSWORD
export PGUSER=$DB_USER

while true
do
  psql -A -e -t -c "update orders set updated_at=getdate() where substring(text_notnull_1,1,10) like '%'||substring(md5(RANDOM()::TEXT),1,10)||'%';"
  echo "psql update exit code="$?
done
