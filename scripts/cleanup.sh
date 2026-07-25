#!/bin/bash

echo "========================================="
echo " Azure Sandbox Cleanup"
echo "========================================="

RESOURCE_GROUP="rg-sandbox-platform"

echo "Deleting Resource Group..."

az group delete \
    --name $RESOURCE_GROUP \
    --yes

echo ""
echo "Cleanup completed."