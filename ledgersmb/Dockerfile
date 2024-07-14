FROM        debian:bookworm
LABEL       maintainer="Freelock john@freelock.com"

ARG         DEBIAN_FRONTEND=noninteractive
ARG         branches="1.8,1.9,1.10,1.11,master"
ARG         NODE_MAJOR=20
# 1.9 started using webpack. as soon as we drop 1.8, we can
# drop installing 'uglify'


# Install Perl, Tex, Starman, psql client, and all dependencies
# Without libclass-c3-xs-perl, everything grinds to a halt;
# add it, because it's a 'recommends' it the dep tree, which
# we're skipping, normally

# 'master' and common dependency install:

# make Apt non-interactive

RUN set -x ; \
  echo -n "APT::Install-Recommends \"0\";\nAPT::Install-Suggests \"0\";\n" \
       >> /etc/apt/apt.conf && \
  apt-get -y update && \
  apt-get -y install curl ca-certificates \
                     wget gnupg eatmydata && \
  cat /etc/os-release ; \
  echo "deb http://apt.postgresql.org/pub/repos/apt/ $(grep VERSION_CODENAME /etc/os-release | cut -d= -f2 )-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
  (wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -) && \
  apt-get -y update && \
  apt-get -y install \
    lsb-release \
    postgresql-client libpq5 \
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
    git cpanminus make gcc libperl-dev libcarp-always-perl \
    default-jre-headless \
    ssh tar gzip graphviz \
    gettext procps libtap-parser-sourcehandler-pgtap-perl \
    libtest2-suite-perl libfile-mimeinfo-perl libhtml-lint-perl \
    libpod-projectdocs-perl libyaml-perl \
    libtest-dependencies-perl libtest-exception-perl libtest-trap-perl \
    libperl-critic-perl libmodule-cpanfile-perl libfile-util-perl \
    libclass-trigger-perl libclass-accessor-lite-perl libtest-requires-perl \
    libmodule-install-perl python3-setuptools libdist-zilla-perl


RUN curl -o- https://raw.githubusercontent.com/transifex/cli/master/install.sh | bash ; mv tx /usr/local/bin/

RUN set -x ; \
  mkdir -p /etc/apt/keyrings && \
  (curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg ) && \
  (echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list) && \
  apt-get update && \
  apt-get -y install nodejs && \
  npm install -g yarn && \
  npm install -g uglify-js@">=2.0 <3.0"

# Including postgresql-autodoc in the above total lump didn't work;
#   splitting out did...
#  echo "deb http://deb.debian.org/debian/ sid main non-free contrib" >> /etc/apt/sources.list && \
# RUN apt-get -y -t sid install postgresql-autodoc

# Additional (testing) dependencies up to and including 1.9
RUN apt-get -y install libpath-class-perl libtype-tiny-perl libtype-tiny-xs-perl libclass-factory-perl libyaml-syck-perl libmoox-handlesvia-perl libpod-coverage-perl libhash-merge-perl libpod-pom-perl libfile-share-perl libtext-diff-perl libhtml-selector-xpath-perl libtest-pod-perl libdbd-mock-perl libx12-parser-perl liblog-any-adapter-log4perl-perl libtest-pod-coverage-perl


# Additional dependency up to and including 1.7
RUN apt-get -y install libmime-lite-perl

# Additional dependency up to and including 1.5
RUN apt-get -y install libcgi-simple-perl libhttp-exception-perl libtest-nowarnings-perl

# Additional dependency up to and including 1.6
RUN apt-get -y install liblist-someutils-perl libtest-warn-perl libtest-most-perl libtest-differences-perl libparallel-forkmanager-perl libmodule-util-perl



#RUN git clone https://github.com/cbbrowne/autodoc.git && \
#  cd autodoc && \
#  make install && \
#  cd .. && rm -rf autodoc

# Build time variables
ENV NODE_PATH /usr/lib/node_modules
ARG CACHEBUST


# Install LedgerSMB
RUN set -x ; \
  cd /srv && \
  git clone -b master https://github.com/ledgersmb/LedgerSMB.git ledgersmb && \
  cd ledgersmb && \
  bash -c 'for branch in ${branches//,/ }; do \
    cd /srv/ledgersmb && \
    git checkout $branch && \
    cpanm --quiet --notest --metacpan \
    --with-develop \
    --with-feature=starman \
    --with-feature=latex-pdf-images \
    --with-feature=latex-pdf-ps \
    --with-feature=openoffice \
    --with-feature=xls \
    --with-feature=edi \
    --installdeps . ; \
  done' && \
  cpanm --quiet --notest \
    URL::Encode URL::Encode::XS \
    Pod::ProjectDocs \
    DBD::Mock \
    Devel::Cover Devel::Cover::Report::Coveralls && \
  cpanm --quiet --notest \
    HTML::Template Term::ReadKey ; \
  cd /srv && rm -rf ~/.cpanm ledgersmb && mkdir ledgersmb && \
  git clone https://github.com/cbbrowne/autodoc.git && \
  cd autodoc && \
  make install && \
  cd /srv && rm -rf autodoc
# postgresql_autodoc requires DBI and DBD::Pg too, but those are already installed

# Math::BigFloat 1.999838 from Bookworm is broken for LedgerSMB
RUN set -x ; \
  cpanm --quiet --notest --reinstall \
    Math::BigFloat

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

COPY start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh && \
    mkdir -p /var/www && \
    chown www-data /var/www

RUN ldconfig -v

# Work around an aufs bug related to directory permissions:
RUN mkdir -p /tmp && \
  chmod 1777 /tmp

# Internal Port Expose
EXPOSE 5762
# If ledgersmb.conf does not exist, www-data user needs to be able to create it.
RUN chown www-data /srv/ledgersmb
USER www-data

# Allow ledgersmb-admin to work
ENV PERL5LIB="lib:old/lib"
ENV PATH="/srv/ledgersmb/bin:${PATH}"

WORKDIR /srv/ledgersmb

CMD ["start.sh"]
