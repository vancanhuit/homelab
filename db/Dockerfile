FROM postgres:15.2-bullseye

COPY init.sql /docker-entrypoint-initdb.d/
COPY --chown=postgres:postgres certs /var/lib/postgresql/certs
