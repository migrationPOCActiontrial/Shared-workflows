#!/bin/bash
set -euo pipefail

SOURCE_BASE="https://github.com/migrationPOCAction"
TARGET_BASE="https://github.com/migrationPOCActiontrial"
BATCH_SIZE=2

repos=(
  spring-boot-inventory-system
  payment-management-service
  unique-springboot-repo
)

for repo in "${repos[@]}"
do
  echo "Migrating ${repo} ..."
  target="$TARGET_BASE/app-15507-${repo}.git"

  git clone --mirror "$SOURCE_BASE/${repo}.git"

  cd "${repo}.git"

  echo "Pushing branches ..."
  git push "$target" 'refs/heads/*:refs/heads/*''

  echo "Pushing tags in batches of ${BATCH_SIZE} ..."

  git for-each-ref --format='%(refname):%(refname)' refs/tags \\

    | xargs -n "$BATCH_SIZE" git push "$target"

  cd ..
  rm -rf "${repo}.git"

  echo "$repo migrated successfully"
done
