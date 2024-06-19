#!/bin/bash
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

DIRECTORIES=$(ls -d */)
for item in ${DIRECTORIES[@]}
do
    if [[ $item == "vendor/" ]]; then
      continue
    fi
    cd $SCRIPT_DIR/$item; go mod vendor -o ../vendor
done

cd $SCRIPT_DIR
git add .
git commit -m "step $(date +%s)"
git push -u origin main