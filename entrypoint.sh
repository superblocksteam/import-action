#!/bin/bash

set -e
set -o pipefail

SHA="$1"
TOKEN="$2"
DOMAIN="$3"
CONFIG_PATH="$4"

SUPERBLOCKS_AUTHOR_NAME="${SUPERBLOCKS_AUTHOR_NAME:-superblocks-app[bot]}"
SUPERBLOCKS_COMMIT_MESSAGE_IDENTIFIER="${SUPERBLOCKS_COMMIT_MESSAGE_IDENTIFIER:-[superblocks ci]}"

if [ -z "$REPO_DIR" ]; then
  REPO_DIR="$(pwd)"
else
  cd "$REPO_DIR"
fi

git config --global --add safe.directory "$REPO_DIR"

# Get the actor name and commit message the last commit
actor_name=$(git show -s --format='%an' "$SHA")
commit_message=$(git show -s --format='%B' "$SHA")

# Skip push if the commit was made by Superblocks. To support multiple Git providers, we also
# check for specific identifier text in the commit message.
if [ "$actor_name" == "$SUPERBLOCKS_AUTHOR_NAME" ] || echo "$commit_message" | grep -qF "$SUPERBLOCKS_COMMIT_MESSAGE_IDENTIFIER" ; then
    printf "\nCommit was made by Superblocks. Skipping push...\n"
    exit 0
fi

# Get the list of changed files in the last commit
changed_files=$(git diff "${SHA}"^ --name-only)

if [ -n "$changed_files" ]; then
    superblocks --version

    # Login to Superblocks
    printf "\nLogging in to Superblocks...\n"
    superblocks config set domain "$DOMAIN"
    superblocks login -t "$TOKEN"
else
    echo "No files changed since the last commit. Skipping push..."
    exit 0
fi

# Function to push a resource to Superblocks if it has changed
push_resource() {
    local location="$1"
    # Push only if there are some changes to $location/application.yaml, $location/page.yaml, or $location/apis/*.
    # This is to avoid pushing when only the components have changed.
    if echo "$changed_files" | grep -qP "^${location}/(application|page).yaml" || echo "$changed_files" | grep -qP "^${location}/apis/" ; then
        printf "\nChange detected. Pushing...\n"
        superblocks push "$location"
    else
        printf "\nNo change detected. Skipping push...\n"
    fi
}

# Check if any push-compatible resources have changed
jq -r '.resources[] | select(.resourceType == "APPLICATION") | .location' "$CONFIG_PATH" | while read -r location; do
    printf "\nChecking %s for changes...\n" "$location"
    push_resource "$location"
done

printf "\nChecking complete. Exiting...\n"
