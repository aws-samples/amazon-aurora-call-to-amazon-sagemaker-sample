#!/bin/bash

while true
do
  psql -A -e -t -c "select count(*) from tablea;"
  echo "psql select count(*) from tablea exit code="$?

  psql -A -e -t -c "select count(*) from tableb;"
  echo "psql select count(*) from tableb exit code="$?
  
  sleep 5
done
