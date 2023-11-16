FROM node:18-bookworm-slim

ARG SUPERBLOCKS_CLI_VERSION='1.4.0-rc.1'
ARG NPM_TOKEN

# Install Superblocks CLI dependencies
RUN apt-get update && apt-get install -y \
  git \
  jq \
  && rm -rf /var/lib/apt/lists/*

RUN npm set "//npm.pkg.github.com/:_authToken" "${NPM_TOKEN}" && \
  npm set "@superblocksteam:registry" "https://npm.pkg.github.com/" && \
  # Install Superblocks CLI
  npm install -g @superblocksteam/cli@"${SUPERBLOCKS_CLI_VERSION}" && \
  # Cleanup
  rm -rf ~/.npmrc

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
