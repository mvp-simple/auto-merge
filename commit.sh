#!/bin/bash
# initialization
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

# git commit
cd $SCRIPT_DIR
git add -A .
git commit -m "step $(date +%s)"
git push -u origin main --force


