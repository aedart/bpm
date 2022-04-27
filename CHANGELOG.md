# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

* Main application "options" to list of suggestions for auto-completion.
* [Bats](https://github.com/bats-core/bats-core) testing framework and initialised a testing setup.
* `str/trim.sh` string trim utility.
* `str/pos.sh` string character position utility.

### Removed

* `distribution/debian/fiels` file. This is generated on each build and will therefore no longer be tracked.

## [0.2.0] - 2022-04-15

### Added

* Bash auto-completion for `bpm` binary. 

### Changed

* `version` command is now able to show current "dev" version, while application is located within a git repository
* Improved `bin/build-version` helper. It's now able to obtain "dev" version, when current commit does match that of the git tag's commit. 
* Support for `NO_COLOR` environment variable. If set, then output will remove ANSI colour codes.

### Fixed

* ANSI not entirely removed in `output_helpers::resolve_ansi` method

## [0.1.0] - 2022-04-13

### Added

* Initialisation of project, top-level directory structure, changelog, license...etc
* Core cli application architecture for invoking commands with eventual options
* ANSI output utilities  
* `bin/build` helper to build debian package
* `bin/build-version` helper to build a `version` text file
* `docs/maintainer` preliminary maintainer documentation

[unreleased]: https://github.com/aedart/bashy/compare/0.2.0...HEAD
[0.2.0]: https://github.com/aedart/bashy/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/aedart/bashy/releases/tag/0.1.0