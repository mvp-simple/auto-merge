#!/bin/bash

# initialization
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME=$(basename "$0")
WORK_DIR=$SCRIPT_DIR/../result
CONFIG_DIR=$SCRIPT_DIR/../config
SCRIPTS_DIR=$SCRIPT_DIR/../scripts
CONFIG=$(cat $CONFIG_DIR/$SCRIPT_NAME.json)

# make vendor folder
$SCRIPT_DIR/make-vendor-folder.sh
# SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

# GOMOD="module github.com/rinatusmanov

# go 1.18"
# GOSUM=""
# TEMP_DIR=$(mktemp -d)

# DIRECTORIES=$(ls -d */)
# for item in ${DIRECTORIES[@]}
# do
#     if [[ $item == "vendor/" ]]; then
#       continue
#     fi
    
#     GOMOD+=$(cat $SCRIPT_DIR/${item}go.mod  | grep -v  'module' | grep -v  'go ')
#     GOMOD+="
# "
#     GOSUM+=$(cat $SCRIPT_DIR/${item}go.sum)
#     GOSUM+="
# "
#     cd $SCRIPT_DIR/$item; git pull
#     mv $SCRIPT_DIR/${item}go.mod $SCRIPT_DIR/${item}go.mod_last || echo "" > /dev/null
#     mv $SCRIPT_DIR/${item}go.sum $SCRIPT_DIR/${item}go.sum_last || echo "" > /dev/null
#     mv $SCRIPT_DIR/${item}.git $SCRIPT_DIR/${item}.git_last || echo "" > /dev/null
# done

# touch $SCRIPT_DIR/go.mod
# touch $SCRIPT_DIR/go.sum

# echo "$GOMOD" > $SCRIPT_DIR/go.mod
# echo "$GOSUM" > $SCRIPT_DIR/go.sum

# go mod tidy
# go mod vendor
# for item in ${DIRECTORIES[@]}
# do
#     if [[ $item == "vendor/" ]]; then
#       continue
#     fi

#     mv $SCRIPT_DIR/${item}go.mod_last $SCRIPT_DIR/${item}go.mod || echo "" > /dev/null
#     mv $SCRIPT_DIR/${item}go.sum_last $SCRIPT_DIR/${item}go.sum || echo "" > /dev/null
#     mv $TEMP_DIR/vendor $SCRIPT_DIR/${item}vendor  || echo "" > /dev/null
# done

# cd $SCRIPT_DIR

# REPO=$(cat sync.config.json)
# SED_REPLACE_AT_FILES_REGEXP=$(echo $REPO | jq -r '.sed_replace_at_files_regexp')
# SED_REPLACE_AT_FILES_REGEXP="'${SED_REPLACE_AT_FILES_REGEXP}'"
# echo $SED_REPLACE_AT_FILES_REGEXP
# if [ -n $SED_REPLACE_AT_FILES_REGEXP ]; then
#   echo $SED_REPLACE_AT_FILES_REGEXP
#   FILES=$(find .)
#   for file in ${FILES[@]}
#   do
#       if [[ -d $file ]]; then
#           continue
#       fi
#       sed -i '' $SED_REPLACE_AT_FILES_REGEXP $file
#       break
#   done
# fi

# git add -A .
# git commit -m "step $(date +%s)"
# git push -u origin main

# for item in ${DIRECTORIES[@]}
# do
#     if [[ $item == "vendor/" ]]; then
#       continue
#     fi
    
#     mv $SCRIPT_DIR/${item}.git_last $SCRIPT_DIR/${item}.git || echo "" > /dev/null
# done

