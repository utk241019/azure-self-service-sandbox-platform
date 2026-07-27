#!/bin/bash

#=========================================================
# Azure Self-Service Sandbox Provisioning
#=========================================================

START_TIME=$(date +%s)

#---------------------------------------------------------
# Validate Arguments
#---------------------------------------------------------

if [ $# -ne 5 ]; then
    echo ""
    echo "Usage:"
    echo "./scripts/deploy.sh <resource-group> <sandbox-name> <location> <admin-username> <admin-password>"
    echo ""
    echo "Example:"
    echo "./scripts/deploy.sh rg-dev-team1 devsandbox01 centralindia azureuser Password@123"
    exit 1
fi

RESOURCE_GROUP=$1
SANDBOX_NAME=$2
LOCATION=$3
USERNAME=$4
PASSWORD=$5

echo ""
echo "========================================================="
echo " Azure Self-Service Sandbox Provisioning"
echo "========================================================="
echo "Resource Group : $RESOURCE_GROUP"
echo "Sandbox Name   : $SANDBOX_NAME"
echo "Location       : $LOCATION"
echo ""

#---------------------------------------------------------
# Check Azure Login
#---------------------------------------------------------

echo "Checking Azure login..."

az account show > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "You are not logged into Azure."
    az login || exit 1
fi

#---------------------------------------------------------
# Check Resource Group
#---------------------------------------------------------

echo ""
echo "Checking Resource Group..."

az group exists --name "$RESOURCE_GROUP" > rg_exists.txt

RG_EXISTS=$(cat rg_exists.txt)
rm rg_exists.txt

if [ "$RG_EXISTS" = "true" ]; then

    echo ""
    echo "Resource Group '$RESOURCE_GROUP' already exists."

    while true
    do
        read -p "Deploy into existing Resource Group? (y/n): " CHOICE

        case $CHOICE in
            [Yy]* ) break ;;
            [Nn]* )
                echo "Deployment cancelled."
                exit 0
                ;;
            * )
                echo "Please enter y or n."
                ;;
        esac
    done

else

    echo ""
    echo "Creating Resource Group..."

    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION"

    if [ $? -ne 0 ]; then
        echo "Failed to create Resource Group."
        exit 1
    fi

fi

#---------------------------------------------------------
# Deploy Infrastructure
#---------------------------------------------------------

echo ""
echo "Deploying Azure resources..."

az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file ./bicep/main.bicep \
    --parameters \
        sandboxName="$SANDBOX_NAME" \
        location="$LOCATION" \
        adminUsername="$USERNAME" \
        adminPassword="$PASSWORD"

if [ $? -ne 0 ]; then
    echo ""
    echo "Deployment failed."
    exit 1
fi

#---------------------------------------------------------
# Fetch Deployment Details
#---------------------------------------------------------

VM_NAME="${SANDBOX_NAME}-vm"

PUBLIC_IP=$(az vm show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    -d \
    --query publicIps \
    -o tsv)

PRIVATE_IP=$(az vm show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    -d \
    --query privateIps \
    -o tsv)

END_TIME=$(date +%s)
DURATION=$((END_TIME-START_TIME))

#---------------------------------------------------------
# Deployment Summary
#---------------------------------------------------------

echo ""
echo "========================================================="
echo "        SANDBOX DEPLOYED SUCCESSFULLY"
echo "========================================================="

echo "Resource Group : $RESOURCE_GROUP"
echo "Sandbox Name   : $SANDBOX_NAME"
echo "VM Name        : $VM_NAME"
echo "Location       : $LOCATION"

echo ""
echo "Public IP      : $PUBLIC_IP"
echo "Private IP     : $PRIVATE_IP"

echo ""
echo "SSH Command"
echo "---------------------------------------------------------"
echo "ssh $USERNAME@$PUBLIC_IP"

echo ""
echo "Deployment Time : ${DURATION} seconds"

echo ""
echo "Azure Portal"
echo "---------------------------------------------------------"
echo "https://portal.azure.com"

echo ""
echo "========================================================="