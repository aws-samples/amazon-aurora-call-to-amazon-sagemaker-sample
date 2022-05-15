## Deploy aurora pg cluster

####TODO - convert provisioned apg to serverless v2

1. Ensure CDK is installed
```
$ npm install -g aws-cdk
```

2. Create a Python virtual environment
```
$ python3 -m venv .venv
```

3. Activate virtual environment

```
$ source .venv/bin/activate
```

4. Install the required dependencies.

```
$ pip install -r requirements.txt
```

5. Bootstrap the AWS environment

Use `aws sts get-caller-identity --query Account --output text` for getting the account number

```
AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`
AWS_REGION=us-west-2
cdk bootstrap aws://$AWS_ACCOUNT_ID/$AWS_REGION
```

6. Synthesize (`cdk synth`) or deploy (`cdk deploy`) the example

```
$ cdk deploy
```

### To dispose of the stack afterwards:

```
$ cdk destroy
```
