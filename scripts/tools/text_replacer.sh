#!/bin/bash
help="get 4 arguments
required:
    -p|--path       path where must find files to replace text
    -r|--regexp     regexp pattern to text find
optional:
    -t|--text       text to replace default is ''
    -m|--mask       filename mask to find default is '*'

    -h|--help       show this text and exit script
"
PATH=""
REGEXP=""
TEXT=""
MASK="*"

while [[ "$#" -gt 0 ]]
  do
    case $1 in
      -h|--help)    echo "${help}";exit;shift;;
      -p|--path)    PATH+=$2;shift;;
      -r|--regexp)  REGEXP+=$2;shift;;
      -t|--text)    TEXT+=$2;shift;;
      -m|--mask)    MASK+=$2;shift;;
    esac
    shift
done