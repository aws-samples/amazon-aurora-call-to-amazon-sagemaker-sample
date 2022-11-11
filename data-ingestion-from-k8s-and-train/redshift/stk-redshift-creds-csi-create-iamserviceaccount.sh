#!/bin/bash -x

IAM_POLICY_NAME_SECRET="stk_redshift_creds_csi_secrets_policy_$RANDOM"
IAM_POLICY_ARN_SECRET=$(aws --region "$AWS_REGION" iam \
	create-policy --query Policy.Arn \
    --output text --policy-name $IAM_POLICY_NAME_SECRET \
    --policy-document '{
    "Version": "2012-10-17",
    "Statement": [ {
        "Effect": "Allow",
        "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        "Resource": ["arn:aws:secretsmanager:us-west-2:584416962002:secret:stk-redshift-creds-csi-JAKp4Q" ]
    } ]
}')
echo $IAM_POLICY_ARN_SECRET | tee -a 00_iam_policy_arn_dbsecret
eksctl utils associate-iam-oidc-provider \
    --region="$AWS_REGION" --cluster=arm-us-west-2 \
    --approve

eksctl create iamserviceaccount \
    --region="$AWS_REGION" --name "appselectcsi-deployment-sa"  \
    --cluster arm-us-west-2 \
    --attach-policy-arn "$IAM_POLICY_ARN_SECRET" --approve \
    --override-existing-serviceaccounts
