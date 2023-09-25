#!/bin/bash

GITHUB_USERNAME="$1"
REPOSITORY_URL="$2"
SERVER_URL="$3"
GITHUB_TOKEN="$4"
GITHUB_SHA="$5"
SUPERBLOCKS_AUTH_TOKEN="$6"
SUPERBLOCKS_CONFIG_PATH="$7"

# Use the input parameters in your script logic
echo "GitHub Username: $GITHUB_USERNAME"
echo "Repository URL: $REPOSITORY_URL"
echo "Server URL: $SERVER_URL"
echo "GitHub Token: $GITHUB_TOKEN"
echo "GitHub SHA: $GITHUB_SHA"
echo "Superblocks Auth Token: $SUPERBLOCKS_AUTH_TOKEN"
echo "Superblocks Config Path: $SUPERBLOCKS_CONFIG_PATH"

SERVER_URL="${SERVER_URL#https://}"

test="Hello $1 $2 $3 $4 $5 $6 $7"
echo "Cloning repository..."
git clone https://$GITHUB_USERNAME:$GITHUB_TOKEN@$SERVER_URL/$REPOSITORY_URL.git /workspace

cd /workspace

ls /github/workspace

changed_resources=()
git remote set-head origin -a
# Read JSON data from a file named "data.json"
json_data=$(cat $SUPERBLOCKS_CONFIG_PATH)
# Get the list of changed files in the last commit
echo "Commit SHA: $GITHUB_SHA"
changed_files=$(git diff ${GITHUB_SHA}^ --name-only)
echo "Changed files: $changed_files"

# Function to check if a folder path is in the list of changed files
folder_changed() {
local folder_path="$1"
if echo "$changed_files" | grep -q "^$folder_path"; then
    echo "Folder '$folder_path' has changed in the last commit. Call superblocks push --resource $folder_path"
fi
}

# Parse the JSON data to extract folder paths
folder_paths=$(echo "$json_data" | jq -r '[.resources[].location]')

# Loop through folder paths and check if they have changed
jq -r '.resources[].location' <<< "$json_data" | while IFS= read -r folder_path; do
    echo "Checking $folder_path"
    folder_changed "$folder_path"
done

# See if superblocks-cli is installed
superblocks --help

echo "imported=COMPLETED" >> $GITHUB_OUTPUT
