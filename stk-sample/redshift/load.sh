#!/bin/bash

export PGHOST=$DB_HOST
export PGPASSWORD=$DB_PASSWORD
export PGUSER=$DB_USER

csv_file="/tmp/"$RANDOM".csv"
s3_dest="s3://apg-export/"$csv_file

psql -t -f generate_series.sql > $csv_file
echo "psql generate_series.sql exit code="$?
aws s3 cp $csv_file $s3_dest
echo "aws s3 cp exit code="$?
psql -A -t -c "copy orders from '$s3_dest' iam_role 'arn:aws:iam::584416962002:role/dms-access-for-endpoint' timeformat 'YYYY-MM-DD HH:MI:SS' maxerror as 250;"
echo "psql copy from s3 exit code="$?
