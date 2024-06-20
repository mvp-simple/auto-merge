#!/bin/bash

# initialization
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME=$(basename "$0")
WORK_DIR=$SCRIPT_DIR/../result
CONFIG_DIR=$SCRIPT_DIR/../config
SCRIPTS_DIR=$SCRIPT_DIR/../scripts
CONFIG=$(cat $CONFIG_DIR/$SCRIPT_NAME.json)

EXECUTOR=""
ACTION=""
while [[ "$#" -gt 0 ]]
  do
    case $1 in
      -e|--executor) EXECUTOR+=$2;shift;;
      -a|--action) ACTION=$2;shift;;
    esac
    shift
done

echo $EXECUTOR

echo $ACTION