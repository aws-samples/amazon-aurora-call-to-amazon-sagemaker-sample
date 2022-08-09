#!/bin/bash

/kafka_2.12-2.6.2/bin/kafka-console-producer.sh --broker-list $BootstrapServerString --producer.config client.properties --topic $topic

