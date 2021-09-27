#!/bin/bash


pgdata=${PGDATA:-/var/lib/postgresql/data/pgdata}

sed -i -e "
s/^#fsync = on/fsync = off/;
s/^#synchronous_commit = on/synchronous_commit = off/;
s/^#log_statement = 'none'/log_statement = 'all'/;
s/^#log_min_duration_statement = -1/log_min_duration_statement = 0/;
s/^#log_duration = off/log_duration = on/;
" $pgdata/postgresql.conf

