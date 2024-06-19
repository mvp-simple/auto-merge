#!/bin/bash

# initialization
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
WORK_DIR=$SCRIPT_DIR/../result
CONFIG_DIR=$SCRIPT_DIR/../config
SCRIPTS_DIR=$SCRIPT_DIR/../scripts
SCRIPT_NAME=go.mod.sum.sh

# read configuration
CONFIG=$(cat $CONFIG_DIR/$SCRIPT_NAME.json)

# make go.mod file
SOURCE_MODULE=$(echo $CONFIG | jq -r '. | .source_module')
SOURCE_GO_VERSION=$(echo $CONFIG | jq -r '. | .source_go_version')
GOMOD="module ${SOURCE_MODULE}

go ${SOURCE_GO_VERSION}
"

GOMOD_FILES=$(find $SCRIPT_DIR/../result -type d -name vendor -prune -o -name 'go.mod')
for FILE in ${GOMOD_FILES[@]}
do
    GOMOD+=$(cat $FILE  | grep -v  'module' | grep -v  'go ')
    GOMOD+="
"
done

# make go.sum file
GOSUM=""

GOSUM_FILES=$(find $SCRIPT_DIR/../result -type d -name vendor -prune -o -name 'go.sum')
for FILE in ${GOSUM_FILES[@]}
do
    GOSUM+=$(cat $FILE)
    GOSUM+="
"
done

echo "${GOSUM}"