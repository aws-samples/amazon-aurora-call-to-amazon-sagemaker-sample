aws secretsmanager  create-secret --name stk-redshift-creds-csi \
  --secret-string '{PGHOST=pgbouncer-14d32ab567b83e8f.elb.us-west-2.amazonaws.com,PGDATABASE=dev,PGUSER=postgres,PGPASSWORD=Admin1234!}'
