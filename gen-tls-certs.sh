#!/bin/bash

set -e

[[ -n ${PASSWORD_FILE} ]] || {
    echo "Missing PASSWORD_FILE"
    exit 1
}

step ca certificate \
            --san=db \
            --san=localhost \
            --san=127.0.0.1 db db.crt db.key \
            --password-file ${PASSWORD_FILE}
mv -v db.{crt,key} db/certs/

step ca certificate \
            --san=ldap \
            --san=localhost \
            --san=127.0.0.1 ldap ldap.crt ldap.key \
            --password-file ${PASSWORD_FILE}
mv -v ldap.{crt,key} ldap/certs/
cp -v $(step path)/certs/root_ca.crt ldap/certs/ca.crt

step ca certificate \
            --san=ldap-admin \
            --san=localhost \
            --san=127.0.0.1 ldap-admin ldap-admin.crt ldap-admin.key \
            --password-file ${PASSWORD_FILE}
step ca certificate \
            --san=ldap-admin \
            --san=localhost \
            --san=127.0.0.1 ldap-admin ldap-client.crt ldap-client.key \
            --password-file ${PASSWORD_FILE}
mv -v ldap-admin.{crt,key} ldap-admin/https-certs/
mv -v ldap-client.{crt,key} ldap-admin/ldap-certs/
cp -v $(step path)/certs/root_ca.crt ldap-admin/https-certs/ca.crt
cp -v $(step path)/certs/root_ca.crt ldap-admin/ldap-certs/ca.crt

step ca certificate \
          --san=keycloak \
          --san=localhost \
          --san=127.0.0.1 \
          --san=${HOST_IP} keycloak keycloak.crt keycloak.key \
          --password-file ${PASSWORD_FILE}
keytool -importcert -alias ca -file $(step path)/certs/root_ca.crt \
        -keystore truststore.jks \
        -storepass ${KEYCLOAK_TRUSTSTORE_PASSWORD} \
        -storetype pkcs12 \
        -noprompt -trustcacerts
mkdir -pv secrets/keycloak
mv -v keycloak.{crt,key} secrets/keycloak/
mv -v truststore.jks secrets/keycloak/

step ca certificate \
          --san=gitea \
          --san=localhost \
          --san=127.0.0.1 \
          --san=${HOST_IP} gitea gitea.crt gitea.key \
          --password-file ${PASSWORD_FILE}
mv -v gitea.{crt,key} gitea/certs
cp -v $(step path)/certs/root_ca.crt gitea/certs/ca.crt

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
