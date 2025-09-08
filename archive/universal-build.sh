#!/bin/bash
# Detect runtime
if command -v podman &> /dev/null; then
    RUNTIME="podman"
else
    RUNTIME="docker"
fi

# Same commands work!
$RUNTIME build -t dev-env .
$RUNTIME run -it -v $(pwd):/workspace dev-env bash