#!/bin/bash

##
# Common setup for bats support and assert modules
#
# Globals:
#   - BATS_ROOT (defined by bats)
#
common_setup() {

    # echo "BATS ROOT >>> $BATS_ROOT"

    # TODO: At some point... change these load methods...
    load "${BATS_ROOT}/../bats-support/load"
    load "${BATS_ROOT}/../bats-assert/load"

    # Define project root
    PROJECT_ROOT="$( cd "$( dirname "${BATS_ROOT}/../../../")" && pwd )"

    # make executables in src/ visible to PATH
    PATH="$PROJECT_ROOT/src:$PATH"

    # Export paths to "data" and "output" directories, for all tests.
    export TEST_DATA_DIR="$PROJECT_ROOT/tests/_data"
    export TEST_OUTPUT_DIR="$PROJECT_ROOT/tests/_output"
}