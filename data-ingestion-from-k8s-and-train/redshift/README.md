# Using secrets with k8s worksloads

We show two primary methods for consuming secrets: 
* [As container environment variable](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables)
* [As files in a volume mounted on one or more of its containers](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod)

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

