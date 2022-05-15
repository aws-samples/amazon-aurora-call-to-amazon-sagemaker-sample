# Setting up your aurora db, s3 and sagemaker

## [create the aurora database cluster](../aurora-pg-cdk)

## Allow aurora to export to S3 for autopilot

#### Create IAM role that allows role to assume a role for writing to S3 buckets

``` bash
aws iam create-role \
   --role-name rds-s3-export-role-matchmaking \
   --assume-role-policy-document '{
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
            "Service": "rds.amazonaws.com"
          },
         "Action": "sts:AssumeRole"
       }
     ] 
   }'  
```
#### Create the IAM policy that allows writing to S3

```bash
aws iam create-policy \
   --policy-name rds-s3-export-policy \
   --policy-document '{
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "s3import",
         "Action": [
           "s3:PutObject"
         ],
         "Effect": "Allow",
         "Resource": [
           "arn:aws:s3:::*",
           "arn:aws:s3:::*/*"
         ] 
       }
     ] 
   }'     
```

#### attach the role to the policy
```bash
aws iam attach-role-policy --role-name rds-s3-export-role-matchmaking --policy-arn $(aws iam list-policies --query 'Policies[?PolicyName==`rds-s3-export-policy`].Arn' --output text)
```

#### Get the aurora cluster identifier- we assume one apg cluster in the account, pls add filter if you have more than one cluster. 
```bash
export dbid=`aws rds describe-db-clusters --query DBClusters[].DBClusterIdentifier --output text`
```

#### Configure the IAM role that allows writing to S3 to the aurora db cluster. Note: the feature name MUST be s3Export, otherwise you will need to modify the db cluster parameters.
```bash
aws rds add-role-to-db-cluster \
   --db-cluster-identifier $dbid \
   --feature-name s3Export \
   --role-arn $(aws iam list-roles --query 'Roles[?RoleName==`rds-s3-export-role-matchmaking`].Arn' --output text)   \
   --region us-west-2
```

#### Wait for the changes to take affect in the db

```bash
aws rds describe-db-clusters --db-cluster-identifier $dbid \
--query 'DBClusters[*].[Status]' --output text
```
```bash
aws rds describe-db-clusters --db-cluster-identifier $dbid \
--query 'DBClusters[*].[AssociatedRoles]' --output table
```

#### Create the S3 bucket to export the data into and create the URI in the database session

We use the bucket `stk-matchmaking` and uri(sub directory) `server_sessions_may_export` in the bucket

```sql
SELECT aws_commons.create_s3_uri(
   'stk-matchmaking',
   'server_sessions_may_export',
   'us-west-2'
) AS s3_uri_1 \gset
```

#### Export the training data to S3

```sql
SELECT * FROM aws_s3.query_export_to_s3('select s_location,s_track,s_tracktheme,s_mode,s_difficulty,p_location,p_track,p_tracktheme,p_mode,p_difficulty,EXTRACT(MINUTE FROM session_length) from server_sessions where session_length is not null and p_skill is not null', :'s3_uri_1', options :='header true,format csv, delimiter $$,$$');
```
We want sessions records that are already closed i.e., `session_length` populated. 
