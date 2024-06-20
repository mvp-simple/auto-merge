#!/bin/bash
help="get 2 arguments 
    -e|--executor script name who want run that hook
    -a|--action hook name
and find hooks sorted by name at scripts/hooks directory as names 
     $script/$action* and run thats

     if  script name or action is empty exiting from script without exception
"


# initialization
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
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

# check EXECUTOR is not empty
if [[ "$EXECUTOR" == "" ]]; then
    exit 0
fi


# check ACTION is not empty
if [[ "$ACTION" == "" ]]; then
    exit 0
fi

# find and shell hooks
[[ -d ${SCRIPT_DIR}/../scripts/hooks/${EXECUTOR} ]] || exit 0

find ${SCRIPT_DIR}/../scripts/hooks/${EXECUTOR} -name "$ACTION*" -print0 | sort -z |
    while IFS= read -r -d '' HOOK; do
        chmod 0777 "${HOOK}"
        "${HOOK}"
    done