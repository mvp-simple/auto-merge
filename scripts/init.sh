#!/bin/bash

# initialization
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
SCRIPT_NAME=$(basename "$0")
WORK_DIR=$SCRIPT_DIR/../result
CONFIG_DIR=$SCRIPT_DIR/../scripts/config
SCRIPTS_DIR=$SCRIPT_DIR/../scripts
CONFIG=$(cat $CONFIG_DIR/$SCRIPT_NAME.json)

# make work folder
mkdir $WORK_DIR || echo "" > /dev/null

# initialization git remote
cd $WORK_DIR
GIT_REMOTE=$(echo $CONFIG | jq -r '. | .git.remote')
git init
git remote add origin ${GIT_REMOTE}
git branch -M main

# action declaration
ACTION_DOWNLOAD="download"

# hook declaration
REPOSITORIES_DOWNLOAD_BEFORE="_${ACTION_DOWNLOAD}_before"
REPOSITORIES_DOWNLOAD_AFTER_="_${ACTION_DOWNLOAD}_after_"

help="
# 1   ${REPOSITORIES_DOWNLOAD_BEFORE}   -   run before download repositories to result folder
# 2   ${REPOSITORIES_DOWNLOAD_AFTER_}   -   run after download repositories to result folder
"

help_ru="
# 1   ${REPOSITORIES_DOWNLOAD_BEFORE}   -   запускается до загрузки исходных репозиториев
# 2   ${REPOSITORIES_DOWNLOAD_AFTER_}   -   запускается после завершения загрузки исходных репозиториев
"

while [[ "$#" -gt 0 ]]
  do
    case $1 in
      -h|--help) echo "${help}";exit;shift;;
      -h_ru|--help_ru) echo "${help_ru}";exit;shift;;
    esac
    shift
done

# download all source repositories
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOMOD_HOOK_BEFORE_PREPARE}
REPOSITORIES_FOLDERS=$(echo $CONFIG | jq '.repositories | keys[]')
for FOLDER in ${REPOSITORIES_FOLDERS[@]}
do
    SOURCE=$(echo $CONFIG | jq -r ".repositories.${FOLDER}")
    SOURCE_FOLDER=$(echo $FOLDER | jq -r ".")
    git clone $SOURCE $SOURCE_FOLDER
done
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOMOD_HOOK_BEFORE_PREPARE}