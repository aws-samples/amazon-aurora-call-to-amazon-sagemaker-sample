#!/bin/bash


export PGHOST=$DB_HOST
export PGPASSWORD=$DB_PASSWORD
export PGUSER=$DB_USER

while true
do
  psql -A -e -t -c "select avg(bigint_null_10),sum(bigint_nonull_3) from orders_sorted where updated_at > getdate() - '30 hour'::INTERVAL and updated_at < getdate() - '9.9995 hour'::INTERVAL group by timestamp_null_27;"
  echo "psql select from orders_sorted exit code="$?
  psql -A -e -t -c "select avg(bigint_null_10),sum(bigint_nonull_3) from orders where updated_at > getdate() - '30 hour'::INTERVAL and updated_at < getdate() - '9.9995 hour'::INTERVAL group by timestamp_null_27;"
  echo "psql select from orders exit code="$?
  sleep `awk -v min=10 -v max=20 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'`
done
