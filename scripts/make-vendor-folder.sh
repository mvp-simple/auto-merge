#!/bin/bash
# initialization
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
SCRIPT_NAME=$(basename "$0")
WORK_DIR=$SCRIPT_DIR/../result
CONFIG_DIR=$SCRIPT_DIR/../scripts/config
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

GOSUM_HOOK_BEFORE_PREPARE="_${ACTION__GOSUM}_before_prepare"
GOSUM_HOOK_AFTER_PREPARED="_${ACTION__GOSUM}_after_prepared"

GOSUM_HOOK_BEFORE_RENAME_="_${ACTION__GOSUM}_before_rename_"
GOSUM_HOOK_AFTER_RENAME__="_${ACTION__GOSUM}_after_renamed_"

VENDOR_HOOK_BEFORE_REPLACE="_${ACTION_VENDOR}_before_replace"
VENDOR_HOOK_AFTER_REPLACE_="_${ACTION_VENDOR}_after_replace_"

VENDOR_HOOK_BEFORE_CREATE_="_${ACTION_VENDOR}_before_create"
VENDOR_HOOK_AFTER_CREATE__="_${ACTION_VENDOR}_after_create_"



help="
# 1   ${GOMOD_HOOK_BEFORE_PREPARE}   -   run before scan all go.mod sub folders at result folder
# 2   ${GOMOD_HOOK_AFTER_PREPARED}   -   run after scan all go.mod sub folders at result folder
# 3   ${GOSUM_HOOK_BEFORE_PREPARE}   -   run before scan all go.sum sub folders at result folder
# 4   ${GOSUM_HOOK_AFTER_PREPARED}   -   run after scan all go.sum sub folders at result folder
# 5   ${VENDOR_HOOK_BEFORE_REPLACE}  -   run before replace all folders named as vendor at result folder
# 6   ${VENDOR_HOOK_AFTER_REPLACE_}  -   run after replace all folders named as vendor at result folder
# 7   ${GOMOD_HOOK_BEFORE_RENAME_}   -   run before renames all go.mod sub folders at result folder
# 8   ${GOMOD_HOOK_AFTER_RENAME__}   -   run after renames all go.mod sub folders at result folder
# 9   ${GOSUM_HOOK_BEFORE_RENAME_}   -   run before renames all go.sum sub folders at result folder
# 10  ${GOSUM_HOOK_AFTER_RENAME__}   -   run after renames all go.sum sub folders at result folder
# 11  ${VENDOR_HOOK_BEFORE_CREATE_}  -   run before vendor folder create
# 12  ${VENDOR_HOOK_AFTER_CREATE__}  -   run after vendor folder create
"

help_ru="
# 1   ${GOMOD_HOOK_BEFORE_PREPARE}   -   запускается до сканирования go.mod во всех директориях папки result
# 2   ${GOMOD_HOOK_AFTER_PREPARED}   -   запускается после сканирования go.mod во всех директориях папки result
# 3   ${GOSUM_HOOK_BEFORE_PREPARE}   -   запускается до сканирования go.sum во всех директориях папки result
# 4   ${GOSUM_HOOK_AFTER_PREPARED}   -   запускается после сканирования go.sum во всех директориях папки result
# 5   ${VENDOR_HOOK_BEFORE_REPLACE}  -   запускается до перемещение папок vendor вложенных в папку result
# 6   ${VENDOR_HOOK_AFTER_REPLACE_}  -   запускается после перемещение папок vendor вложенных в папку result
# 7   ${GOMOD_HOOK_BEFORE_RENAME_}   -   запускается до переименования go.mod в вложенных директориях result
# 8   ${GOMOD_HOOK_AFTER_RENAME__}   -   запускается после переименования go.mod в вложенных директориях result
# 9   ${GOSUM_HOOK_BEFORE_RENAME_}   -   запускается до переименования go.sum в вложенных директориях result
# 10  ${GOSUM_HOOK_AFTER_RENAME__}   -   запускается после переименования go.sum в вложенных директориях result
# 11  ${VENDOR_HOOK_BEFORE_CREATE_}  -   запускается до создания директории vendor
# 12  ${VENDOR_HOOK_AFTER_CREATE__}  -   запускается после создания директории vendor
"

while [[ "$#" -gt 0 ]]
  do
    case $1 in
      -h|--help) echo "${help}";exit;shift;;
      -h_ru|--help_ru) echo "${help_ru}";exit;shift;;
    esac
    shift
done

# prepare go.mod file
SOURCE_MODULE=$(echo $CONFIG | jq -r '. | .source_module')
SOURCE_GO_VERSION=$(echo $CONFIG | jq -r '. | .source_go_version')
GOMOD="module ${SOURCE_MODULE}
go ${SOURCE_GO_VERSION}
"
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOMOD_HOOK_BEFORE_PREPARE}
GOMOD_FILES=$(find $SCRIPT_DIR/../result/*/ -type d -name /vendor -prune -o -name 'go.mod')
for FILE in ${GOMOD_FILES[@]}
do
    GOMOD+=$(cat $FILE  | grep -v  'module' | grep -v  'go ')
    GOMOD+="
"
done
RESULT_GO_MOD_FILENAME="${SCRIPT_DIR}"/../result/go.mod
touch $RESULT_GO_MOD_FILENAME
echo "${GOMOD}" > $RESULT_GO_MOD_FILENAME
"${SCRIPT_DIR}"/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOMOD_HOOK_AFTER_PREPARED}
# end prepare go.mod file

# prepare go.sum file
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOSUM_HOOK_BEFORE_PREPARE}
GOSUM=""
GOSUM_FILES=$(find $SCRIPT_DIR/../result/*/ -type d -name /vendor -prune -o -name 'go.sum')
for FILE in ${GOSUM_FILES[@]}
do
    GOSUM+=$(cat $FILE)
    GOSUM+="
"
done
RESULT_GO_SUM_FILENAME="${SCRIPT_DIR}"/../result/go.sum
touch $RESULT_GO_SUM_FILENAME
echo "${GOSUM}" > $RESULT_GO_SUM_FILENAME
"${SCRIPT_DIR}"/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOSUM_HOOK_AFTER_PREPARED}
# end prepare go.sum file

# vendor folder replacing to temp folders
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${VENDOR_HOOK_BEFORE_REPLACE}
VENDOR_FOLDERS=$(find $SCRIPT_DIR/../result -maxdepth 1 -mindepth 1 -name "vendor"  -type d)
VENDOR_FOLDER_MAP=()
for VENDOR in "${VENDOR_FOLDERS[@]}"; do
  TEMP_VENDOR=$(mktemp -d)/vendor
  VENDOR_FOLDER_MAP+=("${TEMP_VENDOR}"="${VENDOR}")
  mv $VENDOR $TEMP_VENDOR
done
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${VENDOR_HOOK_AFTER_REPLACE_}
# end vendor folder replacing to temp folders

# renaming go.mod files
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOMOD_HOOK_BEFORE_RENAME_}
for FILE in ${GOMOD_FILES[@]}
do
    mv $FILE $FILE$RENAME_SUFFIX
done
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOMOD_HOOK_AFTER_RENAME__}
# end renaming go.mod files

# renaming go.sum files
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOSUM_HOOK_BEFORE_RENAME_}
for FILE in ${GOSUM_FILES[@]}
do
  mv $FILE $FILE$RENAME_SUFFIX
done
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${GOSUM_HOOK_AFTER_RENAME__}
# end renaming go.sum files

VENDOR_HOOK_BEFORE_CREATE_
VENDOR_HOOK_AFTER_CREATE__
# generate vendor folder
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${VENDOR_HOOK_BEFORE_CREATE_}
cd ${SCRIPT_DIR}/../result; go mod tidy; go mod vendor; cd $SCRIPT_DIR
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${VENDOR_HOOK_AFTER_CREATE__}
# end generate vendor folder
