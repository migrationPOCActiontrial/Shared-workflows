#!/bin/bash

TARGET_BASE="https://api.github.com/repos/migrationPOCActiontrial"

GIT_TOKEN="$1"

repos=(
  notification-service
)

for repo in "${repos[@]}"
do
  echo "----------------------------------------"
  echo "Checking default branch for ${repo} ..."
  echo "----------------------------------------"

  while true
  do
    DEFAULT_BRANCH=$(curl -sS \
      -H "Authorization: Bearer ${GIT_TOKEN}" \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "${TARGET_BASE}/APP-15507-${repo}" \
      | grep '"default_branch"' \
      | head -1 \
      | sed 's/.*"default_branch": "\(.*\)".*/\1/')

    echo "Current default branch: ${DEFAULT_BRANCH}"

    if [ "$DEFAULT_BRANCH" = "main" ]; then
      echo "Default branch for ${repo} is already main."
      break
    fi

    echo "Default branch is ${DEFAULT_BRANCH}."
    echo "Changing ${repo} default branch to main..."

    curl -sS -X PATCH \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${GIT_TOKEN}" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "${TARGET_BASE}/APP-15507-${repo}" \
      -d '{"default_branch":"main"}'

    echo
    echo "Waiting 3 seconds before checking again..."
    sleep 3
  done

  echo "${repo} default branch check completed."
done
