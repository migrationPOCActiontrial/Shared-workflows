#!/bin/bash

SOURCE_BASE="https://github.com/migrationPOCAction"
TARGET_BASE="https://github.com/migrationPOCActiontrial"

repos=(
  repo5
)

for repo in "${repos[@]}"
do
  echo "Migrating ${repo} ..."

  git clone --mirror "$SOURCE_BASE/${repo}.git"

  cd "${repo}.git"

  git remote set-url origin "$TARGET_BASE/${repo}.git"

  git push --mirror

  cd ..
  rm -rf "${repo}.git"

  echo "$repo migrated successfully"
done
