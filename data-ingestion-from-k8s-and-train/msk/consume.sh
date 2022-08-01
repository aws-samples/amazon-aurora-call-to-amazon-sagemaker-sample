#!/bin/bash

/kafka_2.12-2.6.2/bin/kafka-console-consumer.sh --bootstrap-server $BootstrapServerString --consumer.config client.properties --topic $topic --from-beginning

