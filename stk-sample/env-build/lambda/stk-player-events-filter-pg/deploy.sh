#!/bin/sh
rm function.zip
cd package
zip -r9 ../function.zip .
cd ../
zip -g function.zip lambda_function.py
aws lambda update-function-code --function-name stk-player-events-loader --zip-file fileb://function.zip

#aws lambda create-function --function-name stk-player-events-loader \
#--zip-file fileb://function.zip --handler lambda_function.lambda_handler  --runtime python3.8 
#--role arn:aws:iam::163538056407:role/service-role/stk-player-events-loader-role-p8mtskv6
