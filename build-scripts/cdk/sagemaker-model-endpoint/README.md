## Running Examples

### To run example
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

```
cdk bootstrap aws://123456789012/us-east-1
```

6. Synthesize (`cdk synth`) or deploy (`cdk deploy`) the example

```
$ cdk deploy
```

### To dispose of the stack afterwards:

```
$ cdk destroy
```
