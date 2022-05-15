# Setting up the game servers, game bots, and load simulation

* Deploy k8s cluster [game-k8s-specs/eksctl-cluster.sh](game-k8s-specs/eksctl-cluster.sh)
* Set up node (EC2 instances) cluster autoscaler using Karpneter
* Allow IAM access to the Karpneter node role TBD: provide specific IAM inline policy
* Deploy CW container insights, fleunt-bit for exporting game logs to OpenSearch
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

