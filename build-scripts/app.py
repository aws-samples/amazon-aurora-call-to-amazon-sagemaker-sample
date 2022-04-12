#!/usr/bin/env python3

import time
import os
from sagemaker import get_execution_role, session
import boto3
from aws_cdk import App, Environment, Fn

vpc_name="aws-controltower-VPC"
sg="sg-0fb220c9a34b5438c"
execution_role_arn="arn:aws:iam::212076617619:role/service-role/AmazonSageMaker-ExecutionRole-20220331T142126"
container1_image="public.ecr.aws/p9d8y1e7/sagemaker-sklearn-automl:2.5-1-cpu-py3"
container1_model_data_url="s3://sagemaker-studio-k4u9t44y3hq/container1_model_data.tar.gz"
container2_image="public.ecr.aws/p9d8y1e7/sagemaker-xgboost:1.3-1-cpu-py3"
container2_model_data_url="s3://sagemaker-studio-k4u9t44y3hq/container2_model_data.tar.gz"
container3_image="public.ecr.aws/p9d8y1e7/sagemaker-sklearn-automl:2.5-1-cpu-py3"
container3_model_data_url="s3://sagemaker-studio-k4u9t44y3hq/container3_model_data.tar.gz"

from aws_cdk import (
    aws_ec2 as ec2,
    aws_s3 as aws_s3,
    aws_sagemaker as sagemaker,
    App, Duration, Stack
)

class SMStack(Stack):
  def __init__(self, app: App, id: str, **kwargs) -> None:
    super().__init__(app, id, **kwargs)
     
    vpc = ec2.Vpc.from_lookup(self,"VPC",vpc_name=vpc_name)
    security_group=ec2.SecurityGroup(self, "auroramlsg",vpc=vpc) 
    subnets = vpc.select_subnets(
      subnet_type=ec2.SubnetType.PRIVATE_WITH_NAT
    )
    model = sagemaker.CfnModel(self, "aurora-ml",
      execution_role_arn=execution_role_arn,
      model_name="aurora-ml",
      vpc_config=sagemaker.CfnModel.VpcConfigProperty(
        security_group_ids=[sg],
        subnets=subnets.subnet_ids
      ),
      containers=[sagemaker.CfnModel.ContainerDefinitionProperty(
          container_hostname="container1",
          image=container1_image,
          image_config=sagemaker.CfnModel.ImageConfigProperty(
            repository_access_mode="Vpc"
          ),
          mode="SingleModel",
          model_data_url=container1_model_data_url,
          environment={
            "AUTOML_SPARSE_ENCODE_RECORDIO_PROTOBUF":1,
            "AUTOML_TRANSFORM_MODE":"feature-transform",
            "SAGEMAKER_DEFAULT_INVOCATIONS_ACCEPT":"application/x-recordio-protobuf",
            "SAGEMAKER_PROGRAM":"sagemaker_serve",
            "SAGEMAKER_SUBMIT_DIRECTORY":"/opt/ml/model/code"
          }
        ),
        sagemaker.CfnModel.ContainerDefinitionProperty(
          container_hostname="container2",
          image=container2_image,
          image_config=sagemaker.CfnModel.ImageConfigProperty(
            repository_access_mode="Vpc"
          ),
          mode="SingleModel",
          model_data_url=container2_model_data_url,
          environment={
            "MAX_CONTENT_LENGTH":20971520,
            "SAGEMAKER_DEFAULT_INVOCATIONS_ACCEPT":"text/csv",
            "SAGEMAKER_INFERENCE_OUTPUT":"predicted_label",
            "SAGEMAKER_INFERENCE_SUPPORTED":"predicted_label,probability,probabilities"
          }
        ),
        sagemaker.CfnModel.ContainerDefinitionProperty(
          container_hostname="container3",
          image=container3_image,
          image_config=sagemaker.CfnModel.ImageConfigProperty(
            repository_access_mode="Vpc"
          ),
          mode="SingleModel",
          model_data_url=container3_model_data_url,
          environment={
            "AUTOML_TRANSFORM_MODE":"inverse-label-transform",
            "SAGEMAKER_DEFAULT_INVOCATIONS_ACCEPT":"text/csv",
            "SAGEMAKER_INFERENCE_INPUT":"predicted_label",
            "SAGEMAKER_INFERENCE_OUTPUT":"predicted_label",
            "SAGEMAKER_INFERENCE_SUPPORTED":"predicted_label,probability,labels,probabilities",
            "SAGEMAKER_PROGRAM":"sagemaker_serve",
            "SAGEMAKER_SUBMIT_DIRECTORY":"/opt/ml/model/code"
          }
        ),
      ],
    )
    endpoint_config = sagemaker.CfnEndpointConfig(
      self,
      id="aurora-ml-endpoint-config",
      production_variants=[
        sagemaker.CfnEndpointConfig.ProductionVariantProperty(
          initial_instance_count=1,
          initial_variant_weight=1.0,
          instance_type="ml.m5.xlarge",
          model_name="aurora-ml",
          variant_name="main",
        )
      ],
    )
    endpoint_config.add_depends_on(model)
    endpoint = sagemaker.CfnEndpoint(
      self,
      id= "aurora-ml-endpoint",
      endpoint_config_name=endpoint_config.attr_endpoint_config_name
    )
    print(security_group.security_group_id)

app = App()
env_us=Environment(account="212076617619", region="us-west-2")
SMStack(app,"aurora-ml",env=env_us)
app.synth()
