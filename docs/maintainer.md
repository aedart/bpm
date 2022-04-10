# Maintainer Notes

This document serves as _preliminary_ internal documentation and notes for "bashy" maintainers.

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
sudo dpkg -i .build/distributions/debian/bashy_*.deb
```

## How to uninstall

```bash
sudo dpkg -r bashy
```