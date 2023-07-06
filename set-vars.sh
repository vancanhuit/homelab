#!/bin/bash

set -e

if=$1
HOST_IP=$(ip -4 addr show | grep ${if} | grep inet | awk '{print $2}' | cut -d/ -f1)
echo "HOST_IP=${HOST_IP}"

echo "POSTGRES_USER=homelab"

vars=(
    POSTGRES_PASSWORD \
    LDAP_ADMIN_PASSWORD \
    KEYCLOAK_ADMIN_PASSWORD \
    KEYCLOAK_TRUSTSTORE_PASSWORD \
    JENKINS_KEYSTORE_PASSWORD \
    GERRIT_KEYSTORE_PASSWORD
)

for var in "${vars[@]}"; do
    echo "${var}=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 32 | xargs)"
done