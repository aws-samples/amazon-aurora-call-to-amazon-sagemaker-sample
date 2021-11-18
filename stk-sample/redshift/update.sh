#!/bin/bash


export PGHOST=$DB_HOST
export PGPASSWORD=$DB_PASSWORD
export PGUSER=$DB_USER

while true
do
  psql -A -e -t -c "update orders set updated_at=getdate() where idempotency_key<(select max(idempotency_key)-10000000 from orders) and idempotency_key>(select max(idempotency_key)-(random() * 100000 + 1)::int-10000000 from orders);"
  echo "psql update exit code="$?
done
