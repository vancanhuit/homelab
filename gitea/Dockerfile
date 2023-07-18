FROM gitea/gitea:1.20.0

COPY --chown=git:git certs/gitea.crt /data/gitea/
COPY --chown=git:git certs/gitea.key /data/gitea/
COPY certs/ca.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates
