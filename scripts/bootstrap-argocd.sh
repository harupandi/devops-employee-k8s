#!/usr/bin/env bash

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

RESOURCE_GROUP="${RESOURCE_GROUP:?RESOURCE_GROUP is required}"
AKS_CLUSTER_NAME="${AKS_CLUSTER_NAME:?AKS_CLUSTER_NAME is required}"
ARGOCD_MANIFEST="${ARGOCD_MANIFEST:?ARGOCD_MANIFEST is required}"

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

# -----------------------------------------------------------------------------
# Get AKS credentials
# -----------------------------------------------------------------------------

echo "==> Getting AKS credentials"

az aks get-credentials \
    --resource-group "$RESOURCE_GROUP" \
    --name "$AKS_CLUSTER_NAME" \
    --overwrite-existing

# -----------------------------------------------------------------------------
# Verify cluster access
# -----------------------------------------------------------------------------

echo "==> Verifying AKS access"

kubectl cluster-info
kubectl get nodes

# -----------------------------------------------------------------------------
# Wait for Argo CD
# -----------------------------------------------------------------------------

echo "==> Waiting for Argo CD namespace"

kubectl wait \
    --for=jsonpath='{.status.phase}'=Active \
    namespace/"$ARGOCD_NAMESPACE" \
    --timeout=120s

echo "==> Waiting for Argo CD server"

kubectl rollout status \
    deployment/argocd-server \
    -n "$ARGOCD_NAMESPACE" \
    --timeout=300s

echo "==> Waiting for Argo CD application controller"

kubectl rollout status \
    statefulset/argocd-application-controller \
    -n "$ARGOCD_NAMESPACE" \
    --timeout=300s

# -----------------------------------------------------------------------------
# Bootstrap Argo CD Application
# -----------------------------------------------------------------------------

echo "==> Applying Argo CD Application"

kubectl apply \
    -f "$ARGOCD_MANIFEST"

# -----------------------------------------------------------------------------
# Verify
# -----------------------------------------------------------------------------

echo "==> Argo CD Application"

kubectl get application \
    -A

echo
echo "==> Argo CD bootstrap completed successfully"