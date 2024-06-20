#!/bin/bash

help="
get 3 arguments
required:
    -r|--regexp     regexp pattern to text find
optional:
    -p|--path       path where must find files to replace text default is './result'
    -m|--mask       filename mask to find default is '*'

    -h|--help       show this text and exit script

Sample:
    ./scripts/tools/text_replacer.sh -m \"*.go\" -r 's/github.com\/lib\/pq/gitlab.ru\/lib\/pq/g'
"
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
FIND_DIR=$SCRIPT_DIR/../../result

REGEXP=""
MASK="*"

while [[ "$#" -gt 0 ]]
  do
    case $1 in
      -h|--help)    echo "${help}";exit;shift;;
      -p|--path)    FIND_DIR+=$2;shift;;
      -r|--regexp)  REGEXP+=$2;shift;;
      -m|--mask)    MASK+=$2;shift;;
    esac
    shift
done
#echo find $FIND_DIR -name "${MASK}"


[[ "$REGEXP" == "" ]] && echo "${help}" && exit 0
FILES=$(find $FIND_DIR -name "${MASK}")
for FILE in ${FILES[@]}
do
  sed -i '' "${REGEXP}" $FILE
done
