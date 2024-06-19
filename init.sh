#!/bin/bash
git init
git remote add origin git@github.com:mvp-simple/auto-merge.git
git branch -M main

REPO=$(cat init.repo.json)
KEYS=$(echo $REPO | jq '. | keys[]')

for key in ${KEYS[@]}
do
    SRC=$(echo $REPO | jq -r ".${key}")
    FOLDER=$(echo $key | jq -r ".")
    git clone $SRC $FOLDER
done