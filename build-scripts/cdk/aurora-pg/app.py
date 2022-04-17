#!/usr/bin/env python3

from aws_cdk import (
    aws_ec2 as ec2,
    aws_rds as rds,
    App, RemovalPolicy, Stack
)

class RDSStack(Stack):
  def __init__(self, app: App, id: str, **kwargs) -> None:
    super().__init__(app, id, **kwargs)

    vpc = ec2.Vpc(self, "VPC")

    cluster = rds.DatabaseCluster(self, "db",
    engine=rds.DatabaseClusterEngine.aurora_postgres(version=rds.AuroraPostgresEngineVersion.VER_13_4),
    credentials=rds.Credentials.from_generated_secret("postgres"),  # Optional - will default to 'admin' username and generated password
    instance_props=rds.InstanceProps(
        #instance_type=ec2.InstanceType.of(ec2.InstanceClass.BURSTABLE4_GRAVITON, ec2.InstanceSize.LARGE),
        instance_type=ec2.InstanceType.of(ec2.InstanceClass.MEMORY_INTENSIVE_2_GRAVITON2,ec2.InstanceSize.LARGE),
        vpc_subnets=ec2.SubnetSelection(subnet_type=ec2.SubnetType.PRIVATE),
        vpc=vpc,
        publicly_accessible=True
    )
)

app = App()
RDSStack(app, "aurora-ml-pg")
app.synth()
