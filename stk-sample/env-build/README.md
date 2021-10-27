### Deploy EKS Cluster to host the gaem server
`eks/stk/eks-cluster-spec.yaml`

### Deploy AWS Load Balancer Controller

per https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
 under `aws-load-balancer-controller`

`curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.0/docs/install/iam_policy.json`

```bash
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

`eksctl utils associate-iam-oidc-provider --region=us-west-2 --cluster=stk-us-west-2 --approve`

```bash
eksctl create iamserviceaccount \
  --cluster=stk-us-west-2 \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::584416962002:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
```

```bash
kubectl apply \
    --validate=false \
    -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml
```

```bash
curl -Lo v2_3_0_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.3.0/v2_3_0_full.yaml
```

modify the cluster name 

```bash
kubectl apply -f v2_3_0_full.yaml 
```

deploy the AWS VPC CNI per https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html

create iamservice account with the CNI policy

```bash
eksctl create iamserviceaccount \
    --name aws-node \
    --namespace kube-system \
    --cluster stk-us-west-2 \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
    --approve \
    --override-existing-serviceaccounts
```

copy the iamserviceaccount arn and add it to `--service-account-role-arn` field below.

```bash
eksctl create addon \
    --name vpc-cni \
    --version latest \
    --cluster stk-us-west-2 \
    --service-account-role-arn arn:aws:iam::584416962002:role/eksctl-stk-us-west-2-addon-iamserviceaccount-Role1-Q199BGXGVQHH \
    --force

eksctl get addon --name vpc-cni --cluster stk-us-west-2
```

### Create ECR to host the image
make sure the base image exists and availible. If not deploy the base image. see build-from-scratch-and-deploy-base-image.md
`eks/stk/ecr-repos.sh`

### Build the image
`eks/stk/build.sh`

### Deploy the game server
`kubectl apply -f eks/stk/stk.yaml`

### Create a firehose Kinesis delivery system 
Use console or cloudfromation. Create s3 bucket for the firehose data. Capture the name of the firehose.

Grant `firehose:PutRecordBatch` IAM permissions to the worker nodes to allow writing to Kinesis

### Deploy the fleunetbit 
Configure `eks/stk/fluentbit-ds-firehose.yaml` 

### Play the game and generate game events

Download Supertuxkart client 

Create online user

Discover your game-server by `kubectl get no -o wide `kubectl get po -o wide| grep stk| awk '{print $7}'`| awk '{print $7":8080"}'`

Run the client = `./SuperTuxKart.app/Contents/MacOS/supertuxkart --network-ai=3 --no-graphics --connect-now=34.219.135.86:8081`

replace the game server address in `--connect-now`  with the value of your cluster nodes

Add bots with `--network-ai` parameter

### Check the s3 bucket for the game events 
