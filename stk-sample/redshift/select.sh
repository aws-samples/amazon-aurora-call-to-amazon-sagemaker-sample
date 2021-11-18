#!/bin/bash


export PGHOST=$DB_HOST
export PGPASSWORD=$DB_PASSWORD
export PGUSER=$DB_USER

while true
do
  psql -A -e -t -c "select avg(bigint_null_10),sum(bigint_nonull_3) from orders_sorted where updated_at > getdate() - '30 hour'::INTERVAL and updated_at < getdate() - '9.9995 hour'::INTERVAL and idempotency_key<(select max(idempotency_key) from orders) and idempotency_key>(select max(idempotency_key)-(random() * 100000 + 1)::int from orders_sorted);"
  echo "psql select orders_sorted  exit code="$?
  psql -A -e -t -c "select avg(bigint_null_10),sum(bigint_nonull_3) from orders where updated_at > getdate() - '30 hour'::INTERVAL and updated_at < getdate() - '9.9995 hour'::INTERVAL and idempotency_key<(select max(idempotency_key) from orders) and idempotency_key>(select max(idempotency_key)-(random() * 100000 + 1)::int from orders);"
  echo "psql select orders_sorted  exit code="$?
  psql -A -e -t -c "select count(*),text_notnull_1 from orders where updated_at > getdate() - '30 hour'::INTERVAL and updated_at < getdate() - '9.9995 hour'::INTERVAL;"
  echo "psql select orders exit code="$?
done
