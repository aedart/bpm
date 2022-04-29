# Maintainer Notes

This document serves as _preliminary_ internal documentation and notes for "bashy" maintainers.
It is far from complete and a more finalised version will be manifested, when time permits it.

## Prerequisites

You will require the following to be installed:

```console
sudo apt install dh-make build-essential devscripts
sudo apt install shellcheck
```

**Note**: _Not sure about `devscripts`..._

### Node + npm

Since this application relies on [bats](https://github.com/bats-core/bats-core), you will need to have the latest stable version of node and npm installed.
Afterwards, you need to run:

```console
npm install
```

## How to build

To build the debian package, run the following.

```bash
./bin/build
```

The built `*.deb` file is located inside the `.build/distributions/debian` directory.

## How to install

To install the current version locally, run the following:

**Warning**: _This MIGHT replace or destroy your current installed version!_

```bash
sudo dpkg -i .build/distributions/debian/bpm_*.deb
```

## How to uninstall

```bash
sudo dpkg -r bpm
```

## How to run tests

```console
npm run test
```

## Code Style Guide

Inspiration should be drawn from [Google's shell guide](https://google.github.io/styleguide/shellguide.html) for bash scripts. 