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
SELECT * FROM aws_s3.query_export_to_s3('select s_location,s_track,s_tracktheme,s_mode,s_difficulty,p_location,p_track,p_tracktheme,p_mode,p_difficulty,p_skill,EXTRACT(MINUTE FROM session_length) as session_length from server_sessions where session_length is not null and p_skill is not null', :'s3_uri_1', options :='header true,format csv, delimiter $$,$$');
```
We want sessions records that are already closed i.e., `session_length` populated. 


#### Train the model using autopilot. Use session_length as the target parameter 

#####TODO automate with cdk to create the autopilot training job

### Allow Aurora call the SageMaker realtime inference endpoint

#### Create the IAM role Aurora will assume to call SageMaker realtime endpoint
```bash
aws iam create-role --role-name rds-sagemaker-role-matchmaking \
--assume-role-policy-document "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"rds.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"
```

#### Create the policy that allows calling Sagemaker realtime inference endpoint
```bash
aws iam create-policy \
   --policy-name rds-sagemaker-tmatchmaking-policy \
   --policy-document '{
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "invokeendpoint",
         "Action": "sagemaker:InvokeEndpoint",
         "Effect": "Allow",
         "Resource": "*"
       }
     ] 
   }'     
```

#### attach the role to the policy
```bash
aws iam attach-role-policy --role-name rds-sagemaker-role-matchmaking --policy-arn $(aws iam list-policies --query 'Policies[?PolicyName==`rds-sagemaker-tmatchmaking-policy`].Arn' --output text)
```

#### Configure the IAM role that allows aurora db cluster invoke realtime sagemaker endpoints.

aws rds add-role-to-db-cluster --db-cluster-identifier $dbid \
--role-arn $(aws iam list-roles --query 'Roles[?RoleName==`rds-sagemaker-role-matchmaking`].Arn' --output text) --feature-name SageMaker

#### Wait for the changes to take affect in the db

```bash
aws rds describe-db-clusters --db-cluster-identifier $dbid \
--query 'DBClusters[*].[Status]' --output text
```
```bash
aws rds describe-db-clusters --db-cluster-identifier $dbid \
--query 'DBClusters[*].[AssociatedRoles]' --output table
```

#### Create the postgres function that calls the Sagemaker inference endpoint

At this point, we have a sagemaker realtime endpoint ready, let `stk-matchmaker5` be the name of the endpoint. 
Note: the order of columns in the function MUST match the order set in the training data (see section :'Export the training data to S3' above) 

```sql
CREATE EXTENSION IF NOT EXISTS aws_ml CASCADE;
drop function estimate_session_length;
create function estimate_session_length(
in s_location CHAR(16),
in s_track CHAR(24),
in s_tracktheme CHAR(24),
in s_mode CHAR(24),
in s_difficulty INT8,
in p_difficulty INT8,
in p_location CHAR(16),
in p_track CHAR(24),
in p_tracktheme CHAR(24),
in p_mode CHAR(24),
in p_skill CHAR(24),
max_rows_per_batch INT DEFAULT NULL,
out estimate VARCHAR) 
AS $$
   select aws_sagemaker.invoke_endpoint('stk-matchmaker5',NULL,
    s_location,s_track,s_tracktheme,s_mode,s_difficulty,
    p_difficulty,p_location,p_track,p_tracktheme,p_mode,p_skill)::VARCHAR
   $$ LANGUAGE SQL PARALLEL SAFE COST 5000;
```

#### Call the endpoint with new match requests 

```sql
select estimate_session_length(s_location,s_track,s_tracktheme,s_mode,s_difficulty,p_difficulty,p_location,p_track,p_tracktheme,p_mode,p_skill) from server_sessions;
```

Our supertuxkart simulation [calls](../game-cdk/game-server/linux-aarch64/serverfiles/start-client.sh) the model for the predicted availiable game server that predicated to provide maximum session length. 

Before you play or watch game getting played (1) download the [game client](https://supertuxkart.net/Download); and (2) discover availiable server by executing:

```sql
select endpoint,is_active,updated_at from sessions where updated_at < NOW() - '1 min'::INTERVAL order by updated_at desc;
```

Simply use one of the `endpoint` and enter it in the "Enter server address" screen.
