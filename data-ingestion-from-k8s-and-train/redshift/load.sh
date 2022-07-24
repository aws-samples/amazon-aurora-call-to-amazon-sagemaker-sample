#!/bin/bash

csv_file="/tmp/"$RANDOM".csv"
s3_dest="s3://stk-zynga/tmp/"$csv_file


while true
do
  export PGHOST=orders1.cenp1vur9574.us-west-2.redshift.amazonaws.com
  psql -t -f generate_series_table.sql > $csv_file
  echo "psql generate_series.sql exit code="$?
  aws s3 cp $csv_file $s3_dest
  echo "aws s3 cp exit code="$?
  psql -A -t -c "copy tablea from '$s3_dest' iam_role 'arn:aws:iam::584416962002:role/dms-access-for-endpoint' timeformat 'YYYY-MM-DD HH:MI:SS' maxerror as 250;"
  echo "psql copy tablea from s3 exit code="$?

  export PGHOST=orders2.cenp1vur9574.us-west-2.redshift.amazonaws.com
  psql -t -f generate_series_table.sql > $csv_file
  echo "psql generate_series.sql exit code="$?
  aws s3 cp $csv_file $s3_dest
  echo "aws s3 cp exit code="$?
  psql -A -t -c "copy tableb from '$s3_dest' iam_role 'arn:aws:iam::584416962002:role/dms-access-for-endpoint' timeformat 'YYYY-MM-DD HH:MI:SS' maxerror as 250;"
  echo "psql copy tableb from s3 exit code="$?
done
