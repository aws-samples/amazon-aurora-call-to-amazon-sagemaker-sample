# Setting up the game servers, game bots, and load simulation

* Deploy k8s cluster [game-k8s-specs/eksctl-cluster.sh](game-k8s-specs/eksctl-cluster.sh)
* Set up node (EC2 instances) cluster autoscaler using [Karpneter](https://karpenter.sh/v0.10.0/getting-started/getting-started-with-eksctl/). We used [this Provisioner spec](./game-k8s-specs/karpenter-provisioner-controller-aarch64.yaml)
* Allow IAM access to the Karpneter node role TBD: provide specific IAM inline policy
* Deploy [CW container insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy-container-insights-EKS.html), fleunt-bit for [exporting game logs to OpenSearch](https://www.eksworkshop.com/intermediate/230_logging/)
* Populate the database cradentials, pull the secrets from secret manager and populate [game-k8s-specs/db-creds.secrets](game-k8s-specs/db-creds.secrets)
execute:
```bash
game-k8s-specs/db-creds-create.sh 
```
* Deploy game server cdk to create game server, game client and the load simulator docker images
[game-cdk/README.md](game-cdk/README.md). 

* Deploy game server
`kubectl apply -f game-k8s-specs/stk-server-match.yaml`

* Deploy game client
`kubectl apply -f game-k8s-specs/stk-client-match.yaml`

* Deploy the appsimulator
`kubectl apply -f game-k8s-specs/appsimulator.yaml`

