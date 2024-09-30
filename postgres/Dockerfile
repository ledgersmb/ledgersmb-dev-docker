ARG         PGBASE=17
FROM        postgres:$PGBASE
LABEL       maintainer="LedgerSMB devel@lists.ledgersmb.org"

# Note: $PG_MAJOR comes from the parent postgres image
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y update && \
    apt-get -y install postgresql-$PG_MAJOR-pgtap && \
    apt-get -y autoremove && \
    apt-get -y autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /docker-entrypoint-initdb.d

COPY lsmb-dev-init.sh /docker-entrypoint-initdb.d/lsmb-dev-init.sh

