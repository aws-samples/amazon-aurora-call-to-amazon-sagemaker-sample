### Deploy EKS Cluster to host the gaem server
`eks/stk/eks-cluster-spec.yaml`

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

