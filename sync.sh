#!/bin/bash
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

DIRECTORIES=$(ls -d */)
for item in ${DIRECTORIES[@]}
do
    if [[ $item == "vendor/" ]]; then
      continue
    fi
    
    echo ${item:0:-1}
    exit 1
    cd $SCRIPT_DIR/$item; git pull
    mv $SCRIPT_DIR/${item}vendor $SCRIPT_DIR/${item}vendor_last || echo "" > /dev/null
    mv $SCRIPT_DIR/${item}.git $SCRIPT_DIR/${item}.git_last || echo "" > /dev/null
    echo go mod vendor -o ../vendor
    cd $SCRIPT_DIR/$item; go mod vendor -o ../vendor${item:0:-1}
    mv $SCRIPT_DIR/${item}vendor_last $SCRIPT_DIR/${item}vendor  || echo "" > /dev/null
done

cd $SCRIPT_DIR
git add -A .
git commit -m "step $(date +%s)"
git push -u origin main

for item in ${DIRECTORIES[@]}
do
    if [[ $item == "vendor/" ]]; then
      continue
    fi

    mv $SCRIPT_DIR/${item}.git_last $SCRIPT_DIR/${item}.git || echo "" > /dev/null
done