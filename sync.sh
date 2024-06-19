#!/bin/bash
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

GOMOD="module github.com/rinatusmanov

go 1.18"
GOSUM=""
TEMP_DIR=$(mktemp -d)

DIRECTORIES=$(ls -d */)
for item in ${DIRECTORIES[@]}
do
    if [[ $item == "vendor/" ]]; then
      continue
    fi
    
    GOMOD+=$(cat $SCRIPT_DIR/${item}go.mod  | grep -v  'module' | grep -v  'go ')
    GOMOD+="
"
    GOSUM+=$(cat $SCRIPT_DIR/${item}go.sum)
    GOSUM+="
"
    mv $SCRIPT_DIR/${item}go.mod $SCRIPT_DIR/${item}go.mod_last || echo "" > /dev/null
    mv $SCRIPT_DIR/${item}go.sum $SCRIPT_DIR/${item}go.sum_last || echo "" > /dev/null
    mv $SCRIPT_DIR/${item}vendor $TEMP_DIR/vendor || echo "" > /dev/null
    # cd $SCRIPT_DIR/$item; git pull
    # mv $SCRIPT_DIR/${item}.git $SCRIPT_DIR/${item}.git_last || echo "" > /dev/null
    # cd $SCRIPT_DIR/$item; go mod vendor -o ../vendor_${item%"/"}
done

touch $SCRIPT_DIR/go.mod
touch $SCRIPT_DIR/go.sum

echo "$GOMOD" > $SCRIPT_DIR/go.mod
echo "$GOSUM" > $SCRIPT_DIR/go.sum

echo ${DIRECTORIES[@]}

go mod tidy
go mod vendor
for item in ${DIRECTORIES[@]}
do
    if [[ $item == "vendor/" ]]; then
      continue
    fi

    mv $SCRIPT_DIR/${item}go.mod_last $SCRIPT_DIR/${item}go.mod || echo "" > /dev/null
    mv $SCRIPT_DIR/${item}go.sum_last $SCRIPT_DIR/${item}go.sum || echo "" > /dev/null
    mv $TEMP_DIR/vendor $SCRIPT_DIR/${item}vendor  || echo "" > /dev/null
done

cd $SCRIPT_DIR
git add -A .
git commit -m "step $(date +%s)"
git push -u origin main
