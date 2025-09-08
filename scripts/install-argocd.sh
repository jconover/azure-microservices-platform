#!/bin/bash

# Script to install ArgoCD in the cluster

NAMESPACE="argocd"

echo "Creating ArgoCD namespace..."
kubectl create namespace $NAMESPACE

echo "Installing ArgoCD..."
kubectl apply -n $NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n $NAMESPACE --timeout=300s

echo "Getting initial admin password..."
kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

echo ""
echo "ArgoCD installed successfully!"
echo "To access ArgoCD UI, run:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Then navigate to https://localhost:8080"
