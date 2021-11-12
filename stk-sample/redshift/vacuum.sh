#!/bin/bash


export PGHOST=$DB_HOST
export PGPASSWORD=$DB_PASSWORD
export PGUSER=$DB_USER

while true
do
  psql -A -e -t -c "vacuum sort only orders_sorted to 100 percent;"
  echo "psql vacuum orders_sorted exit code="$?
  psql -A -e -t -c "vacuum sort only orders to 100 percent;"
  echo "psql vacuum orders exit code="$?
  sleep `awk -v min=10 -v max=20 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'`
done
