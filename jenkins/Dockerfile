FROM jenkins/jenkins:2.401.2-lts-jdk17

COPY --chown=jenkins:jenkins certs/jenkins.jks /var/lib/jenkins/jenkins.jks

USER root
COPY certs/ca.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates
RUN keytool -importcert -alias homelab-ca -file /usr/local/share/ca-certificates/ca.crt \
    -keystore $JAVA_HOME/lib/security/cacerts \
    -storepass changeit \
    -noprompt -trustcacerts

USER jenkins
