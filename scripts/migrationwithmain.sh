#!/bin/bash

SOURCE_BASE="https://github.com/migrationPOCAction"
TARGET_BASE="https://github.com/migrationPOCActiontrial"

GIT_TOKEN="$1"

repos=(
  spring-boot-order-service
  notification-service
  spring-boot-inventory-system
  payment-management-service
  spring-boot-product-catalog
  spring-boot-demo-project
  spring-boot-user-management
  unique-springboot-repo
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

  echo "Checking default branch for ${repo} ..."

  while true
  do
    DEFAULT_BRANCH=$(curl -sS \
      -H "Authorization: Bearer ${GIT_TOKEN}" \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "https://api.github.com/repos/migrationPOCActiontrial/${repo}" \
      | grep '"default_branch"' \
      | head -1 \
      | sed 's/.*"default_branch": "\(.*\)".*/\1/')

    echo "Current default branch: ${DEFAULT_BRANCH}"

    if [ "$DEFAULT_BRANCH" = "main" ]; then
      echo "Default branch for ${repo} is already main."
      break
    fi

    echo "Default branch is ${DEFAULT_BRANCH}. Changing it to main..."

    curl -sS -X PATCH \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${GIT_TOKEN}" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "https://api.github.com/repos/migrationPOCActiontrial/${repo}" \
      -d '{"default_branch":"main"}'

    echo
    echo "Waiting before checking again..."
    sleep 3
  done

  echo "$repo migrated successfully"
  echo "----------------------------------------"

done
