#!/bin/bash

SOURCE_BASE="https://github.com/migrationPOCAction"
TARGET_BASE="https://github.com/migrationPOCActiontrial"

GIT_TOKEN="$1"

repos=(
    spring-boot-order-service
    notification-service
    spring-boot-inventory-system
    payment-management-service
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

    echo "Setting default branch to 'main' for ${repo} ..."

    curl -sS -w "\nHTTP Status: %{http_code}\n" -X PATCH \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${GIT_TOKEN}" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "https://api.github.com/repos/migrationPOCActiontrial/${repo}" \
      -d '{"default_branch":"main"}'

    echo "$repo migrated successfully"
done
