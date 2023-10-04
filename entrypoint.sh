#!/bin/bash

set -e
set -o pipefail

SHA="$1"
TOKEN="$2"
DOMAIN="$3"
CONFIG_PATH="$4"
CLI_VERSION="$5"
GITHUB_TOKEN="$6"

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
    # TODO(taha) Remove the following once the push-compatible version of the CLI is released
    npm set //npm.pkg.github.com/:_authToken "$GITHUB_TOKEN"
    echo "@superblocksteam:registry=https://npm.pkg.github.com/" >> ~/.npmrc

    # Install Superblocks CLI
    printf "\nInstalling Superblocks CLI ($CLI_VERSION)...\n"
    npm install -g @superblocksteam/cli@"$CLI_VERSION"

    # Login to Superblocks
    superblocks config set domain "$DOMAIN"
    superblocks login -t "$TOKEN"
else
    echo "No files changed since the last commit. Skipping push..."
    exit 0
fi

# Function to check if a folder path is in the list of changed files
folder_changed() {
    local folder_path="$1"
    if echo "$changed_files" | grep -q "^$folder_path/"; then
        printf "\nChange detected. Pushing...\n"
        superblocks push "$folder_path"
    fi
}

# Read superblocks config config file json
json_data=$(cat "$CONFIG_PATH")

# Loop through folder paths and check if they have changed
jq -r '.resources[].location' <<< "$json_data" | while IFS= read -r folder_path; do
    printf "\nChecking $folder_path for changes...\n"
    folder_changed "$folder_path"
done
