# LedgerSMB Docker development & testing infrastructure

Provides `docker-compose` infrastructure to kick off a local development
and test environment for LedgerSMB.

The infrastructure is based on the `ledgersmb/ledgersmb-dev-postgres` and
`ledgersmb/ledgersmb-dev-lsmb` LedgerSMB containers and the `wernight/phantomjs`
selenium tester container. The postgres container is derived from the standard
postgres container, adding the `pgTAP` test infrastructure. The lsmb container
holds everything required to run and test LedgerSMB. This container currently
supports versions 1.5 and master.

# Prerequisites

Apart from the obvious (docker, docker-compose), this project expects
a LedgerSMB Git repository to exist in the current directory.

# Getting started

By running:

```sh
   $ LSMB_DEV_VERSION=master docker-compose -f <path> up -d
```

an execution environment is wrapped around the local repository. `<path>`
is the path of the `docker-compose.yml` held in this repository. Three
containers are created: `postres-lsmb-master-devel`, `ledgersmb-master-devel`
and `selenium-lsmb-master-devel`.

