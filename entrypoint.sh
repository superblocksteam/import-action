#!/bin/bash

set -e
set -o pipefail

COMMIT_SHA="${COMMIT_SHA:-HEAD}"
SUPERBLOCKS_DOMAIN="${SUPERBLOCKS_DOMAIN:-app.superblocks.com}"
SUPERBLOCKS_CONFIG_PATH="${SUPERBLOCKS_CONFIG_PATH:-.superblocks/superblocks.json}"

# Ensure that a Superblocks token is provided
if [ -z "$SUPERBLOCKS_TOKEN" ]; then
  echo "The 'SUPERBLOCKS_TOKEN' environment variable is unset or empty. Exiting..."
  exit 1
fi

if [ -z "$REPO_DIR" ]; then
  REPO_DIR="$(pwd)"
else
  cd "$REPO_DIR"
fi

git config --global --add safe.directory "$REPO_DIR"

# Get the list of changed files in the last commit
changed_files=$(git diff "${COMMIT_SHA}"^ --name-only)

if [ -n "$changed_files" ]; then
    superblocks --version

    # Login to Superblocks
    printf "\nLogging in to Superblocks...\n"
    superblocks config set domain "$SUPERBLOCKS_DOMAIN"
    superblocks login -t "$SUPERBLOCKS_TOKEN"
else
    echo "No files changed since the last commit. Skipping push..."
    exit 0
fi

# Function to push a resource to Superblocks if it has changed
push_resource() {
    local location="$1"
    # Push only if there are some changes to $location/application.yaml, $location/page.yaml, $location/api.yaml, or $location/apis/*.
    # This is to avoid pushing when only the components have changed.
    if echo "$changed_files" | grep -qP "^${location}/(application|page|api).yaml" || echo "$changed_files" | grep -qP "^${location}/apis/" ; then
        printf "\nChange detected. Pushing...\n"
        superblocks push "$location"
    else
        printf "\nNo change detected. Skipping push...\n"
    fi
}

# Check if any push-compatible resources have changed
jq -r '.resources[] | .location' "$SUPERBLOCKS_CONFIG_PATH" | while read -r location; do
    printf "\nChecking %s for changes...\n" "$location"
    push_resource "$location"
done

printf "\nChecking complete. Exiting...\n"
