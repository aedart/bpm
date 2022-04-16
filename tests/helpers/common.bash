#!/bin/bash

# Copyright (C) 2022  Alin Eugen Deac <aedart@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

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