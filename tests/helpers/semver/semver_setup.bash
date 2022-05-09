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
# Semantic Version utils tests setup
#
# Globals:
#   - BATS_ROOT (defined by bats)
#
semver_setup() {
    load "../../helpers/unit"
    unit_setup

    # Source in semver utils
    source "${PROJECT_ROOT}/src/semver/semver.sh"

    # Debug
#    echo "Semver setup" >&3
}

# ------------------------------------------------------------------------
# Test Helpers
# ------------------------------------------------------------------------

##
# Run compare method with given data
#
# Arguments:
#   - Name of compare method to run, e.g. "semver::gte"
#   - Data provider (version_a  version_b   expected_return)
# Returns:
#   - 0 (pass)
#   - 1 (failure)
#
run_compare_method() {
    local method="$1"
    local data_provider="$2"

    # Process data_provider
    while read -r line; do
        local ignore="^\#"
        if [[ -z $line || $line =~ $ignore ]]; then
            continue
        fi

        # Extract data
        read -r -a data <<< "$line"

        local a="${data[0]}"
        local b="${data[1]}"
        local expected="${data[2]}"

        # Debug:
        # echo "${a} vs. ${b} | expected: ${expected}" >&3

        # Run and assert compare method
        run "$method" "${a}" "${b}"

        if [[ "$status" != "${expected}" ]]; then
            fail "Expected '${expected}'. Got '${status}' for '${a}' vs. '${b}', using ${method}"
        fi

    done <<<"$data_provider"
}