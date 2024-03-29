#!/bin/bash

cd /srv/ledgersmb

if [[ ! -f ledgersmb.conf ]]; then
  [[ -f doc/conf/ledgersmb.conf.default ]] \
      && cp doc/conf/ledgersmb.conf.default ledgersmb.conf
  [[ ! -f ledgersmb.conf ]] && cp conf/ledgersmb.conf.default ledgersmb.conf
  sed -i \
    -e "s/\(cache_templates = \).*\$/cache_templates = 1/g" \
    -e "s/\(host = \).*\$/\1$POSTGRES_HOST/g" \
    -e "s/\(port = \).*\$/\1$POSTGRES_PORT/g" \
    -e "s/\(default_db = \).*\$/\1$DEFAULT_DB/g" \
    -e "s%\(sendmail   = \).*%#\1/usr/sbin/ssmtp%g" \
    -e "s/# \(smtphost = \).*\$/\1mailhog:1025/g" \
    -e "s/# \(backup_email_from = \).*\$/\1lsmb-backups@example.com/g" \
    ledgersmb.conf
fi

if [[ -e bin/ledgersmb-server.psgi ]]; then
   psgi_app=/srv/ledgersmb/bin/ledgersmb-server.psgi
else
   psgi_app=/srv/ledgersmb/tools/starman.psgi
fi

# start ledgersmb
PERL5OPT="$PERL5OPT $HARNESS_PERL_SWITCHES"
export PERL5OPT

if [[ -x .local/start.sh ]]
then
   source .local/start.sh
fi

exec plackup -I/srv/ledgersmb/lib -I/srv/ledgersmb/old/lib \
      -R /srv/ledgersmb/lib,/srv/ledgersmb/old/lib,/srv/ledgersmb/workflows,/srv/ledgersmb/ledgersmb.conf,/srv/ledgersmb/ledgersmb.logging,/srv/ledgersmb/ledgersmb.yaml \
      --port 5762 $psgi_app
