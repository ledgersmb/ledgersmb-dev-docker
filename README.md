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
LedgerSMB. This script should work with any linux distribution that has `docker`, `git`, `make` and all of their prerequisites installed and where the current `$USER` is in the docker group. 

These prerequisites can generally be met using the following on Ubuntu:

```sh
sudo apt-get -y install make git curl gnupg ca-certificates lsb-release

# If the following fails, see the instructions at
# https://docs.docker.com/engine/install
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose

# Add the current user to the 'docker' group
sudo usermod -a -G docker $USER
```

## Quick Start (from scratch)

The Quick Start bash script installs LedgerSMB using an insecure development configuration and runs the LedgerSMB test suites.  

It is meant as an example to get a new developer started. The computer used for this install should not be connected directly to a WAN without additional security precautions.

All further instructions assume that this script is run from the `$USER`'s `$HOME` directory and that the user is NOT the root user.

The Quick Start script only works after commit fdbc05543751ec5fa560587dcafd9cdb0d6ef397 (15 August 2022) in the LedgerSMB master branch. Prior to that the directories `logs` and `screens` were not present in the LedgerSMB repository and needed to added manually.

Details about each step appear below the script.

This Quick Start shell script has been tested on Ubuntu 22.04, Debian 11.4, and Fedora 36.  Although we had several problems getting Fedora and Docker to cooperate.

```sh
#!/bin/bash
set -e -x

# Not for use in Production.

# Clone the LedgerSMB development docker master repository
git clone https://github.com/ledgersmb/ledgersmb-dev-docker.git ldd

# Clone the LedgerSMB git master repository
git clone https://github.com/ledgersmb/LedgerSMB.git

cd LedgerSMB

# Set up LedgerSMB configuration for development
cp doc/conf/ledgersmb.conf.default ledgersmb.conf
sed -i -e 's/db_namespace = public/db_namespace = xyz/' ledgersmb.conf
sed -i -e 's/host = localhost/host = postgres/' ledgersmb.conf

# Start the docker containers
../ldd/lsmb-dev master pull
../ldd/lsmb-dev master up -d

# Make the runtime javascript (see options below)
make jsdev # With VUE debugger enabled

# Run the tests (see options below)
make devtest       # Single process
```

Note that this Quick Start script is meant to be run from a new user directory and if run a second time in the same directory will error out.

After the command `../ldd/lsmb-dev master up -d` is executed above you should see output similar to:

```
======================================
== LedgerSMB 'master'
== should be available at
======================================
host         : http://host:49156
mailhog      : http://host:49153
dev (login)* : http://host:49155/login.pl
dev (setup)* : http://host:49155/setup.pl
db           : postgresql://host:49154

mailhog      : http://172.22.0.2:8025
psgi         : http://172.22.0.4:5762
proxy (login): http://172.22.0.5/login.pl
proxy (setup): http://172.22.0.5/setup.pl
dev (login)* : http://172.22.0.4:9000/login.pl
dev (setup)* : http://172.22.0.4:9000/setup.pl
db           : postgresql://172.22.0.3:5432
======================================
* Only available if 'make serve' is running
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

### Problems we've seen

1. The `$USER` is not in the `docker` group. This is fixed by executing `sudo usermod -aG docker $USER` or some variation that works in your distribution.

2. If you get the warning:

	<!-- language: sh -->
    * The collector has reached the maximum number of concurrent jobs to process.
    * Testing will continue, but some tests may be running or even complete before they are rendered.
    * All tests and events will eventually be displayed, and your final results will not be effected.

	To eliminate this warning adjust `LedgerSMB/.yath.rc` by adding `--max-open-jobs 8` or `--no-max-open-jobs` to the `[Test]` section and restart the containers. Be aware that yath can exhaust file handles if max open jobs is set too high. The default is 2 times the number of parallel jobs `-j` set for the tests.

3. When having problems always make sure the firewall rules are correct. On Fedora 36 the firewall, by default, prevents docker-compose from publishing port 4444 and results in the error 'Selenium server did not return proper status...'.

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
<http://host:49156/setup.pl> if you want to go through the proxy or at
<http://172.20.0.6/setup.pl> to go directly and create a test database.
The default password of the `postgres` user is `abc`.

Note that the `host` connection uses a proxy which will redirect "/" to "/login.pl".

Similarly, after you create a test company using `setup.pl`, browsing to
<http://172.20.0.6/login.pl> allows to log into the company.

The Postgres database is made available and can be connected to using pgsql connection URL <postgresql://postgres@host:49154>.

Without a `.local/.env` file as described in the next section, all host ports are assigned randomly so they will not clash when running multiple parallel test environments. The `.local/.env` is not present by default and must be added by the developer.

LedgerSMB offers the possibility to run in development mode, where you can
see the modifications done in the user interface code be installed and shown
in realtime. This is started with the command:

```sh
# Runs the realtime user interface compiler
make serve
```

You can then use a browser to browse your host in development mode using the `dev` connections shown above.

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
# Does not create a database
make test # Runs the tests in the `t/` directory
```

```sh
# Creates a database for the `xt/` tests.
make devtest # Runs the tests in the `t/` and `xt/` directories
```

```sh
make pherkin # Runs the tests `xt/**/*.feature`
```

Note that the `xt/` directory contains both regular tests and `feature` tests. Using `make devtest` runs all tests using `yath` in `t/` and `xt/`.  

Using make `pherkin` only runs the `.feature` tests using `pherkin`. The `pherkin` tests provide more detail, but do not parallelize as well and therefor are slower.

The set of tests to be run can be restricted by setting the `TESTS` Makefile
variable. For example:

```bash
make test TESTS=t/01-load.t
make devtest TESTS=xt/66-cucumber/01-basic/change_password.feature
```

Tests can be run in parallel using:

```bash
make devtest TESTS='-j4 t/ xt/'
make test TESTS='-j4 t/'
``` 

This example runs the tests using 4 parallel jobs.  There are significant speedups when running tests in parallel.

### lsmb-dev

The `LedgerSMB/Makefile` applies some magic to make sure certain `make` commands are actually run inside the `ldmaster_lsmb` docker container using the `ldd/lsmb-dev` bash shell script.

Some developers prefer to add `ldd/lsmb-dev` to their path. One way to do that is to add a symbolic link in the `~/bin` directory.  For example:

```sh
cd ~
mkdir bin	# If it does not exist.
ln -s -f -v $HOME/ldd/lsmb-dev $HOME/bin/lsmb-dev
```

This symbolic link works automatically for Unbuntu 22.04, Debian 11.4, and Fedora 36 after you logoff and login (or restart). For other distributions you might need to add something like following to the `$USER`'s `.profile` or `.bashrc` as appropriate for the distribution.

```sh
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
```

Then log out and log back in so that the `~/bin` directory is added to the `$PATH` variable. 

These changes allows the user to use `lsmb-dev` directly without always having to type `../ldd/lsmb-dev`. Note that `lsmb-dev` must be used from within the `LedgerSMB` directory (using the Quick Start script) or from within another valid LedgerSMB repository.

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
