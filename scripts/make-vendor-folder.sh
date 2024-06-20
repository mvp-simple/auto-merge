#!/bin/bash

# initialization
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME=$(basename "$0")
WORK_DIR=$SCRIPT_DIR/../result
CONFIG_DIR=$SCRIPT_DIR/../config
SCRIPTS_DIR=$SCRIPT_DIR/../scripts
RENAME_SUFFIX="_TEMP_RENAMED"
CONFIG=$(cat $CONFIG_DIR/$SCRIPT_NAME.json)


# action declaration
ACTION__GOMOD="gomod"
ACTION__GOSUM="gosum"
ACTION_VENDOR="vendor"

# hook declaration
GOMOD_HOOK_BEFORE_PREPARE="_${ACTION__GOMOD}_before_prepare"
GOMOD_HOOK_AFTER_PREPARED="_${ACTION__GOMOD}_after_prepared"

GOMOD_HOOK_BEFORE_RENAME_="_${ACTION__GOMOD}_before_rename_"
GOMOD_HOOK_AFTER_RENAME__="_${ACTION__GOMOD}_after_renamed_"

GOMOD_HOOK_BEFORE_RESTORE="_${ACTION__GOMOD}_before_restore"
GOMOD_HOOK_AFTER_RESTORE_="_${ACTION__GOMOD}_after_restore_"

GOSUM_HOOK_BEFORE_PREPARE="_${ACTION__GOSUM}_before_prepare"
GOSUM_HOOK_AFTER_PREPARED="_${ACTION__GOSUM}_after_prepared"

GOSUM_HOOK_BEFORE_RENAME_="_${ACTION__GOSUM}_before_rename_"
GOSUM_HOOK_AFTER_RENAME__="_${ACTION__GOSUM}_after_renamed_"

GOSUM_HOOK_BEFORE_RESTORE="_${ACTION__GOSUM}_before_restore"
GOSUM_HOOK_AFTER_RESTORE_="_${ACTION__GOSUM}_after_restore_"

VENDOR_HOOK_BEFORE_REPLACE="_${ACTION_VENDOR}_before_replace"
VENDOR_HOOK_AFTER_REPLACE_="_${ACTION_VENDOR}_after_replace_"

VENDOR_HOOK_BEFORE_RESTORE="_${ACTION_VENDOR}_before_restore"
VENDOR_HOOK_AFTER_RESTORE_="_${ACTION_VENDOR}_after_restore_"

# prepare go.mod file
SOURCE_MODULE=$(echo $CONFIG | jq -r '. | .source_module')
SOURCE_GO_VERSION=$(echo $CONFIG | jq -r '. | .source_go_version')
GOMOD="module ${SOURCE_MODULE}
go ${SOURCE_GO_VERSION}
"
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOMOD_HOOK_BEFORE_PREPARE}
GOMOD_FILES=$(find $SCRIPT_DIR/../result -type d -name /vendor -prune -o -name 'go.mod')
for FILE in ${GOMOD_FILES[@]}
do
    GOMOD+=$(cat $FILE  | grep -v  'module' | grep -v  'go ')
    GOMOD+="
"
done
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOMOD_HOOK_AFTER_PREPARED}
# end prepare go.mod file


# prepare go.sum file
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOSUM_HOOK_BEFORE_PREPARE}
GOSUM=""
GOSUM_FILES=$(find $SCRIPT_DIR/../result -type d -name /vendor -prune -o -name 'go.sum')
for FILE in ${GOSUM_FILES[@]}
do
    GOSUM+=$(cat $FILE)
    GOSUM+="
"
done
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOSUM_HOOK_AFTER_PREPARED}
# end prepare go.sum file


# vendor folder replacing to temp folders
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${VENDOR_HOOK_BEFORE_REPLACE}
VENDOR_FOLDERS=$(find $SCRIPT_DIR/../result -name "vendor"  -type d)
VENDOR_FOLDER_MAP=()
for VENDOR in "${VENDOR_FOLDERS[@]}"; do
  TEMP_VENDOR=$(mktemp -d)/vendor
  VENDOR_FOLDER_MAP+=("${TEMP_VENDOR}"="${VENDOR}")
  mv $VENDOR $TEMP_VENDOR
done
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${VENDOR_HOOK_AFTER_REPLACE_}
# end vendor folder replacing to temp folders

# renaming go.mod files
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${VENDOR_HOOK_AFTER_REPLACE_}
for FILE in ${GOMOD_FILES[@]}
do
    mv $FILE $FILE$RENAME_SUFFIX
done
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${VENDOR_HOOK_AFTER_REPLACE_}
# end renaming go.mod files

# renaming go.sum files
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${VENDOR_HOOK_AFTER_REPLACE_}
for FILE in ${GOSUM_FILES[@]}
do
  mv $FILE $FILE$RENAME_SUFFIX
done
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${VENDOR_HOOK_AFTER_REPLACE_}
# end renaming go.sum files




# restore go.mod files names
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOMOD_HOOK_BEFORE_RESTORE}
for FILE in ${GOMOD_FILES[@]}
do
    mv $FILE$RENAME_SUFFIX $FILE
done
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOMOD_HOOK_AFTER_RESTORE_}
# end restore go.mod files names

# restore go.sum files names
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOSUM_HOOK_BEFORE_RESTORE}
for FILE in ${GOSUM_FILES[@]}
do
    mv $FILE$RENAME_SUFFIX $FILE
done
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOSUM_HOOK_AFTER_RESTORE_}
# end restore go.sum files names

# vendor folder returning to true position
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${VENDOR_HOOK_BEFORE_RESTORE}
for VENDOR in "${VENDOR_FOLDER_MAP[@]}"; do
  TEMP_VENDOR=$(cut -d "=" -f 1 <<< "$VENDOR")
  TRUE_FOLDER=$(cut -d "=" -f 2 <<< "$VENDOR")
  mv $TEMP_VENDOR $TRUE_FOLDER
done
${SCRIPT_DIR}/run_hooks.sh -e ${SCRIPT_NAME} -a ${VENDOR_HOOK_AFTER_RESTORE_}
# end vendor folder returning to true position


