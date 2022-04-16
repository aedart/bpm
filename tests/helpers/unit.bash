#!/bin/bash

##
# "unit tests" setup
#
# Globals:
#   - BATS_ROOT (defined by bats)
#
unit_setup() {
    # Define path to helpers directory
    readonly HELPERS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

    # Load common settings and run setup
    load "${HELPERS_DIR}/common"
    common_setup

    # Setup for "unit tests"
    # N/A
}