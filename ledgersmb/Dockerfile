FROM        debian:buster
LABEL       maintainer="Freelock john@freelock.com"


# Install Perl, Tex, Starman, psql client, and all dependencies
# Without libclass-c3-xs-perl, everything grinds to a halt;
# add it, because it's a 'recommends' it the dep tree, which
# we're skipping, normally

# 'master' and common dependency install:

RUN echo -n "APT::Install-Recommends \"0\";\nAPT::Install-Suggests \"0\";\n" \
       >> /etc/apt/apt.conf && \
  DEBIAN_FRONTEND="noninteractive" apt-get -y update && \
  DEBIAN_FRONTEND="noninteractive" apt-get -y install curl ca-certificates \
                                      wget gnupg2 && \
  curl -L https://deb.nodesource.com/setup_16.x -o ./setup && \
  bash ./setup && rm ./setup && \
  DEBIAN_FRONTEND="noninteractive" apt-get -y update && \
  DEBIAN_FRONTEND="noninteractive" apt-get -y upgrade && \
  DEBIAN_FRONTEND="noninteractive" apt-get -y install \
    gnupg \
    libauthen-sasl-perl libcgi-emulate-psgi-perl libconfig-inifiles-perl \
    libcookie-baker-perl libdbd-pg-perl libdbi-perl libdata-uuid-perl \
    libdatetime-perl libdatetime-format-strptime-perl \
    libemail-sender-perl libemail-stuffer-perl libfile-find-rule-perl \
    libhtml-escape-perl libhttp-headers-fast-perl libio-stringy-perl \
    libjson-maybexs-perl libcpanel-json-xs-perl libjson-pp-perl \
    liblist-moreutils-perl \
    liblocale-maketext-perl liblocale-maketext-lexicon-perl \
    liblog-log4perl-perl libmime-types-perl \
    libmath-bigint-gmp-perl libmodule-runtime-perl libmoo-perl \
    libmoox-types-mooselike-perl libmoose-perl \
    libmoosex-nonmoose-perl libnumber-format-perl \
    libpgobject-perl libpgobject-simple-perl libpgobject-simple-role-perl \
    libpgobject-type-bigfloat-perl libpgobject-type-datetime-perl \
    libpgobject-type-bytestring-perl libpgobject-util-dbmethod-perl \
    libpgobject-util-dbadmin-perl libplack-perl \
    libplack-builder-conditionals-perl libplack-middleware-reverseproxy-perl \
    libplack-request-withencoding-perl libscope-guard-perl \
    libsession-storage-secure-perl libstring-random-perl \
    libtemplate-perl libtext-csv-perl libtext-csv-xs-perl \
    libtext-markdown-perl libtry-tiny-perl libversion-compare-perl \
    libxml-simple-perl libnamespace-autoclean-perl \
    starman starlet libhttp-parser-xs-perl \
    libtemplate-plugin-latex-perl libtex-encode-perl \
    libxml-twig-perl libopenoffice-oodoc-perl \
    libexcel-writer-xlsx-perl libspreadsheet-writeexcel-perl \
    libclass-c3-xs-perl liblocale-codes-perl \
    texlive-latex-recommended texlive-fonts-recommended \
    texlive-xetex fonts-liberation \
    lsb-release \
    git cpanminus make gcc nodejs libperl-dev lsb-release libcarp-always-perl \
    ssh tar gzip \
    gettext procps libtap-parser-sourcehandler-pgtap-perl \
    libtest-dependencies-perl libtest-exception-perl libtest-trap-perl \
    libperl-critic-perl libmodule-cpanfile-perl libfile-util-perl \
    libclass-trigger-perl libclass-accessor-lite-perl libtest-requires-perl \
    libmodule-install-perl python3-setuptools libdist-zilla-perl \
    python3-pip python3-urllib3 && \
  pip3 install transifex-client && \
  pip3 install --upgrade urllib3 && \
  npm install -g uglify-js@">=2.0 <3.0" && \
  echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
  (wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -) && \
  DEBIAN_FRONTEND="noninteractive" apt-get -y update && \
  DEBIAN_FRONTEND="noninteractive" apt-get -y install postgresql-client

# Including postgresql-autodoc in the above total lump didn't work;
#   splitting out did...
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install postgresql-autodoc graphviz

# Additional dependency up to and including 1.7
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install libmime-lite-perl

# we need at least npm 7.x for our code base; Node 12.x comes with npm 6.x...
RUN npm install -g npm

RUN git clone https://github.com/cbbrowne/autodoc.git && \
  cd autodoc && \
  make install && \
  cd .. && rm -rf autodoc

# Build time variables
ENV NODE_PATH /usr/lib/node_modules
ARG CACHEBUST

# Install LedgerSMB
RUN cd /srv && \
  git clone -b master https://github.com/ledgersmb/LedgerSMB.git ledgersmb && \
  cd ledgersmb && \
  git remote update && \
  cpanm --quiet --notest \
    --with-develop \
    --with-feature=starman \
    --with-feature=latex-pdf-images \
    --with-feature=latex-pdf-ps \
    --with-feature=openoffice \
    --with-feature=xls \
    --with-feature=edi \
    --installdeps . && \
  git checkout -b 1.5 origin/1.5 && \
  cpanm --quiet --notest \
    --with-develop \
    --with-feature=starman \
    --with-feature=latex-pdf-ps \
    --with-feature=openoffice \
    --with-feature=edi \
    --installdeps . && \
  git checkout -b 1.6 origin/1.6 && \
  cpanm --quiet --notest \
    --with-develop \
    --with-feature=starman \
    --with-feature=latex-pdf-ps \
    --with-feature=openoffice \
    --with-feature=edi \
    --installdeps . && \
  git checkout -b 1.7 origin/1.7 && \
  cpanm --quiet --notest \
    --with-develop \
    --with-feature=starman \
    --with-feature=latex-pdf-ps \
    --with-feature=openoffice \
    --with-feature=edi \
    --installdeps . && \
  git checkout -b 1.8 origin/1.8 && \
  cpanm --quiet --notest \
    --with-develop \
    --with-feature=starman \
    --with-feature=latex-pdf-ps \
    --with-feature=openoffice \
    --with-feature=edi \
    --installdeps . && \
  git checkout -b 1.9 origin/1.9 && \
  cpanm --quiet --notest \
    --with-develop \
    --with-feature=starman \
    --with-feature=latex-pdf-ps \
    --with-feature=openoffice \
    --with-feature=edi \
    --installdeps . && \
  make dojo && \
  cpanm --quiet --notest Dancer2 Dancer2::Session::Cookie Dancer2::Plugin::Auth::Extensible URL::Encode URL::Encode::XS && \
  cpanm --quiet --notest Pod::ProjectDocs && \
  cpanm --quiet --notest DBD::Mock && \
  cpanm --quiet --notest Devel::Cover && \
  cpanm --quiet --notest Devel::Cover::Report::Coveralls && \
  rm -rf ~/.cpanm && \
  cd ~/ && rm -rf ledgersmb && mkdir ledgersmb

# Configure outgoing mail to use host, other run time variable defaults

## sSMTP
ENV SSMTP_ROOT ar@example.com
ENV SSMTP_MAILHUB 172.17.0.1
ENV SSMTP_HOSTNAME 172.17.0.1
#ENV SSMTP_USE_STARTTLS
#ENV SSMTP_AUTH_USER
#ENV SSMTP_AUTH_PASS
ENV SSMTP_FROMLINE_OVERRIDE YES
#ENV SSMTP_AUTH_METHOD

ENV POSTGRES_HOST postgres
ENV POSTGRES_PORT 5432
ENV DEFAULT_DB lsmb

# Upgrade npm from v6 provided by buster
RUN npm install -g npm@7.14.0

COPY start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh && \
    mkdir -p /var/www && \
    chown www-data /var/www

# Work around an aufs bug related to directory permissions:
RUN mkdir -p /tmp && \
  chmod 1777 /tmp

# Internal Port Expose
EXPOSE 5762
# If ledgersmb.conf does not exist, www-data user needs to be able to create it.
RUN chown www-data /srv/ledgersmb
USER www-data

WORKDIR /srv/ledgersmb

CMD ["start.sh"]
