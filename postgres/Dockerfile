ARG PGBASE=latest
ARG PGLATEST=14
FROM        postgres:$PGBASE

# Announce we want to re-use PGBASE
ARG PGBASE
ARG PGLATEST
LABEL       maintainer="LedgerSMB devel@lists.ledgersmb.org"

RUN DEBIAN_FRONTEND="noninteractive" apt-get -y update && \
    apt-get -y install postgresql-$(echo $PGBASE | sed -e "s/latest/$PGLATEST/")-pgtap && \
    apt-get -y autoremove && \
    apt-get -y autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /docker-entrypoint-initdb.d

COPY lsmb-dev-init.sh /docker-entrypoint-initdb.d/lsmb-dev-init.sh

