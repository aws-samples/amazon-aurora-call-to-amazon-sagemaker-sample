#!/bin/bash

kubectl delete -f game-k8s-specs/stk-server-match.yaml
kubectl delete -f game-k8s-specs/stk-client-match.yaml
kubectl delete -f game-k8s-specs/appsimulator.yaml

eksctl delete -f /game-k8s-specs/eksctl-cluster.sh

cdk destroy
