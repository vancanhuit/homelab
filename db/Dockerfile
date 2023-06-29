FROM postgres:15.3-bookworm

COPY init.sql /docker-entrypoint-initdb.d/
COPY --chown=postgres:postgres certs /var/lib/postgresql/certs
