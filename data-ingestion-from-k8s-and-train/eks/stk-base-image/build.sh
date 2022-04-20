#!/bin/bash
region="us-west-2"
repo="supertuxkart"
ver="arm10"

repo_url='public.ecr.aws/p9d8y1e7/'$repo:$ver

cd stk-code/cmake_build/
make -j$(nproc) SERVER_ONLY=ON

cd ../../

aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
docker build -t $repo:$ver .
docker tag $repo:$ver $repo_url
docker push $repo_url
