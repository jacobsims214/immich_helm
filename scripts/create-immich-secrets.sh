#!/bin/bash
# Create Immich secrets
# Usage: ./scripts/create-immich-secrets.sh [minio-access-key] [minio-secret-key]
#
# Creates the following Kubernetes secret in the immich namespace:
#   - immich-minio-creds
#       ACCESS_KEY_ID     — MinIO access key for CNPG barman-cloud backups
#       SECRET_ACCESS_KEY — MinIO secret key

set -e

NAMESPACE="immich"
SECRET_NAME="immich-minio-creds"

# -----------------------------------------------------------------------
# Resolve credentials
# -----------------------------------------------------------------------
if [ -z "$1" ]; then
    read -rp "MinIO Access Key ID: " ACCESS_KEY
else
    ACCESS_KEY="$1"
fi

if [ -z "$2" ]; then
    read -rsp "MinIO Secret Access Key: " SECRET_KEY
    echo ""
else
    SECRET_KEY="$2"
fi

if [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ]; then
    echo "ERROR: Both ACCESS_KEY_ID and SECRET_ACCESS_KEY are required."
    exit 1
fi

# -----------------------------------------------------------------------
# Ensure namespace exists
# -----------------------------------------------------------------------
if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo "Creating namespace $NAMESPACE..."
    kubectl create namespace "$NAMESPACE"
fi

# -----------------------------------------------------------------------
# Create / replace secret
# -----------------------------------------------------------------------
if kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" &>/dev/null; then
    echo "Secret $SECRET_NAME already exists in namespace $NAMESPACE."
    read -rp "Replace it? (y/N) " -n 1 REPLY
    echo ""
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    kubectl delete secret "$SECRET_NAME" -n "$NAMESPACE"
fi

echo "Creating secret $SECRET_NAME in namespace $NAMESPACE..."
kubectl create secret generic "$SECRET_NAME" \
    --namespace "$NAMESPACE" \
    --from-literal=ACCESS_KEY_ID="$ACCESS_KEY" \
    --from-literal=SECRET_ACCESS_KEY="$SECRET_KEY"

echo ""
echo "Secret created successfully!"
echo ""
echo "Next steps:"
echo "  1. Create the MinIO bucket 'immich-db-backups' on your storage server (192.168.8.251)."
echo "  2. Add this repo to ArgoCD via the UI, then create the Application pointing at this repo."
echo ""
echo "To retrieve the MinIO access key later:"
echo "  kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath='{.data.ACCESS_KEY_ID}' | base64 -d"
