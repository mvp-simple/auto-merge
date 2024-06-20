#!/bin/bash
help="get 2 arguments 
    -e|--executor script name who want run that hook
    -a|--action hook name
and find hooks sorted by name at scripts/hooks directory as names 
     $script/$action* and run thats
"


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

HOOKS=$(find ${SCRIPT_DIR}/../scripts/hooks/${EXECUTOR} -name "$ACTION* | sort -t '\0' -n")
for HOOK in ${HOOKS[@]}
do
    chmod 0777 "${HOOK}"
    "${HOOK}"
done