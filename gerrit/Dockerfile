FROM gerritcodereview/gerrit:3.8.1

COPY etc/ /var/gerrit/etc/
COPY lib/ /var/gerrit/lib/
COPY certs/gerrit.jks /var/gerrit/etc/

USER root
COPY certs/ca.crt /
RUN keytool -importcert -alias homelab-ca -file /ca.crt \
    -keystore /usr/lib/jvm/jre/lib/security/cacerts \
    -storepass changeit \
    -noprompt -trustcacerts && \
    rm -f /ca.crt
USER gerrit
