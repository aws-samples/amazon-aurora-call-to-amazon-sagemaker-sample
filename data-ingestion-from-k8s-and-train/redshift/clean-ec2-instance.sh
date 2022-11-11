#!/bin/bash

nodes=$(kubectl get no| grep NotReady | awk '{print $1}')
for no in $nodes
do
  aws ec2 terminate-instances --instance-ids `aws ec2 describe-instances --filters "Name=private-dns-name,Values=$no" --query "Reservations[].Instances[].InstanceId" --out text`
done
