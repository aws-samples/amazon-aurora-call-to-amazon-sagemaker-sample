#!/usr/bin/env python3

import time
import os
from sagemaker import get_execution_role, session
import boto3

from aws_cdk import (
    aws_s3 as aws_s3,
    aws_sagemaker as sagemaker,
    App, Duration, Stack
)

class SMStack(Stack):
  def __init__(self, app: App, id: str, **kwargs) -> None:
    super().__init__(app, id, **kwargs)

    model = sagemaker.CfnModel(self, "aurora-ml",
      execution_role_arn="arn:aws:iam::212076617619:role/service-role/AmazonSageMaker-ExecutionRole-20220331T142126",
      model_name="aurora-ml",
      containers=[sagemaker.CfnModel.ContainerDefinitionProperty(
          image="246618743249.dkr.ecr.us-west-2.amazonaws.com/sagemaker-sklearn-automl:2.5-1-cpu-py3",
          mode="SingleModel",
          model_data_url="s3://sagemaker-studio-k4u9t44y3hq/auroraml-churn-endpoint/data-processor-models/auroraml-churn-endpoint-dpp0-1-71ca99eb8e894875ada4a2648ab6b555/output/model.tar.gz",
          environment={
            "AUTOML_SPARSE_ENCODE_RECORDIO_PROTOBUF":1,
            "AUTOML_TRANSFORM_MODE":"feature-transform",
            "SAGEMAKER_DEFAULT_INVOCATIONS_ACCEPT":"application/x-recordio-protobuf",
            "SAGEMAKER_PROGRAM":"sagemaker_serve",
            "SAGEMAKER_SUBMIT_DIRECTORY":"/opt/ml/model/code"
          }
        ),
        sagemaker.CfnModel.ContainerDefinitionProperty(
          image="246618743249.dkr.ecr.us-west-2.amazonaws.com/sagemaker-xgboost:1.3-1-cpu-py3",
          mode="SingleModel",
          model_data_url="s3://sagemaker-studio-k4u9t44y3hq/auroraml-churn-endpoint/tuning/auroraml-c-dpp0-xgb/auroraml-churn-endpointpjftIEpiX-237-a8ba5390/output/model.tar.gz",
          environment={
            "MAX_CONTENT_LENGTH":20971520,
            "SAGEMAKER_DEFAULT_INVOCATIONS_ACCEPT":"text/csv",
            "SAGEMAKER_INFERENCE_OUTPUT":"predicted_label",
            "SAGEMAKER_INFERENCE_SUPPORTED":"predicted_label,probability,probabilities"
          }
        ),
        sagemaker.CfnModel.ContainerDefinitionProperty(
          image="246618743249.dkr.ecr.us-west-2.amazonaws.com/sagemaker-sklearn-automl:2.5-1-cpu-py3",
          mode="SingleModel",
          model_data_url="s3://sagemaker-studio-k4u9t44y3hq/auroraml-churn-endpoint/data-processor-models/auroraml-churn-endpoint-dpp0-1-71ca99eb8e894875ada4a2648ab6b555/output/model.tar.gz",
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

app = App()
SMStack(app, "aurora-ml")
app.synth()
