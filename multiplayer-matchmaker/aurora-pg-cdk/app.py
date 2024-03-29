#!/usr/bin/env python3

import os
from aws_cdk import (
    aws_ec2 as ec2,
    aws_rds as rds,
    App,RemovalPolicy,Stack,Environment
)


class RDSStack(Stack):
  def __init__(self, app: App, id: str, **kwargs) -> None:
    super().__init__(app, id, **kwargs)

    vpc = ec2.Vpc(self, "VPC")

    cluster = rds.DatabaseCluster(self, "craft-usw2",
      engine=rds.DatabaseClusterEngine.aurora_postgres(version=rds.AuroraPostgresEngineVersion.VER_13_6),
      credentials=rds.Credentials.from_generated_secret("postgres"),  # Optional - will default to 'admin' username and generated password
      instance_props=rds.InstanceProps(
        instance_type=ec2.InstanceType.of(ec2.InstanceClass.BURSTABLE4_GRAVITON, ec2.InstanceSize.LARGE),
        #instance_type=ec2.InstanceType.of(ec2.InstanceClass.MEMORY6_GRAVITON,ec2.InstanceSize.LARGE),
        vpc_subnets=ec2.SubnetSelection(subnet_type=ec2.SubnetType.PUBLIC),
        vpc=vpc
      )
    )

app = App()
#RDSStack(app, "aurora-ml-pg")
env = Environment(
    account=os.environ.get(
        "CDK_DEPLOY_ACCOUNT", os.environ.get("CDK_DEFAULT_ACCOUNT")
    ),
    region=os.environ.get(
        "CDK_DEPLOY_REGION", os.environ.get("CDK_DEFAULT_REGION")
    ),
)
RDSStack(app, "craft",env=env)
app.synth()
