#!/usr/bin/env bash

# requires single argument, stop/start
# if we are on an instance which hosts only Zookeeper, without Kafka, zkonly file should be present

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/env.sh

ZKDELALL="$DIR/../python/zkDelAll.py"

if [ "$1" == "stop" ]; then
    # shutdown kafka
    if [ ! -f zkonly ]; then
        for pid in `ps aux | grep [k]afka.logs.dir | awk '{print $2}' | tr '\n' ' '`; do kill -s 9 $pid; done
    fi

    # remove all data from zookeeper
    if [ -f zkonly ]; then
        python $ZKDELALL /
    fi

    # remove Kafka's data dir
    if [ ! -f zkonly ]; then
        rm -rf $KAFKA_DATA
    fi

    # create folders for new data
    if [ ! -f zkonly ]; then
        mkdir -p $KAFKA_DATA
    fi
fi

if [ "$1" == "start" ]; then
    # start Kafka
    if [ ! -f zkonly ]; then
        $KAFKA_DIR/bin/kafka-server-start.sh -daemon $KAFKA_DIR/config/server.properties
    fi
fi
