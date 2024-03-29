#!/bin/bash

set -e

[[ -n ${PASSWORD_FILE} ]] || {
    echo "Missing PASSWORD_FILE"
    exit 1
}

[[ -n ${HOST_IP} ]] || {
    echo "Missing HOST_IP"
    exit 1
}

[[ -e db/certs/db.crt ]] || {
    step ca certificate \
            --san=db \
            --san=localhost \
            --san=127.0.0.1 db db.crt db.key \
            --password-file ${PASSWORD_FILE}
    mv -v db.{crt,key} db/certs/
}

[[ -e ldap/certs/ldap.crt ]] || {
    step ca certificate \
            --san=ldap \
            --san=localhost \
            --san=127.0.0.1 ldap ldap.crt ldap.key \
            --password-file ${PASSWORD_FILE}
    mv -v ldap.{crt,key} ldap/certs/
    cp -v $(step path)/certs/root_ca.crt ldap/certs/ca.crt
}

[[ -e ldap-admin/https-certs/ldap-admin.crt ]] || {
    step ca certificate \
            --san=ldap-admin \
            --san=localhost \
            --san=127.0.0.1 ldap-admin ldap-admin.crt ldap-admin.key \
            --password-file ${PASSWORD_FILE}
    mv -v ldap-admin.{crt,key} ldap-admin/https-certs/
    cp -v $(step path)/certs/root_ca.crt ldap-admin/https-certs/ca.crt
}
[[ -e ldap-admin/ldap-certs/ldap-client.crt ]] || {
    step ca certificate \
            --san=ldap-admin \
            --san=localhost \
            --san=127.0.0.1 ldap-admin ldap-client.crt ldap-client.key \
            --password-file ${PASSWORD_FILE}
    mv -v ldap-client.{crt,key} ldap-admin/ldap-certs/
    cp -v $(step path)/certs/root_ca.crt ldap-admin/ldap-certs/ca.crt
}

[[ -e secrets/keycloak.crt ]] || {
     step ca certificate \
          --san=keycloak \
          --san=localhost \
          --san=127.0.0.1 \
          --san=${HOST_IP} keycloak keycloak.crt keycloak.key \
          --password-file ${PASSWORD_FILE}
}
[[ -e secrets/keycloak.jks ]] || {
    keytool -importcert -alias homelab-ca -file $(step path)/certs/root_ca.crt \
            -keystore keycloak.jks \
            -storepass ${KEYCLOAK_TRUSTSTORE_PASSWORD} \
            -storetype pkcs12 \
            -noprompt -trustcacerts
    mv -v keycloak.{crt,key} secrets/
    mv -v keycloak.jks secrets/
}

[[ -e gitea/certs/gitea.crt ]] || {
    step ca certificate \
          --san=gitea \
          --san=localhost \
          --san=127.0.0.1 \
          --san=${HOST_IP} gitea gitea.crt gitea.key \
          --password-file ${PASSWORD_FILE}
    mv -v gitea.{crt,key} gitea/certs
    cp -v $(step path)/certs/root_ca.crt gitea/certs/ca.crt
}

[[ -e jenkins/certs/jenkins.jks ]] || {
    step ca certificate \
          --san=jenkins \
          --san=localhost \
          --san=127.0.0.1 \
          --san=${HOST_IP} jenkins jenkins.crt jenkins.key \
          --password-file ${PASSWORD_FILE}
    openssl pkcs12 -export \
                   -in jenkins.crt \
                   -inkey jenkins.key \
                   -out jenkins.p12 \
                   -password pass:${JENKINS_KEYSTORE_PASSWORD}
    keytool -importkeystore \
            -srckeystore jenkins.p12 \
            -srcstorepass ${JENKINS_KEYSTORE_PASSWORD} \
            -destkeystore jenkins.jks \
            -deststorepass ${JENKINS_KEYSTORE_PASSWORD}
    cp -v $(step path)/certs/root_ca.crt jenkins/certs/ca.crt
    mv -v jenkins.jks jenkins/certs/
}

[[ -e gerrit/certs/gerrit.jks ]] || {
    step ca certificate \
          --san=gerrit \
          --san=localhost \
          --san=127.0.0.1 \
          --san=${HOST_IP} gerrit gerrit.crt gerrit.key \
          --password-file ${PASSWORD_FILE}
    openssl pkcs12 -export \
                   -in gerrit.crt \
                   -inkey gerrit.key \
                   -out gerrit.p12 \
                   -password pass:${GERRIT_KEYSTORE_PASSWORD}
    keytool -importkeystore \
            -srckeystore gerrit.p12 \
            -srcstorepass ${GERRIT_KEYSTORE_PASSWORD} \
            -destkeystore gerrit.jks \
            -deststorepass ${GERRIT_KEYSTORE_PASSWORD}
    cp -v $(step path)/certs/root_ca.crt gerrit/certs/ca.crt
    mv -v gerrit.jks gerrit/certs/
}

[[ -e secrets/registry.crt ]] || {
    step ca certificate \
          --san=registry \
          --san=localhost \
          --san=127.0.0.1 \
          --san=${HOST_IP} registry registry.crt registry.key \
          --password-file ${PASSWORD_FILE}
    mv -v registry.{crt,key} secrets/
}

[[ -e secrets/wiki.pem ]] || {
    step ca certificate \
          --san=wiki \
          --san=localhost \
          --san=127.0.0.1 \
          --san=${HOST_IP} wiki wiki.pem wiki-key.pem \
          --password-file ${PASSWORD_FILE}
    mv -v wiki.pem secrets/
    mv -v wiki-key.pem secrets/
}