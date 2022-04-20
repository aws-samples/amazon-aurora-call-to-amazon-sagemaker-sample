import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Script generated for node S3 bucket
S3bucket_node1 = glueContext.create_dynamic_frame.from_catalog(
    database="stk-zynga",
    table_name="stk_zyngastructured",
    transformation_ctx="S3bucket_node1",
)

# Script generated for node ApplyMapping
ApplyMapping_node2 = ApplyMapping.apply(
    frame=S3bucket_node1,
    mappings=[
        ("created_at", "string", "created_at", "string"),
        ("m_ticks", "long", "m_ticks", "long"),
        ("m_kart_id", "long", "m_kart_id", "long"),
        ("m_action", "long", "m_action", "long"),
        ("m_value", "long", "m_value", "long"),
        ("m_value_l", "long", "m_value_l", "long"),
        ("m_value_r", "long", "m_value_r", "long"),
        ("country", "string", "country", "string"),
        ("partition_0", "string", "year", "string"),
        ("partition_1", "string", "month", "string"),
        ("partition_2", "string", "day", "string"),
        ("partition_3", "string", "hour", "string"),
    ],
    transformation_ctx="ApplyMapping_node2",
)

dynamic_frame_with_less_partitions=ApplyMapping_node2.coalesce(5)

# Script generated for node S3 bucket
S3bucket_node3 = glueContext.getSink(
    path="s3://stk-zynga/compressed-parquet/",
    connection_type="s3",
    updateBehavior="UPDATE_IN_DATABASE",
    partitionKeys=["year", "month", "day"],
    compression="snappy",
    enableUpdateCatalog=True,
    transformation_ctx="S3bucket_node3",
)
S3bucket_node3.setCatalogInfo(
    catalogDatabase="stk-zynga", catalogTableName="compressed-parquet"
)
S3bucket_node3.setFormat("glueparquet")
S3bucket_node3.writeFrame(dynamic_frame_with_less_partitions)


S3bucket_node4 = glueContext.getSink(
    path="s3://stk-zynga/repartition-parquet/",
    connection_type="s3",
    updateBehavior="UPDATE_IN_DATABASE",
    partitionKeys=["country","year", "month"],
    compression="snappy",
    enableUpdateCatalog=True,
    transformation_ctx="S3bucket_node4",
)
S3bucket_node4.setCatalogInfo(
    catalogDatabase="stk-zynga", catalogTableName="repartition-parquet"
)
S3bucket_node4.setFormat("glueparquet")
S3bucket_node4.writeFrame(dynamic_frame_with_less_partitions)

job.commit()
