# LedgerSMB Docker development & testing infrastructure

Provides `docker-compose` infrastructure to kick off a local development
and test environment for LedgerSMB.

The infrastructure is based on the `ledgersmb/ledgersmb-dev-postgres` and
`ledgersmb/ledgersmb-dev-lsmb` LedgerSMB containers, the `wernight/phantomjs`
selenium tester container and the `mailhog/mailhog` mail testing tool.

The postgres container is derived from the standard
postgres container, adding the `pgTAP` test infrastructure. The lsmb container
holds everything required to run and test LedgerSMB. This container currently
supports versions 1.5 and master.

# Prerequisites

Apart from the obvious (docker, docker-compose), this project expects
a LedgerSMB Git repository to exist in the current directory.

# Getting started

By running:

```sh
   $ docker-compose -f <path> up -d
```

an execution environment is wrapped around the local repository. `<path>`
is the path of the `docker-compose.yml` held in this repository. Four
containers are created:

* `ledgersmbdevdocker_db_1`,
* `ledgersmbdevdocker_lsmb_1`
* `ledgersmbdevdocker_selenium_1`
* `ledgersmbdevdocker_mailhog_1`

# Development and testing against different perl versions

A script is provided to help create docker images using different Perl
versions. These are based on the
[official Perl docker images](https://hub.docker.com/_/perl/) and are not
optimised for size, but can be useful for testing version-specific
behaviour.

Running:

```sh
   $ ./tools/make_perl_context [perl version]
```

Will create a new docker context for the specified perl version, from
which an image can be built and used in place of the oficial
`ledgersmb/ledgersmb-dev-lsmb` image.

# MailHog

The default configuration, all mail sent from ledgersmb is 'caught' by
[MailHog](https://github.com/mailhog/MailHog). This allows e-mail
functionaility to be tested without sending real messages over the
internet.

MailHog traps all messages, providing a web UI and API to view or retrieve
them.

The `mailhog/mailhog` container serves the web API on port 8025 and accepts
SMTP connections on port 1025.
