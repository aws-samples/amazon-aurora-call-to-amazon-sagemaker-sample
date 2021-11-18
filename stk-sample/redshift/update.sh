#!/bin/bash


export PGHOST=$DB_HOST
export PGPASSWORD=$DB_PASSWORD
export PGUSER=$DB_USER

while true
do
  #psql -A -e -t -c "update orders set updated_at=getdate() where substring(text_notnull_1,1,10) like '%'||substring(md5(RANDOM()::TEXT),1,10)||'%';"
  psql -A -e -t -c "update orders set updated_at=getdate() where idempotency_key<(select max(idempotency_key) from orders) and idempotency_key>(select max(idempotency_key)-(random() * 100000 + 1)::int from orders);"
  echo "psql update exit code="$?
done
