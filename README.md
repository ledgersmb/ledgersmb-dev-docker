# LedgerSMB Docker development & testing infrastructure

Provides `docker-compose` infrastructure to kick off a local development
and test environment for LedgerSMB.

The infrastructure is based on the `ledgersmbdev/ledgersmb-dev-postgres`,
`ledgersmbdev/ledgersmb-dev-nginx` and `ledgersmbdev/ledgersmb-dev-lsmb`
LedgerSMB containers, the selenium tester containers and the
`mailhog/mailhog` mail testing tool.

The ledgersmb-dev-postgres container is derived from the standard
Postgres container, adding the `pgTAP` test infrastructure and setting
aggressive database performance optimizations to help speed up testing.

The ledgersmb-dev-lsmb container holds everything required to run and
test LedgerSMB. This container currently supports versions 1.6, 1.7,
1.8, 1.9 and master -- the image gets updated regularly to include dependencies
for specific feature branches.

## Quick Start Prerequisites

The Quick Start shell script below will install everything necessary to develop and test
LedgerSMB. This script should work with any linux system that has
`docker` and `make` installed and where the current `$USER` is in the docker group. 
These prerequisites can be met using the following on Ubuntu:

```sh
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose make
sudo usermod -a -G docker $USER
```

## Quick Start (from scratch)

The following bash shell script was tested on Ubuntu 22.04. It installs LedgerSMB and runs
the development test suite.  Details about each step appear below the script.

```sh
#!/bin/bash
set -e -x

# Not for use in Production.

# Clone the LedgerSMB git master repository
git clone https://github.com/ledgersmb/LedgerSMB.git

# Set up LedgerSMB configuration for development
mkdir LedgerSMB/logs
mkdir LedgerSMB/screens
cp LedgerSMB/doc/conf/ledgersmb.conf.default LedgerSMB/ledgersmb.conf
sed -i -e 's/db_namespace = public/db_namespace = xyz/' LedgerSMB/ledgersmb.conf
sed -i -e 's/host = localhost/host = postgres/' LedgerSMB/ledgersmb.conf

# Clone the LedgerSMB development docker master repository
git clone https://github.com/ledgersmb/ledgersmb-dev-docker.git ldd

# Start the docker containers
cd LedgerSMB
../ldd/lsmb-dev master pull
../ldd/lsmb-dev master up -d

# Make the runtime javascript (see options below)
make jsdev # With VUE debugger enabled

# Run the npm server (optional)
docker exec -t -d ldmaster_lsmb npm run serve

# Run the tests (see options below)
make devtest       # Single process
```

Note that this Quick Start script is meant to be run from a new user directory and if run a second time in the same directory will error out.

After the command `../ldd/lsmb-dev master up -d` is executed above you should see output similar to:

```
-======================================
-== LedgerSMB 'master'
-== should be available at
-======================================
-host         : http://host:49154
-mailhog      : http://172.28.0.3:8025
-psgi         : http://172.28.0.4:5762
-proxy (login): http://172.28.0.5/login.pl
-proxy (setup): http://172.28.0.5/setup.pl
-dev (login)  : http://172.28.0.4:9000/login.pl
-dev (setup)  : http://172.28.0.4:9000/setup.pl
-======================================
-== Postgres Database can be accessed at
-======================================
-db:  host:49158
-db:  172.28.0.2:5432
-======================================
```
Note that without further customization, as described below, the ports are chosen randomly with each container start up. So your ports will likely be different.

Ten containers are created:

* `ldmaster_db`
* `ldmaster_lsmb`
* `ldmaster_mailhog`
* `ldmaster_proxy`
* `ldmaster_selenium`
* `ldmaster_chrome_1`
* `ldmaster_chrome_2`
* `ldmaster_chrome_3`
* `ldmaster_chrome_4`
* `ldmaster_chrome_5`

The `LedgerSMB` directory is mapped to the `/srv/ledgersmb` directory
inside the `ldmaster_lsmb` and `ldmaster_proxy` containers. The
database container creates its database storage on a "RAM drive",
meaning that restarting the container causes all existing databases
to be flushed.

A Selenium grid is created with a hub and 5 copies of the browser you selected,
Chrome is set per default. Firefox and Opera are supported.

### Creating JavaScript output

A "transpiled" version of the JavaScript code must
be available in the `UI/js/` directory. This is created from `UI/js-src/`
by running either of the two commands shown below.

```bash
make jsdev # With VUE debugger enabled
```
or

```bash
make js  # Without VUE debugger enabled
```

After editing the code in `UI/js-src/`, one of these commands needs to be re-run.

### Accessing LedgerSMB

As per the example above, you should be able to browse to your host at
<http://host:32452/setup.pl> if you want to go through the proxy or at
<http://172.20.0.6/setup.pl> to go directly and create a test database.
The default password of the `postgres` user is `abc`.

Similarly, after you create a test company using `setup.pl`, browsing to
<http://172.20.0.6/login.pl> allows to log into the company.

The Postgres database is made available at <http://host:45632> on the example
above, should you want to browse it.

All host ports are assigned randomly on available ports to not clash with the
host but this can be overridden

LedgerSMB offers the possibility to run in development mode, where you can
see the modifications done in the user interface code be installed and shown
in realtime.

This is started with the command:

```sh
# Runs the realtime user interface compiler
docker exec -t -d ldmaster_lsmb npm run serve
```

And you can then use a browser to browse your host in development mode
at <http://host:31845>, <http://host:31845/login.pl> or <http://host:31845/setup.pl>.

### Environment variables

Defaults can be overridden by setting environment variables. By default,
`.local/.env` in the LedgerSMB repository clone is read if available at container startup. 
Local overrides and can contain the following:

```sh
# Set local defaults for environment variables

# Database user and password
# export PGUSER=postgres
# export PGPASSWORD=abc

# Browser to use by default, can be overriden on command line
export BROWSER=${BROWSER:-chrome}

# Browser instances to create, can be overriden on command line
export BROWSERS_COUNT=${BROWSERS_COUNT:-5}

# Home directory for the container user
export HOME_DEV=../LedgerSMB/.local/home

# Uncomment to fix host ports used
# export LSMB_PORT=5000
# export LSMB_PORT_DEV=9000
# export DB_PORT=5432
# export MAILHOG_PORT=8025

# Uncomment to use a customized ledgersmb-dev-test image.
# export LSMB_IMAGE=user/ledgersmb-dev-test:latest
```

### Running tests

Three commands exist to run tests:

```sh
make test # Runs the tests in the `t/` directory
```

```sh
make devtest # Runs the tests in the `t/` and `xt/` directories
```

```sh
make pherkin # Runs the tests `xt/**/*.feature`
```

The set of tests to be run can be restricted setting the `TESTS` Makefile
variable. For example:

```bash
make test TESTS=t/01-load.t
make devtest TESTS=xt/66-cucumber/01-basic/change_password.feature
```

### lsmb-dev

The `LedgerSMB/Makefile` applies some magic to make sure certain `make` commands are actually run inside the `ldmaster_lsmb` docker container using the `ldd/lsmb-dev` bash shell script.

Some developers prefer to add `ldd/lsmb-dev` to their path. One way to do that is to add a symbolic link in the `~/bin` directory.  For example:

```sh
cd ~
mkdir bin	# If it does not exist.
ln -s -f -v /home/${USER}/ldd/lsmb-dev /home/${USER}/bin/lsmb-dev
```
Then exit and log back in so Ubuntu adds the `~/bin` directory into the `$PATH` variable.

This allows the user to use `lsmb-dev` directly without always having to type `../ldd/lsmb-dev`. Note that `lsmb-dev` must be used from within the `LedgerSMB` directory (using the Quick Start script) or from within another valid LedgerSMB repository.

### Restarting LedgerSMB after making (Perl) edits

It's best to restart the single `ldmaster_lsmb` container using Docker
directly by running

```bash
docker restart ldmaster_lsmb
```

Although the command `../ldd/lsmb-dev master restart` works, it usually
comes up with different IP addresses on the containers than the original
`up -d` command.

## Retaining databases between container restarts

The database gets stored in RAM for performance reasons. If however,
you want/need to retain databases between container restarts, you can
change the backing storage to harddisk/ssd by changing the end of `docker-compose.yml` in `ledgersmb-dev-docker` repository clone before the initial startup from


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

### Multiple parallel test environments

Multiple test environments, based on multiple clones, can be created
using a different first-argument to the `lsmb-dev` script. E.g. a
1.8 testing environment can be created using:

```sh
git clone -b 1.8 https://github.com/ledgersmb/LedgerSMB.git
git clone https://github.com/ledgersmb/ledgersmb-dev-docker.git ldd
cd LedgerSMB
../ldd/lsmb-dev 18 pull
BROWSER=firefox ../ldd/lsmb-dev 18 up -d
```

This creates 10 additional containers:

* `ld18_db`
* `ld18_lsmb`
* `ld18_selenium`
* `ld18_mailhog`
* `ld18_proxy`
* `ld18_selenium`
* `ld18_firefox_1`
* `ld18_firefox_2`
* `ld18_firefox_3`
* `ld18_firefox_4`
* `ld18_firefox_5`

## DB (PostgreSQL)

Please note that the database container patches the PostgreSQL configuration
for faster test performance rather than the reliability levels you'd want
for your production environment (that is, data consistency isn't fully
guaranteed on outage, which shouldn't be a problem for tests -- we'll simply
re-run them -- but isn't a risk to be taken in production).

## MailHog

The default configuration, all mail sent from LedgerSMB is 'caught' by
[MailHog](https://github.com/mailhog/MailHog). This allows e-mail
functionality to be tested without sending real messages over the
internet.

MailHog traps all messages, providing a web UI and API to view or retrieve
them.

The `mailhog/mailhog` container serves the web API on port 8025 and accepts
SMTP connections on port 1025.

## Development and testing against different perl versions

A script is provided to help create docker images using different Perl
versions. These are based on the
[official Perl docker images](https://hub.docker.com/_/perl/) and are not
optimised for size, but can be useful for testing version-specific
behaviour.

Running:

```sh
   ./tools/make_perl_context [perl version]
```

Will create a new docker context for the specified perl version, from
which an image can be built and used in place of the official
`ledgersmbdev/ledgersmb-dev-lsmb` image.
