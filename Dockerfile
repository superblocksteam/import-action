# Container image that runs your code
FROM node:18-bookworm-slim

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

RUN apt-get update
RUN apt-get upgrade -y
RUN apt install -y git
RUN apt install jq -y

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]