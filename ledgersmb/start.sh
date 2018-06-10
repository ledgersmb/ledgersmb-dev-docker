#!/bin/bash

update_ssmtp.sh
cd /srv/ledgersmb

if [[ ! -f ledgersmb.conf ]]; then
  cp conf/ledgersmb.conf.default ledgersmb.conf
  sed -i \
    -e "s/\(cache_templates = \).*\$/cache_templates = 1/g" \
    -e "s/\(host = \).*\$/\1$POSTGRES_HOST/g" \
    -e "s/\(port = \).*\$/\1$POSTGRES_PORT/g" \
    -e "s/\(default_db = \).*\$/\1$DEFAULT_DB/g" \
    -e "s%\(sendmail   = \).*%#\1/usr/sbin/ssmtp%g" \
    -e "s/# \(smtphost = \).*\$/\1mailhog:1025/g" \
    -e "s/# \(backup_email_from = \).*\$/\1lsmb-backups@example.com/g" \
    /srv/ledgersmb/ledgersmb.conf
fi

if [[ -e bin/ledgersmb-server.psgi ]]; then
   psgi_app=bin/ledgersmb-server.psgi
else
   psgi_app=tools/starman.psgi
fi

# start ledgersmb
exec plackup --port 5762 --preload-app $psgi_app
