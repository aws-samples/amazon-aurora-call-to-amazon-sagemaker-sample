#!/bin/bash


export PGHOST=$DB_HOST
export PGPASSWORD=$DB_PASSWORD
export PGUSER=$DB_USER

while true
do
  psql -A -e -t -c "update orders set updated_at=getdate()-(random() * 3 + 1)::int,TEXT_NOTNULL_1=MD5(random()::text)||MD5(random()::text)||MD5(random()::text)||MD5(random()::text) WHERE IDEMPOTENCY_KEY<(SELECT MAX(IDEMPOTENCY_KEY)-10000000 FROM ORDERS) AND IDEMPOTENCY_KEY>(SELECT max(idempotency_key)-(random() * 100000 + 1)::int-10000000 from orders);"
  echo "psql update exit code="$?
done
