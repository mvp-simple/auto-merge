#!/bin/bash

# initialization
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
SCRIPT_NAME=$(basename "$0")
WORK_DIR=$SCRIPT_DIR/../result
CONFIG_DIR=$SCRIPT_DIR/../scripts/config
SCRIPTS_DIR=$SCRIPT_DIR/../scripts
CONFIG=$(cat $CONFIG_DIR/$SCRIPT_NAME.json)

# action declaration
ACTION_CLEAN_PULL___="clean_pull"
ACTION_VENDOR_CREATE="vendor_folder"
ACTION_PUSH_RESULT__="push_result"

# hook declaration
GIT_CLEAN_PULL_BEFORE="_${ACTION_CLEAN_PULL___}_before"
GIT_CLEAN_PULL_AFTER_="_${ACTION_CLEAN_PULL___}_after_"
VENDOR_CREATE_BEFORE_="_${ACTION_VENDOR_CREATE}_before"
VENDOR_CREATE_AFTER__="_${ACTION_VENDOR_CREATE}_after_"
GIT_PUSH_BEFORE______="_${ACTION_PUSH_RESULT__}_before"
GIT_PUSH_AFTER_______="_${ACTION_PUSH_RESULT__}_after_"


help="
# 1   ${GIT_CLEAN_PULL_BEFORE}   -   run before reset all changes at repositories
# 2   ${GIT_CLEAN_PULL_AFTER_}   -   run after reset all changes at repositories
# 3   ${VENDOR_CREATE_BEFORE_}   -   run before subcomponent exec
# 4   ${VENDOR_CREATE_AFTER__}   -   run after subcomponent exec
# 5   ${GIT_PUSH_BEFORE______}   -   run before result push
# 6   ${GIT_PUSH_AFTER_______}   -   run after result push
"

help_ru="
# 1   ${GIT_CLEAN_PULL_BEFORE}   -   запускается до очистки всех изменений в наблюдаемых репозиториях
# 2   ${GIT_CLEAN_PULL_AFTER_}   -   запускается после очистки всех изменений в наблюдаемых репозиториях
# 3   ${VENDOR_CREATE_BEFORE_}   -   запускается до запуска вложенного компонента make-vendor-folder
# 4   ${VENDOR_CREATE_AFTER__}   -   запускается после запуска вложенного компонента make-vendor-folder
# 5   ${GIT_PUSH_BEFORE______}   -   запускается до отправки изменений результата
# 6   ${GIT_PUSH_AFTER_______}   -   запускается после отправки изменений результата
"

while [[ "$#" -gt 0 ]]
  do
    case $1 in
      -h|--help) echo "${help}";exit;shift;;
      -h_ru|--help_ru) echo "${help_ru}";exit;shift;;
    esac
    shift
done

# clean and pull watched repositories
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${GIT_CLEAN_PULL_BEFORE}
REPOSITORIES=$(echo $CONFIG | jq -r '.repositories[]')
for REPOSITORY in ${REPOSITORIES[@]}; do
  mv "${SCRIPT_DIR}/../result/${REPOSITORY}/.git_last" "${SCRIPT_DIR}/../result/${REPOSITORY}/.git" || echo "" > /dev/null
  cd "${SCRIPT_DIR}/../result/${REPOSITORY}"; git clean -fdx && git reset --hard; git pull;
  mv "${SCRIPT_DIR}/../result/${REPOSITORY}/.git" "${SCRIPT_DIR}/../result/${REPOSITORY}/.git_last" || echo "" > /dev/null
done

# end clean and pull watched repositories


# make vendor folder
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${VENDOR_CREATE_BEFORE_}
$SCRIPT_DIR/make-vendor-folder.sh
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${VENDOR_CREATE_AFTER__}
# end make vendor folder

# git push
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${GIT_PUSH_BEFORE______}
rm "${SCRIPT_DIR}/../result/.gitignore" || echo "" > /dev/null
copy "${SCRIPT_DIR}/../scripts/files/git/.gitignore_result" "${SCRIPT_DIR}/../result/.gitignore"
cd "${SCRIPT_DIR}/../result"; git add -A .; git commit -m "step $(date +%s)"; git push -u origin main --force;
for REPOSITORY in ${REPOSITORIES[@]}; do
  mv "${SCRIPT_DIR}/../result/${REPOSITORY}/.git_last" "${SCRIPT_DIR}/../result/${REPOSITORY}/.git" || echo "" > /dev/null
done
${SCRIPT_DIR}/../scripts/hooks/run_hooks.sh -e ${SCRIPT_NAME} -a ${GIT_PUSH_AFTER_______}
# end git push
