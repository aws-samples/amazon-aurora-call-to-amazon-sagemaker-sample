eksctl create iamserviceaccount \
    --name appsimulator \
    --namespace default \
    --cluster arm-stk-us-west-2 \ 
    --attach-policy-arn arn:aws:iam::584416962002:policy/appsimulator \
    --approve \
    --override-existing-serviceaccounts
