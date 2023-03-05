# Simple Home Lab Setup with Docker Compose

- [Docker Engine](https://docs.docker.com/engine/).
- [Docker Compose](https://docs.docker.com/compose/).
- [Smallstep CA](https://smallstep.com/docs/step-ca).
- [OpenLDAP](https://github.com/osixia/docker-openldap).
- [PHPLDAPAdmin](https://github.com/osixia/docker-phpLDAPadmin).
- [Keycloak](https://www.keycloak.org/).
- [PostgreSQL](https://hub.docker.com/_/postgres).

```sh
$ cat /etc/os-release
NAME="Pop!_OS"
VERSION="22.04 LTS"
ID=pop
ID_LIKE="ubuntu debian"
PRETTY_NAME="Pop!_OS 22.04 LTS"
VERSION_ID="22.04"
HOME_URL="https://pop.system76.com"
SUPPORT_URL="https://support.system76.com"
BUG_REPORT_URL="https://github.com/pop-os/pop/issues"
PRIVACY_POLICY_URL="https://system76.com/privacy"
VERSION_CODENAME=jammy
UBUNTU_CODENAME=jammy
LOGO=distributor-logo-pop-os

$ docker version
Client:
 Version:           20.10.12
 API version:       1.41
 Go version:        go1.17.3
 Git commit:        20.10.12-0ubuntu4
 Built:             Mon Mar  7 17:10:06 2022
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server:
 Engine:
  Version:          20.10.12
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.17.3
  Git commit:       20.10.12-0ubuntu4
  Built:            Mon Mar  7 15:57:50 2022
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.5.9-0ubuntu3.1
  GitCommit:
 runc:
  Version:          1.1.0-0ubuntu1.1
  GitCommit:
 docker-init:
  Version:          0.19.0
  GitCommit:

$ docker compose version
Docker Compose version v2.12.2

$ openssl version
OpenSSL 3.0.2 15 Mar 2022 (Library: OpenSSL 3.0.2 15 Mar 2022)

$ java -version
openjdk version "17.0.6" 2023-01-17
OpenJDK Runtime Environment (build 17.0.6+10-Ubuntu-0ubuntu122.04)
OpenJDK 64-Bit Server VM (build 17.0.6+10-Ubuntu-0ubuntu122.04, mixed mode, sharing)

$ step version
Smallstep CLI/0.23.2 (linux/amd64)
Release Date: 2023-02-07T00:53:54Z

$ step-ca version
Smallstep CA/0.23.2 (linux/amd64)
Release Date: 2023-02-02T23:10:54Z
```

```sh
# Add or modify env vars
$ cp .env.sample .env

# Internal PKI
$ step ca init
$ step certificate install $(step path)/certs/root_ca.crt
$ cat $(step path)/certs/intermediate_ca.crt > ca-bundle.crt
$ cat $(step path)/certs/root_ca.crt >> ca-bundle.crt
# Adjust certificate lifetimes before starting:
# https://smallstep.com/docs/step-ca/basic-certificate-authority-operations/#adjust-certificate-lifetimes
$ step-ca $(step path)/config/ca.json

# Generate TLS certificates
$ step ca certificate --san=db --san=localhost --san=127.0.0.1 db db.crt db.key
$ mv db.{crt,key} db/certs/

$ step ca certificate --san=ldap --san=localhost --san=127.0.0.1 ldap ldap.crt ldap.key
$ mv ldap.{crt,key} ldap/certs/
$ cp ca-bundle.crt ldap/certs/

$ step ca certificate --san=ldap-admin --san=localhost --san=127.0.0.1 ldap-admin ldap-admin.crt ldap-admin.key
$ step ca certificate --san=localhost --san=127.0.0.1 ldap-admin-client ldap-admin-client.crt ldap-admin-client.key
$ mv ldap-admin.{crt,key} ldap-admin/https-certs/
$ mv ldap-admin-client.{crt,key} ldap-admin/ldap-certs/
$ cp ca-bundle.crt ldap-admin/https-certs/
$ cp ca-bundle.crt ldap-admin/ldap-certs/

$ step ca certificate --san=keycloak --san=localhost --san=127.0.0.1 keycloak keycloak.crt keycloak.key
$ source .env
$ keytool -importcert -alias intermediate -file $(step path)/certs/intermediate_ca.crt -keystore truststore.jks -storepass ${KEYCLOAK_TRUSTSTORE_PASSWORD} -storetype pkcs12
$ keytool -importcert -alias root -file $(step path)/certs/root_ca.crt -keystore truststore.jks -storepass ${KEYCLOAK_TRUSTSTORE_PASSWORD} -storetype pkcs12

$ mv keycloak.{crt,key} secrets/keycloak/
$ mv truststore.jks secrets/keycloak/
$ cp ca-bundle.crt secrets/keycloak/
```

```sh
$ docker compose up -d --build
```