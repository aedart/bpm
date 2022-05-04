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
# It offers no support for "Perl-compatible regular expressions (PCRE)".
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
# echo "major ${my_version_array['major']}"
# echo "minor ${my_version_array['minor']}"
# echo "patch ${my_version_array['patch']}"
# echo "pre-release ${my_version_array['pre_release']}"
# echo "build meta-data ${my_version_array['build_meta']}"
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