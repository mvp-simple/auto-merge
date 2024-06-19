#!/bin/bash
git init
git remote add origin git@github.com:mvp-simple/auto-merge.git
git branch -M main

GIT_REPOSITORIES=(
    https://github.com/rinatusmanov/dauni-ml.git 
    https://github.com/rinatusmanov/evgeniya.git 
    https://github.com/rinatusmanov/compiler_go_ibm_db.git
)

for item in ${GIT_REPOSITORIES[@]}
do
    git clone $item
done
