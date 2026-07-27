#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage:"
    echo "./scripts/cleanup.sh <resource-group>"
    exit 1
fi

RESOURCE_GROUP=$1

az group delete \
    --name $RESOURCE_GROUP \
    --yes \
    --no-wait