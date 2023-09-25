# Container image that runs your code
FROM node:alpine3.18

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh
RUN npm install -g @superblocksteam/cli@latest
RUN apk update
RUN apk upgrade
RUN apk add git
RUN apk add bash
RUN apk add jq

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]