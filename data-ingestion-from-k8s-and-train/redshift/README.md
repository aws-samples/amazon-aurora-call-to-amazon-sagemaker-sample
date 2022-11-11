# Using secrets with k8s worksloads in EKS

We show two primary methods for consuming secrets: 
* 1/[As container environment variable](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables)
* 2/[As files in a volume mounted on one or more of its containers](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod)

The first method does not encrypt the secret, it merely encode it and relay on the transport layer encryption to secure it. Once stored in k8s masters, EKS use KMS key to encrypt at reast. The application consumes it via environment variable. 

##### Pros/Cons 
`+` Simple, only need `echo` the secret within the deployed pod.

`+` No need for specific permission to access within the namespace the application is deployed i.e., the namespace default service account

`-` Flat secret structure i.e., no nested strucutre tha might needed with high-level languages like Java, C#, Ruby and Go

`-` No rotation 

`-` Stored locally or require extra tool if stored in git e.g. Sealed secrets


Second option uses AWS Secret Manager for encrypting at transit (from app to store and back) and at rest. Secrets are mounted as files and parsed by the application. The access to the secrets requires explicit [IRSA](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html) that limits the access to the secrets for only a granted k8s services accounts unlike the default service account. 

Also, high-level langaugaes can use it with AWS SDK. e.g.,

```python
get_secret_value_response = client.get_secret_value(
            SecretId=secret_name)
```

##### Pros/Cons 
`+` Secure to the serviceaccount level i.e., smaller blast radius

`+` Allowing nested structure e.g., json

`+` Portable i.e., supports the CSI driver so can work with other secrets managers

`+` Support rotation from AWS secrets manager and not redeploying the secret for each namesapce

`=` Requires knowledge 

`+` Not limited to only k8s but supports other high-level lanaguges


For first option (1) we need to have the secrets stored in flat file like

```bash
$cat stk-redshift-creds.secrets
PGHOST=myhost
PGDATABASE=dev
PGUSER=myuser
PGPASSWORD=mypass
```

```bash
kubectl create secret generic  stk-redshift-creds --namespace=default --from-env-file=stk-redshift-creds.secrets
```
more in [create-secrets.sh](./create-secrets.sh)

To deploy the secrets you need to reference it in the pod spec e.g.,

```yaml
      - name: appselect
        envFrom:
          - secretRef:
              name: stk-redshift-creds
```
Once the [spec](./select.yaml) is deployed

For the CSI driver options (2) we need to 

* 2.1/ Create the secret in AWS secret store

```bash
aws --region secretsmanager \
  create-secret --name stk-redshift-creds-csi \
  --secret-string '{PGHOST=myhost,PGDATABASE=dev,PGUSER=myuser,PGPASSWORD=mypass}'
```

* 2.2/ Create IRSA to limit the access to the secret i.e., IAM policy scoping the accessi (`secretsmanager:GetSecretValue` and `secretsmanager:DescribeSecret` to the secret and associate it with `iamserviceaccount`

```bash
IAM_POLICY_ARN_SECRET=$(aws iam \
	create-policy --query Policy.Arn \
    --output text --policy-name $IAM_POLICY_NAME_SECRET \
    --policy-document '{
    "Version": "2012-10-17",
    "Statement": [ {
        "Effect": "Allow",
        "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        "Resource": ["'"$SECRET_ARN"'" ]
    } ]
}')
``` 

```bash
eksctl create iamserviceaccount \
    --name "nappselectcsi-deployment-sa" \
    --cluster "$EKS_CLUSTERNAME" \
    --attach-policy-arn "$IAM_POLICY_ARN_SECRET" --approve \
    --override-existing-serviceaccounts
```

more in [stk-redshift-creds-csi-create-iamserviceaccount.sh](./stk-redshift-creds-csi-create-iamserviceaccount.sh)

* 2.3/ Create SecretProviderClass to define secretsmanager as the secret porvider

```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: stk-redshift-creds-csi
spec:
  provider: aws
  parameters:
    objects: |
        - objectName: "stk-redshift-creds-csi"
          objectType: "secretsmanager"
```

* 2.4/ Create pod and mount secrets

```yaml
       volumeMounts:
        - name: secrets-store-inline
          mountPath: "/mnt/secrets"
          readOnly: true
      ...
      volumes:
      - name: secrets-store-inline
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: stk-redshift-creds-csi
```

* 2.5/ Access the secret from within the pod

```bash
kubectl exec appselectcsi-75d9df79ff-xrbwc -- cat /mnt/secrets/stk-redshift-creds-csi
{PGHOST=myhost,PGDATABASE=dev,PGUSER=myuser,PGPASSWORD=mypass}
```
