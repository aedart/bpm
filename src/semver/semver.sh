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

# ------------------------------------------------------------------------
# Semantic Version Utility
#
# Responsible for parsing, validating and comparing version strings. It
# also offers some utilities for picking version ranges according to
# specified constraints.
#
# @see https://semver.org/
# ------------------------------------------------------------------------

# ------------------------------------------------------------------------
# Semantic Version Regex
# ------------------------------------------------------------------------

# Unfortunately, bash only supports "Extended Regular Expressions (ERE)".
# Thus, no builtin support for "Perl-compatible regular expressions (PCRE)".
# Therefore, a custom regex is made, based on the following:
#
# Original: ^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$
# Source: https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string

declare -r SEMVER_DIGITS="(0|[1-9][0-9]*)"
declare -r SEMVER_MAJOR=$SEMVER_DIGITS
declare -r SEMVER_MINOR=$SEMVER_DIGITS
declare -r SEMVER_PATCH=$SEMVER_DIGITS
declare -r SEMVER_PRE_RELEASE="?(\\-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)*"
declare -r SEMVER_BUILD_METADATA="?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"
declare -r SEMANTIC_VERSION_REGEX="^${SEMVER_MAJOR}\\.${SEMVER_MINOR}\\.${SEMVER_PATCH}${SEMVER_PRE_RELEASE}${SEMVER_BUILD_METADATA}"

# ------------------------------------------------------------------------
# Public methods
# ------------------------------------------------------------------------

##
# Determine if given version string is a valid acc. to
# semantic version schema
#
# Globals:
#   - SEMANTIC_VERSION_REGEX
# Arguments:
#   - version string, e.g. 2.1.3-alpha.1+exp.sha.5114f85
# Returns:
#   - 0 (true) if version string is valid
#   - 1 (false) if version string is not valid
#
semver::is_valid() {
    local version="$1"

    if [[ $version =~ $SEMANTIC_VERSION_REGEX ]]; then
        return 0
    fi

    return 1
}

##
# Parse version string into given array
#
# Example:
# ```bash
# declare -A my_version_array=()
# semver::parse "1.2.3-alpha.1+exp.sha.5114f85" "my_version_array"
#
# echo "version: ${my_version_array['version']}"
# echo "major: ${my_version_array['major']}"
# echo "minor: ${my_version_array['minor']}"
# echo "patch: ${my_version_array['patch']}"
# echo "pre-release: ${my_version_array['pre_release']}"
# echo "build meta-data: ${my_version_array['build_meta']}"
# ```
#
# Globals:
#   - SEMANTIC_VERSION_REGEX
# Arguments:
#   - version string, e.g. 2.1.3-alpha.1+exp.sha.5114f85
#   - name of the associative array to parse version into
# Outputs:
#   - Writes to stderr if version is invalid
# Returns:
#   - 0 (true) on success
#   - 1 (false) on failure
#
semver::parse() {
    local version="$1"
    local -n version_array="$2"

    if [[ $version =~ $SEMANTIC_VERSION_REGEX ]]; then

        # Store full version string that was matched
        version_array['version']="${BASH_REMATCH[0]}"

        # Store major, minor and patch
        version_array['major']="${BASH_REMATCH[1]}"
        version_array['minor']="${BASH_REMATCH[2]}"
        version_array['patch']="${BASH_REMATCH[3]}"

        # Store eventual pre-release. Note, due to regex
        # we must remove leading "-" sign.
        version_array['pre_release']="${BASH_REMATCH[4]#\-}"

        # Match group 5 is a nested group part of the pre-
        # release. This must be ignored.
        #echo "(nested in pre_release): ${BASH_REMATCH[5]}"

        # Finally, store eventual build meta-data. Here too
        # a leading symbol ("+" sign) must be removed.
        version_array['build_meta']="${BASH_REMATCH[6]#\+}"

        return 0
    fi

    semver::_output_error "${version} is not a valid version"
    return 1
}

# TODO:
# TODO: -1: a less than b (a < b)
# TODO: 0: a equals b (a = b)
# TODO: 1: a greater than b (a > b)
semver::compare() {
    # Arrays to hold the parsed versions
    local -A version_a=()
    local -A version_b=()

    # Output symbols (for the sake of readability)
    local -r A_LESS_THAN_B='-1'
    local -r A_EQUALS_B='0'
    local -r A_GREATER_THAN_B='1'

    # TODO: Fail if num. arguments is not exactly two!

    # Parse and populate local version arrays
    semver::parse "$1" "version_a"
    semver::parse "$2" "version_b"

    # ------------------------------------------------------------------------

    # Early out - if both versions are the same (full version strings comparison)
    # Here, eventual build meta-data is also part of the comparison, which is NOT
    # in accordance to Semantic Versioning 2.0.0 standard. Yet, its okay here...
    if [[ "${version_a['version']}" == "${version_b['version']}" ]]; then
        echo $A_EQUALS_B
        exit 0
    fi

    # ------------------------------------------------------------------------

    # Create two new arrays that contain only the numeric version identifiers
    local a=("${version_a['major']}" "${version_a['minor']}" "${version_a['patch']}")
    local b=("${version_b['major']}" "${version_b['minor']}" "${version_b['patch']}")

    # Loop through the version numbers, comparing from left to right (major, minor and patch)
    # @see https://semver.org/#spec-item-11
    for (( i = 0; i < 3; i++ )); do
        local vA="${a[$i]}"
        local vB="${b[$i]}"

        # Debug
        # echo "$vA vs. $vB"

        # When a is less than b
        if [[ $vA < $vB ]]; then
            echo $A_LESS_THAN_B
            exit 0
        fi

        # When a is greater than b
        if [[ $vA > $vB ]]; then
            echo $A_GREATER_THAN_B
            exit 0
        fi

        # Continue, to next version identifier when both are equal...
    done

    # ------------------------------------------------------------------------

    # If we reached this point, it means that major, minor and patch are equal.
    # Therefore, we must compare eventual pre-release identifiers if available.
    # @see https://semver.org/#spec-item-11
    local pre_release_a="${version_a['pre_release']}"
    local pre_release_b="${version_b['pre_release']}"

    # Early out - if neither a nor b have pre-release identifiers...
    if [[ -z "${pre_release_a}" && -z "${pre_release_b}" ]]; then
        echo $A_EQUALS_B
        exit 0
    fi

    # "[...] When major, minor, and patch are equal, a pre-release version has
    # lower precedence than a normal version:
    #
    # Example: 1.0.0-alpha < 1.0.0. [...]" (#spec-item-11.3)

    # When a has pre-release, but b does not... E.g. (a) 1.0.0-alpha < (b) 1.0.0
    if [[ -n "${pre_release_a}" && -z "${pre_release_b}"  ]]; then
        echo $A_LESS_THAN_B
        exit 0
    fi

    # When a has no pre-release, but b does... E.g. (a) 1.0.0 > (b) 1.0.0-alpha
    if [[ -z "${pre_release_a}" && -n "${pre_release_b}"  ]]; then
        echo $A_GREATER_THAN_B
        exit 0
    fi

    # ------------------------------------------------------------------------

    # "[..] Precedence for two pre-release versions [...] MUST be determined
    # by comparing each dot separated identifier from left to right until a
    # difference is found [...]" (#spec-item-11.4)

    # TODO: Split pre-releases by dot, into two arrays... loop identifiers
    # TODO: and compare acc. to spec-item-11.4...

    # ------------------------------------------------------------------------

    # Finally, both version and pre-release identifiers are the same. Output
    # and exit accordingly.
    echo $A_EQUALS_B
    exit 0
}

# ------------------------------------------------------------------------
# Internals
# ------------------------------------------------------------------------

##
# Writes to stderr
#
# Arguments:
#   - string message
# Outputs:
#   - writes to stderr
#
semver::_output_error() {
    echo -e "$*" >&2;
}