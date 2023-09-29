#!/bin/bash

GITHUB_SHA="$1"
SUPERBLOCKS_AUTH_TOKEN="$2"
SUPERBLOCKS_CONFIG_PATH="$3"
GITHUB_USERNAME="$4"
GITHUB_TOKEN="$5"
SUPERBLOCKS_CLI_BRANCH="$6"
BUILD_SUPERBLOCKS_CLI="$7"

# Use the input parameters in your script logic
echo "GitHub SHA: $GITHUB_SHA"
echo "Superblocks Auth Token: $SUPERBLOCKS_AUTH_TOKEN"
echo "Superblocks Config Path: $SUPERBLOCKS_CONFIG_PATH"
echo "GitHub USERNAME: $GITHUB_USERNAME"
echo "GitHub Token: $GITHUB_TOKEN"
echo "Superblocks CLI Branch: $SUPERBLOCKS_CLI_BRANCH"
echo "Build Superblocks CLI: $BUILD_SUPERBLOCKS_CLI"

if [ "$BUILD_SUPERBLOCKS_CLI" = 'true' ] ; then
    echo "Building superblocks-cli"
    git clone "https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/superblocksteam/superblocks-cli.git"
    cd superblocks-cli
    git checkout $SUPERBLOCKS_CLI_BRANCH
    npm install
    npm run build
    ln -s ${PWD}/packages/cli/bin/run /usr/bin/superblocks
    cd ..
else
    npm install -g @superblocksteam/cli@"^1.0.0"
fi

# See if superblocks-cli is installed
which superblocks
superblocks --help

cd $GITHUB_WORKSPACE
git config --global --add safe.directory "$GITHUB_WORKSPACE"

changed_resources=()
# git remote set-head origin -a
# Read superblocks config config file json
json_data=$(cat $SUPERBLOCKS_CONFIG_PATH)
# Get the list of changed files in the last commit
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

# use if we need to output later
echo "imported=COMPLETED" >> $GITHUB_OUTPUT
