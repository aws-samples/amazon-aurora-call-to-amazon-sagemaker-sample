#!/bin/bash

account=$(aws sts get-caller-identity --output text --query Account)

aws rds modify-db-cluster-parameter-group \
  --db-cluster-parameter-group-name AllowAWSAccessToExternalServices \
  --parameters "ParameterName=aws_default_s3_role,ParameterValue=arn:aws:iam::$account:role/AllowAuroraS3Role,ApplyMethod=pending-reboot" \
  --parameters "ParameterName=aws_default_sagemaker_role,ParameterValue=arn:aws:iam::$account:role/AllowAuroraSageMakerRole,ApplyMethod=pending-reboot" \
  --parameters "ParameterName=aws_default_comprehend_role,ParameterValue=arn:aws:iam::$account:role/AllowAuroraComprehendRole,ApplyMethod=pending-reboot"


aws rds modify-db-cluster --db-cluster-identifier stk --db-cluster-parameter-group-name AllowAWSAccessToExternalServices 
aws rds failover-db-cluster --db-cluster-identifier stk

#REBOOT THE DB TO GET THIS GROUP APPLIED
