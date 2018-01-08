FROM perl:5.14
MAINTAINER  Nick Prater nick@npbroadcast.com

# ledgersmb development and test container created
# from official perl images.

# Dockerfile based on official ledgersmb/ledgersmb-dev-lsmb

# No point installing perl libraries via apt-get as we're
# using the official perl container, which doesn't use the
# debian system libraries.
#
# gcc, cpanminus, git are already installed in the base perl image

RUN echo -n "APT::Install-Recommends \"0\";\nAPT::Install-Suggests \"0\";\n" \
       >> /etc/apt/apt.conf && \
  DEBIAN_FRONTEND=noninteractive apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install curl ca-certificates \
                                            gnupg2 && \
  curl -L https://deb.nodesource.com/setup_6.x -o ./setup && \
  bash ./setup && rm ./setup && \
  DEBIAN_FRONTEND=noninteractive apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install \
    postgresql-client \
    texlive-latex-recommended \
    texlive-xetex \
    ssmtp \
    nodejs lsb-release \
    gettext procps  \
  python-pip python-urllib3 python-six && \
  pip install transifex-client && \
  npm install -g uglify-js@">=2.0 <3.0"

# 1.5 additional dependency install:
#    JRE is for running the dojo build process using ClosureCompiler
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
      default-jre-headless

# Build time variables
ENV NODE_PATH /usr/local/lib/node_modules
ARG CACHEBUST

# Install LedgerSMB
RUN cd /srv && mkdir ledgersmb && cd ledgersmb && \
  wget https://github.com/ledgersmb/LedgerSMB/raw/master/cpanfile && \
  cpanm --quiet --notest \
    --with-develop \
    --with-feature=starman \
    --with-feature=latex-pdf-images \
    --with-feature=latex-pdf-ps \
    --with-feature=openoffice \
    --with-feature=xls \
    --with-feature=edi \
    --installdeps . && \
  rm cpanfile && \
  wget https://github.com/ledgersmb/LedgerSMB/raw/1.5/cpanfile && \
  cpanm --quiet --notest \
    --with-develop \
    --with-feature=starman \
    --with-feature=latex-pdf-images \
    --with-feature=latex-pdf-ps \
    --with-feature=openoffice \
    --with-feature=edi \
    --installdeps . && \
  rm cpanfile && \
  cpanm --quiet --notest Pod::ProjectDocs && \
  rm -rf ~/.cpanm && \
  cd .. && rm -rf ledgersmb && mkdir ledgersmb

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
COPY update_ssmtp.sh /usr/local/bin/update_ssmtp.sh

RUN chown www-data /etc/ssmtp /etc/ssmtp/ssmtp.conf && \
  chmod +x /usr/local/bin/update_ssmtp.sh /usr/local/bin/start.sh && \
  mkdir -p /var/www

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
