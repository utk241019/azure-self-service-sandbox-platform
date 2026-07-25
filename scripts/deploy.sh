#!/bin/bash

echo "========================================="
echo " Azure Sandbox Deployment"
echo "========================================="

RESOURCE_GROUP="rg-sandbox-platform"

echo "Checking Azure login..."

az account show > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "You are not logged into Azure."
    echo "Run: az login"
    exit 1
fi

echo "Deploying sandbox resources..."

az deployment group create \
    --resource-group $RESOURCE_GROUP \
    --template-file ./bicep/main.bicep \
    --parameters ./bicep/main.bicepparam

if [ $? -eq 0 ]; then
    echo ""
    echo "Deployment completed successfully."
else
    echo ""
    echo "Deployment failed."
fi