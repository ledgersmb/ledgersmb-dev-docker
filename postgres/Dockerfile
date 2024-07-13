ARG         PGBASE=14
FROM        postgres:$PGBASE
LABEL       maintainer="LedgerSMB devel@lists.ledgersmb.org"

ARG PGBASE
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y update && \
    apt-get -y install postgresql-$PG_BASE-pgtap && \
    apt-get -y autoremove && \
    apt-get -y autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /docker-entrypoint-initdb.d

COPY lsmb-dev-init.sh /docker-entrypoint-initdb.d/lsmb-dev-init.sh

