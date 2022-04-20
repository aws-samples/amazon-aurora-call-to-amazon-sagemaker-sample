# Amazon Aurora and Amazon ML Services Sample

This is sample demonstrates a tool that helps organizations to easily access ML services deployed on Amazon SageMaker or Amazon Comprehend. In this sample we use multiple sources such as customer care, order system, financial systems to train, deploy a model and use it to predict business outcomes. Each source may need a different algorithm, e.g. linear regression for classified data, anomaly detection for unclassified data and we’d want to reconcile them.

The following are examples that demonstrate the aurora-ml connector

## The cheating problem in gaming
### [Cheating in MMO game sample](./multi-model-cheat-in-gaming) demonstrates a multi-model example 
### [Detecting bots in high-frequency game](./data-ingestion-from-k8s-and-train) demonstrates a realtime ingestion of application events to postgresql that used for training a model 
### [mlops customer churn sample](./mlops-customer-churn) demonstrates Continuous Learning with SageMaker AutoML 
