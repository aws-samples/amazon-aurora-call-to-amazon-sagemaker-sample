FROM public.ecr.aws/lambda/java:latest-arm64
RUN yum -y update
RUN yum install -y wget tar net-tools curl vim unzip less
RUN wget https://archive.apache.org/dist/kafka/2.6.2/kafka_2.12-2.6.2.tgz && \
    tar -xzf kafka_2.12-2.6.2.tgz
COPY ./consume.sh /consume.sh
COPY ./client.properties /client.properties
