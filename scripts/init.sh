#!/bin/bash

# initialization
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
WORK_DIR=$SCRIPT_DIR/../result
CONFIG_DIR=$SCRIPT_DIR/../config
SCRIPTS_DIR=$SCRIPT_DIR/../scripts
SCRIPT_NAME=init.sh

# make work folder
mkdir $WORK_DIR || echo "" > /dev/null

# read configuration
CONFIG=$(cat $CONFIG_DIR/$SCRIPT_NAME.json)

# initialization git remote
cd $WORK_DIR
echo $CONFIG
GIT_REMOTE=$(echo $CONFIG | jq -r '. | .git.remote')
git init
git remote add origin ${GIT_REMOTE}
git branch -M main



REPOSITORIES_FOLDERS=$(echo $CONFIG | jq '.repositories | keys[]')
for FOLDER in ${REPOSITORIES_FOLDERS[@]}
do
    SOURCE=$(echo $CONFIG | jq -r ".repositories.${FOLDER}")
    SOURCE_FOLDER=$(echo $FOLDER | jq -r ".")
    git clone $SOURCE $SOURCE_FOLDER
done

cd $SCRIPT_DIR