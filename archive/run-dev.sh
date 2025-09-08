#!/bin/bash
# run-dev.sh

podman run -it --rm \
  --privileged \
  -v /etc/localtime:/etc/localtime:ro \
  --name fedora-dev-container \
  -v $(pwd):/workspace \
  -v ~/.aws:/root/.aws \
  -v ~/.azure:/root/.azure \
  -w /workspace \
  -h fedora-dev \
  fedora-dev \
  ${@:-/bin/bash}
