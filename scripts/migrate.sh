#!/bin/bash
set -euo pipefail

SOURCE_BASE="https://github.com/migrationPOCAction"
TARGET_BASE="https://github.com/migrationPOCActiontrial"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAG_FILE="$SCRIPT_DIR/config/tags.txt"

repos=(
  spring-boot-inventory-system
  payment-management-service
  unique-springboot-repo
)

if [[ ! -f "$TAG_FILE" ]]; then
  echo "ERROR: Tag file not found: $TAG_FILE"
  exit 1
fi

echo "Using tag configuration: $TAG_FILE"

for repo in "${repos[@]}"
do
  echo "========================================"
  echo "Migrating ${repo} ..."
  echo "========================================"

  target="$TARGET_BASE/app-15507-${repo}.git"

  git clone --mirror "$SOURCE_BASE/${repo}.git"

  cd "${repo}.git"

  echo "Pushing all branches..."

  git push "$target" 'refs/heads/*:refs/heads/*'

  echo "Pushing selected tags..."

  while IFS= read -r tag
  do
    # Skip empty lines
    [[ -z "$tag" ]] && continue

    # Skip comments
    [[ "$tag" =~ ^# ]] && continue

    echo "Processing tag: $tag"

    if git show-ref --tags --verify --quiet "refs/tags/$tag"; then
      echo "Pushing tag: $tag"

      git push "$target" \
        "refs/tags/$tag:refs/tags/$tag"
    else
      echo "WARNING: Tag '$tag' does not exist in $repo. Skipping."
    fi

  done < "$TAG_FILE"

  cd ..

  rm -rf "${repo}.git"

  echo "✅ $repo migrated successfully"
  echo
done

echo "Migration completed successfully"
