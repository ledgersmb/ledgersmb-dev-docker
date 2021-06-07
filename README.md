# LedgerSMB Docker development & testing infrastructure

Provides `docker-compose` infrastructure to kick off a local development
and test environment for LedgerSMB.

The infrastructure is based on the `ledgersmb/ledgersmb-dev-postgres`,
`ledgersmb/ledgersmb-dev-nginx` and `ledgersmb/ledgersmb-dev-lsmb`
LedgerSMB containers, the `wernight/phantomjs`
selenium tester container and the `mailhog/mailhog` mail testing tool.

The ledgersmb-dev-postgres container is derived from the standard
postgres container, adding the `pgTAP` test infrastructure and setting
aggressive database performance optimizations to help speed up testing.

The ledgersmb-dev-lsmb container holds everything required to run and
test LedgerSMB. This container currently supports versions 1.5, 1.6, 1.7,
1.8 and master -- the image gets updated regularly to include dependencies
for specific feature branches.

# Prerequisites

Apart from the obvious (docker, docker-compose), this project expects
a LedgerSMB Git repository to exist in the current directory.

# Getting started (from scratch)

```sh
$ git clone https://github.com/ledgersmb/LedgerSMB.git
$ git clone https://github.com/ledgersmb/ledgersmb-dev-docker.git ldd
$ cd LedgerSMB
$ ../ldd/lsmb-dev master pull
$ ../ldd/lsmb-dev master up -d
======================================
== LedgerSMB 'master'
== should be available at
======================================
http://172.20.0.6
======================================
```

Ten containers are created:

* `ldmaster_db_1`
* `ldmaster_lsmb_1`
* `ldmaster_mailhog_1`
* `ldmaster_proxy_1`
* `ldmaster_selenium_1`
* `ldmaster_chrome_1`
* `ldmaster_chrome_2`
* `ldmaster_chrome_3`
* `ldmaster_chrome_4`
* `ldmaster_chrome_5`

The `LedgerSMB` directory is mapped to the `/srv/ledgersmb` directory
inside the `ldmaster_lsmb_1` and `ldmaster_proyxy_1` containers. The
database container creates its database storage on a "RAM drive",
meaning that restarting the container causes all existing databases
to be flushed.

A Selenium grid is created with a hub and 5 copies of the browser you selected,
Chrome is set per default. Firefox and Opera are supported.

## Creating JavaScript output

To use the web-app, a "transpiled" version of the JavaScript code must
be available in the `UI/js/` directory. This is created from `UI/js-src/`
by running

```bash
$ make dojo
```

After editing the code in `UI/js-src/`, this command needs to be re-run.

## Accessing LedgerSMB

As per the example above, you should be able to browse to
http://172.20.0.6/setup.pl to create a test database. The password of
the `postgres` user is `abc`.

Similarly, when a test company exists, browsing to
http://172.20.0.6/login.pl allows to log into the company.

## Running tests

Three commands exist to run tests:

* `make test`\
   Runs the tests in the `t/` directory
* `make devtest`\
   Runs the tests in the `t/` and `xt/` directories
* `make pherkin`\
  Runs the tests `xt/**/*.feature`
\
The set of tests to be run can be restricted using the `TESTS` Makefile
variable:

```bash
$ make test TESTS=t/01-load.t
```

The combination of the `lsmb-dev` command and the use of `make` takes care
of making sure the tests are being run inside the `ldmaster_lsmb_1` docker
container.

## Restarting LedgerSMB after making (Perl) edits

It's best to restart the single `ldmaster_lsmb_1` container using Docker
directly by running

```bash
$ docker restart ldmaster_lsmb_1
```

Although the command `../ldd/lsmb-dev master restart` works, it usually
comes up with different IP addresses on the containers than the original
`up -d` command.

## Retaining databases between container restarts

The database gets stored in RAM for performance reasons. If however,
you want/need to retain databases between container restarts, you can
change the backing storage to harddisk/ssd by changing

```yaml
volumes:
  dbdata:
    driver_opts:
      type: tmpfs
      device: tmpfs
```

to

```yaml
volumes:
  dbdata:
#    driver_opts:
#      type: tmpfs
#      device: tmpfs
```

## Multiple parallel test environments

Multiple test environments, based on multiple clones, can be created
using a different first-argument to the `lsmb-dev` script. E.g. a
1.8 testing environment can be created using:

```sh
$ git clone -b 1.8 https://github.com/ledgersmb/LedgerSMB.git
$ git clone https://github.com/ledgersmb/ledgersmb-dev-docker.git ldd
$ cd LedgerSMB
$ ../ldd/lsmb-dev 18 pull
$ BROWSER=firefox ../ldd/lsmb-dev 18 up -d
```
This creates 10 additional containers:
* `ld18_db_1`
* `ld18_lsmb_1`
* `ld18_selenium_1`
* `ld18_mailhog_1`
* `ld18_proxy_1`
* `ld18_selenium_1`
* `ld18_firefox_1`
* `ld18_firefox_2`
* `ld18_firefox_3`
* `ld18_firefox_4`
* `ld18_firefox_5`


# DB (PostgreSQL)

Please note that the database container patches the PostgreSQL configuration
for faster test performance rather than the reliability levels you'd want
for your production environment (that is, data consistency isn't fully
guaranteed on outage, which shouldn't be a problem for tests -- we'll simply
re-run them -- but isn't a risk to be taken in production).


# MailHog

The default configuration, all mail sent from ledgersmb is 'caught' by
[MailHog](https://github.com/mailhog/MailHog). This allows e-mail
functionaility to be tested without sending real messages over the
internet.

MailHog traps all messages, providing a web UI and API to view or retrieve
them.

The `mailhog/mailhog` container serves the web API on port 8025 and accepts
SMTP connections on port 1025.



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
