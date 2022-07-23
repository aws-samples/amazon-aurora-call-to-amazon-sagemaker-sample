#!/bin/bash

while true
do
  psql -A -e -t -c "select avg(bigint_null_10),sum(bigint_nonull_3) from orders_sorted where updated_at > getdate() - '30 hour'::INTERVAL and updated_at < getdate() - '9.9995 hour'::INTERVAL and idempotency_key<(select max(idempotency_key) from orders_sorted) and idempotency_key>(select max(idempotency_key)-(random() * 100000 + 1)::int from orders_sorted);"
  echo "psql select orders_sorted  exit code="$?
  psql -A -e -t -c "select avg(bigint_null_10),sum(bigint_nonull_3) from orders_old where updated_at > getdate() - '30 hour'::INTERVAL and updated_at < getdate() - '9.9995 hour'::INTERVAL and idempotency_key<(select max(idempotency_key) from orders_sorted) and idempotency_key>(select max(idempotency_key)-(random() * 100000 + 1)::int from orders_sorted);"
  echo "psql select orders_old  exit code="$?
  psql -A -e -t -c "select count(*),text_notnull_1 from orders_old where updated_at > getdate() - '30 hour'::INTERVAL and updated_at < getdate() - '9.9995 hour'::INTERVAL group by text_notnull_1;"
  echo "psql select orders_old exit code="$?
done
