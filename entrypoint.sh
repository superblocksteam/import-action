#!/bin/bash

set -e
set -o pipefail

SHA="$1"
TOKEN="$2"
DOMAIN="$3"
CONFIG_PATH="$4"
CLI_VERSION="$5"

SUPERBLOCKS_BOT_NAME="superblocks-app[bot]"

cd "$GITHUB_WORKSPACE"
git config --global --add safe.directory "$GITHUB_WORKSPACE"

# Get the name of the actor who made the last commit
actor_name=$(git show -s --format='%an' "$SHA")
if [ "$actor_name" == "$SUPERBLOCKS_BOT_NAME" ]; then
    printf "\nCommit was made by Superblocks. Skipping push...\n"
    exit 0
fi

# Get the list of changed files in the last commit
changed_files=$(git diff "${SHA}"^ --name-only)

if [ -n "$changed_files" ]; then
    # Install Superblocks CLI
    printf "\nInstalling Superblocks CLI (%s)...\n" "$CLI_VERSION"
    npm install -g @superblocksteam/cli@"$CLI_VERSION"
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
