#!/usr/bin/env python3

from aws_cdk import (
    aws_stepfunctions as _aws_stepfunctions,
    aws_stepfunctions_tasks as _aws_stepfunctions_tasks,
    aws_stepfunctions as sfn,
    aws_ecr as ecr,
    aws_s3 as aws_s3,
    aws_lambda as _lambda,
    App, Duration, Stack
)

class SMStack(Stack):
  def __init__(self, app: App, id: str, **kwargs) -> None:
    super().__init__(app, id, **kwargs)

    bucket = aws_s3.Bucket(self, "aurora_ml")
    # need to copy the model.tar.gz to the bucket
    create_model = _aws_stepfunctions_tasks.SageMakerCreateModel(self, "Sagemaker",
      model_name="aurora-ml-churn",
      primary_container=_aws_stepfunctions_tasks.ContainerDefinition(
        image=_aws_stepfunctions_tasks.DockerImage.from_registry("246618743249.dkr.ecr.us-west-2.amazonaws.com/sagemaker-sklearn-automl:2.5-1-cpu-py3"),
        mode=_aws_stepfunctions_tasks.Mode.SINGLE_MODEL,
        model_s3_location=_aws_stepfunctions_tasks.S3Location.from_bucket(bucket,"/model.tar.gz")
      )#,
      #containers=[
      #  _aws_stepfunctions_tasks.ContainerDefinition(
      #  image=_aws_stepfunctions_tasks.DockerImage.from_registry("174872318107.dkr.ecr.us-west-2.amazonaws.com/mxnet-algorithms:inference-cpu"),
      #  mode=_aws_stepfunctions_tasks.Mode.SINGLE_MODEL,
      #  model_s3_location=_aws_stepfunctions_tasks.S3Location.from_bucket(bucket,"/sagemaker/DEMO-autopilot-churn/output/automl-churn-04-21-04-53/tuning/automl-chu-dpp9-mlp/automl-churn-04-21-04-53BBz55kvP-006-3e2cb1e8/output/model.tar.gz")
      #  ),
      #  _aws_stepfunctions_tasks.ContainerDefinition(
      #  image=_aws_stepfunctions_tasks.DockerImage.from_registry("246618743249.dkr.ecr.us-west-2.amazonaws.com/sagemaker-sklearn-automl:2.5-1-cpu-py3"),
      #  mode=_aws_stepfunctions_tasks.Mode.SINGLE_MODEL,
      #  model_s3_location=_aws_stepfunctions_tasks.S3Location.from_bucket(bucket,"/output/automl-churn-04-21-04-53/data-processor-models/automl-churn-04-21-04-53-dpp9-1-3e12858ef21c4d309a803adb5e2cd58/output/model.tar.gz")
      #  )
      #]
    )
 
    wait_job = _aws_stepfunctions.Wait(
      self, "Wait 30 Seconds",
      time=_aws_stepfunctions.WaitTime.duration(
      Duration.seconds(30))
    )    
    fail_job = _aws_stepfunctions.Fail(
      self, "Fail",
      cause='AWS Batch Job Failed',
      error='DescribeJob returned FAILED'
    )
    succeed_job = _aws_stepfunctions.Succeed(
      self, "Succeeded",
      comment='AWS Batch Job succeeded'
    )

    # Create Chain
    #definition = create_model.next(wait_job)
    #  .when(_aws_stepfunctions.Condition.string_equals('$.status', 'FAILED'), fail_job)
    #  .when(_aws_stepfunctions.Condition.string_equals('$.status', 'SUCCEEDED'), succeed_job)
    #  .otherwise(wait_job))

    # Create state machine
    sm = _aws_stepfunctions.StateMachine(
      self, "StateMachine",
      definition=create_model,
      timeout=Duration.minutes(5))

app = App()
SMStack(app, "aurora-ml")
app.synth()
