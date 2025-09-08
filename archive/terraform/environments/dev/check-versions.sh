#!/bin/bash
for VERSION in 1.31.1 1.31.2 1.31.3 1.31.4 1.31.5 1.31.6 1.31.7 1.31.8 1.31.9 1.31.10; do
  echo -n "Checking $VERSION... "
  if terraform plan -var="kubernetes_version=$VERSION" &>/dev/null; then
    echo "✓ WORKS!"
    echo "Use: terraform apply -var=\"kubernetes_version=$VERSION\""
    break
  else
    echo "✗ Failed"
  fi
done
