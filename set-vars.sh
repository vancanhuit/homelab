#!/bin/bash

set -e

IF=$1
[[ -n ${IF} ]] || {
    echo "Please specify a network interface."
    exit 1
}
HOST_IP=$(ip -4 addr show | grep ${IF} | grep inet | awk '{print $2}' | cut -d/ -f1)
[[ -n ${HOST_IP} ]] || {
    echo "Cannot get IPv4 address from the network interface ${IF}"
    exit 1
}
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