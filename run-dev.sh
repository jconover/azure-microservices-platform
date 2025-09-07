#!/bin/bash
# run-dev.sh

podman run -it --rm \
  --name fedora-dev-container \
  -v $(pwd):/workspace \
  -v ~/.aws:/root/.aws \
  -v ~/.azure:/root/.azure \
  -w /workspace \
  -h fedora-dev \
  fedora-dev \
  ${@:-/bin/bash}