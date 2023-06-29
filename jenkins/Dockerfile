FROM jenkins/jenkins:2.401.2-lts-jdk17

USER root
COPY certs/ca.crt /
COPY --chown=jenkins:jenkins certs/jenkins.jks /var/lib/jenkins/jenkins.jks
RUN keytool -importcert -alias homelab-ca -file /ca.crt \
    -keystore $JAVA_HOME/lib/security/cacerts \
    -storepass changeit \
    -noprompt -trustcacerts && \
    rm -f /ca.crt

USER jenkins
