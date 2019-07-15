#!/bin/bash

set -e

#echo "HERE"
#cat /configs/config.hcl



if [ -z "$CONFIG" ]; then
    echo "No config file passed"
    exit 
fi

if [[ ! -z "$VAULT_ADDR" ]]; then
    SA=${SERVICE_NAME:-"vault-auth"}
    VAULT_ADDR=${VAULT_ADDR:-"http://127.0.0.1:8200"}
    SA_NS=${SA_NAMESPACE:-"default"}


    if [ -z "$VAULT_ROLE" ]; then
        echo "Unable to find role: VAULT_ROLE"
        exit 
    fi

    # Get the service name
    VAULT_SA_NAME=$(kubectl get sa $SA -n $SA_NS -o jsonpath="{.secrets[*]['name']}")
    # Get the SA JWT token
    SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -n $SA_NS -o jsonpath="{.data.token}" | base64 --decode; echo)
    
    TOKEN=$(curl \
        --request POST \
        --data '{"jwt": "'${SA_JWT_TOKEN}'", "role": "'${VAULT_ROLE}'"}' \
        ${VAULT_ADDR}/v1/auth/kubernetes/login \
        |jq '.auth.client_token' --raw-output)


    if [ -z "$TOKEN" ]; then
        echo "Unable to get token for ${ROLE} from vault"
        exit 
    fi

    # VAULT_TOKEN is used to authenticate against vault allowing the program to get information from vault
    export VAULT_TOKEN=$TOKEN
fi
#-log-level debug

consul-template -config $CONFIG $FLAGS

echo "DONE"
