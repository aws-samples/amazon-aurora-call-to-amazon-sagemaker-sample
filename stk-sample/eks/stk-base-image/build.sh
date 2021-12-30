#!/bin/bash
region="us-west-2"
repo="supertuxkart"
repo_url='public.ecr.aws/p9d8y1e7/'$repo

aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
docker build -t $repo:arm .
docker tag $repo:arm $repo_url
docker push $repo_url
