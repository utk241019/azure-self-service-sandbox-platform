#!/bin/bash

# -------------------------------------------------
# Azure Self-Service Sandbox Provisioning
# -------------------------------------------------

if [ $# -ne 5 ]; then
    echo ""
    echo "Usage:"
    echo "./scripts/deploy.sh <resource-group> <sandbox-name> <location> <admin-username> <admin-password>"
    echo ""
    echo "Example:"
    echo "./scripts/deploy.sh rg-payroll-dev payroll01 centralindia azureuser Password@123"
    exit 1
fi

RESOURCE_GROUP=$1
SANDBOX_NAME=$2
LOCATION=$3
USERNAME=$4
PASSWORD=$5

echo ""
echo "=============================================="
echo " Azure Self-Service Sandbox Provisioning"
echo "=============================================="

echo "Resource Group : $RESOURCE_GROUP"
echo "Sandbox Name   : $SANDBOX_NAME"
echo "Location       : $LOCATION"
echo ""

# ---------------------------------------
# Check Azure Login
# ---------------------------------------

echo "Checking Azure login..."

az account show > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Not logged into Azure."
    az login || exit 1
fi

# ---------------------------------------
# Check Resource Group
# ---------------------------------------

echo ""
echo "Checking Resource Group..."

az group show --name "$RESOURCE_GROUP" > /dev/null 2>&1

if [ $? -eq 0 ]; then

    echo ""
    echo "Resource Group '$RESOURCE_GROUP' already exists."

    while true
    do
        read -p "Deploy into existing Resource Group? (y/n): " CHOICE

        case $CHOICE in
            [Yy]* )
                break
                ;;
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

    echo "Resource Group not found."
    echo "Creating Resource Group..."

    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION"

    if [ $? -ne 0 ]; then
        echo "Failed to create Resource Group."
        exit 1
    fi

fi

# ---------------------------------------
# Deploy Infrastructure
# ---------------------------------------

echo ""
echo "Deploying infrastructure..."

az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file ./bicep/main.bicep \
    --parameters \
        sandboxName="$SANDBOX_NAME" \
        location="$LOCATION" \
        adminUsername="$USERNAME" \
        adminPassword="$PASSWORD"

if [ $? -eq 0 ]; then

    echo ""
    echo "=============================================="
    echo "Sandbox deployed successfully!"
    echo "=============================================="

    echo "Resource Group : $RESOURCE_GROUP"
    echo "Sandbox Name   : $SANDBOX_NAME"

else

    echo ""
    echo "Deployment failed."

fi