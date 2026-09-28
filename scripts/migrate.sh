#!/bin/bash

SOURCE_BASE="https://github.com/migrationPOCAction"
TARGET_BASE="https://github.com/migrationPOCActiontrial"

repos=(
  spring-boot-inventory-system
  payment-management-service
  unique-springboot-repo
)

for repo in "${repos[@]}"
do
  echo "Migrating ${repo} ..."

  git clone --mirror "$SOURCE_BASE/${repo}.git"

  cd "${repo}.git"

  git push "$TARGET_BASE/app-15507-${repo}.git" \
  'refs/heads/*:refs/heads/*' \
  'refs/tags/*:refs/tags/*'

  cd ..
  rm -rf "${repo}.git"

  echo "$repo migrated successfully"
done
