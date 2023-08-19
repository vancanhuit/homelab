# Simple Home Lab Setup with Docker Compose

- [Docker Engine](https://docs.docker.com/engine/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Smallstep CA](https://smallstep.com/docs/step-ca)
- [OpenLDAP](https://github.com/osixia/docker-openldap)
- [PHPLDAPAdmin](https://github.com/osixia/docker-phpLDAPadmin)
- [PostgreSQL](https://hub.docker.com/_/postgres)
- [Keycloak](https://www.keycloak.org/)
- [Jenkins](https://jenkins.io)
- [Gitea](https://gitea.io)
- [Gerrit](https://www.gerritcodereview.com/)
- [Docker Registry](https://docs.docker.com/registry/deploying/)
- [Wiki.js](https://js.wiki/)

```sh
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
$ git clone https://github.com/vancanhuit/homelab.git
$ cd homelab

$ echo $(tr -dc A-Za-z0-9 < /dev/urandom | head -c 32 | xargs) > ca.pass
# Change wlp3s0 to an appropriate network interface name on each machine
$ ./set-vars.sh wlp3s0 | tee .env
$ export $(cat .env | xargs)

# Internal PKI
$ step ca init --name Homelab \
               --deployment-type standalone \
               --provisioner ca@home.lab \
               --dns ${HOST_IP} \
               --address :10443 \
               --password-file ./ca.pass
$ sudo step certificate install $(step path)/certs/root_ca.crt
$ mkdir -pv secrets/
$ cp -v $(step path)/certs/root_ca.crt secrets/ca.crt
# Adjust certificate lifetimes before starting:
# https://smallstep.com/docs/step-ca/basic-certificate-authority-operations/#adjust-certificate-lifetimes
$ step-ca $(step path)/config/ca.json --password-file ./ca.pass

# Generate TLS certificates
$ PASSWORD_FILE=./ca.pass ./gen-tls-certs.sh
$ cat >> gerrit/etc/gerrit.config << EOF
[accountPatchReviewDb]
    url = jdbc:postgresql://db:5432/gerrit?ssl,sslmode=verify-full&user=${POSTGRES_USER}&password=${POSTGRES_PASSWORD}
EOF
$ cat > gerrit/etc/secure.config << EOF
[ldap]
    password = ${LDAP_ADMIN_PASSWORD}
[httpd]
    sslKeyPassword = ${GERRIT_KEYSTORE_PASSWORD}
EOF
```

```sh
$ docker compose up -d --build
```

## LDAP users and groups

* Users
    * Base DN: `ou=users,dc=home,dc=lab`.
    * Object class: `inetOrgPerson`.
* Groups:
    * Base DN: `ou=groups,dc=home,dc=lab`.
    * Object class: `groupOfUniqueNames`.

## Keycloak - LDAP data mapping

* Users:
    * First name: `cn`.
    * Last name: `sn`.
    * Full name: `displayName`.
    * Email: `mail`.
    * Username: `uid`.
    * Password: `userPassword`.
* Groups:
    * Name: `cn`.
    * Membership LDAP attribute: `uniqueMember`.
    * Membership attribute type: `dn`.
    * Membership user LDAP attribute: `uid`.

## Configuring LDAP authentication

* [https://www.keycloak.org/docs/latest/server_admin/#_ldap](https://www.keycloak.org/docs/latest/server_admin/#_ldap).
* [https://docs.gitea.com/usage/authentication](https://docs.gitea.com/usage/authentication).
* [https://plugins.jenkins.io/ldap/](https://plugins.jenkins.io/ldap/).
* [https://docs.requarks.io/auth/ldap](https://docs.requarks.io/auth/ldap).
* [https://gerrit-review.googlesource.com/Documentation/config-gerrit.html#ldap](https://gerrit-review.googlesource.com/Documentation/config-gerrit.html#ldap).