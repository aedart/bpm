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

# Slightly modified version of the official regex from https://semver.org.
# Bash only supports "Extended Regular Expressions (ERE)". It does not support
# "Perl-compatible regular expressions (PCRE)". Thus, regex is an adaptation.
#
# In addition, this regex allows optional "v" or "V" as a prefix, e.g. v1.2.3 or V1.2.3.
# This is NOT in accordance to the standard, but it is required to match git tags that
# are labelled such.
#
# Original regex: ^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$
# Source: https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string

readonly SEMVER_PREFIX="([v|V]{0,1})"
readonly SEMVER_DIGITS="(0|[1-9][0-9]*)"
readonly SEMVER_MAJOR=$SEMVER_DIGITS
readonly SEMVER_MINOR=$SEMVER_DIGITS
readonly SEMVER_PATCH=$SEMVER_DIGITS
readonly SEMVER_PRE_RELEASE="?(\\-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)*"
readonly SEMVER_BUILD_METADATA="?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"
readonly SEMANTIC_VERSION_REGEX="^${SEMVER_PREFIX}${SEMVER_MAJOR}\\.${SEMVER_MINOR}\\.${SEMVER_PATCH}${SEMVER_PRE_RELEASE}${SEMVER_BUILD_METADATA}"

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
# echo "evt. prefix: ${my_version_array['prefix']}"
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

        # Eventual "v" prefix
        version_array['prefix']="${BASH_REMATCH[1]}"

        # Store major, minor and patch
        version_array['major']="${BASH_REMATCH[2]}"
        version_array['minor']="${BASH_REMATCH[3]}"
        version_array['patch']="${BASH_REMATCH[4]}"

        # Store eventual pre-release. Note, due to regex
        # we must remove leading "-" sign.
        version_array['pre_release']="${BASH_REMATCH[5]#\-}"

        # Match group 5 is a nested group part of the pre-
        # release. This must be ignored.
        #echo "(nested in pre_release): ${BASH_REMATCH[6]}"

        # Finally, store eventual build meta-data. Here too
        # a leading symbol ("+" sign) must be removed.
        version_array['build_meta']="${BASH_REMATCH[7]#\+}"

        return 0
    fi

    semver::_output_error "${version} is not a valid version"
    return 1
}


##
# Determine if version a is less than version b (a < b)
#
# Globals:
#   - SEMANTIC_VERSION_REGEX
# Arguments:
#   - Version string a, e.g. "1.2.3-alpha.beta+exp.sha.5114f85"
#   - Version string b, e.g. "1.2.3-alpha.1+exp.sha.6873f02"
# Outputs:
#   - Writes to stderr when version string(s) are invalid
# Returns:
#   - 0 (true) if a is less than b
#   - 1 (false) if a is not less than b
#
semver::less_than() {
    local result=
    result=$('semver::compare' "$1" "$2")

    if [[ "$result" == '-1'  ]]; then
        return 0
    fi

    return 1
}

##
# Alias for semver::less_than
#
semver::lt() {
    # shellcheck disable=SC2046
    return $('semver::less_than' "$1" "$2")
}

##
# Determine if version a is less than or equals to version b (a < b | a = b)
#
# Globals:
#   - SEMANTIC_VERSION_REGEX
# Arguments:
#   - Version string a, e.g. "1.2.3-alpha.beta+exp.sha.5114f85"
#   - Version string b, e.g. "1.2.3-alpha.1+exp.sha.6873f02"
# Outputs:
#   - Writes to stderr when version string(s) are invalid
# Returns:
#   - 0 (true) if a is less than or equal to b
#   - 1 (false) if a is not less than or equal to b
#
semver::less_than_or_equals_to() {
    local result=
    result=$('semver::compare' "$1" "$2")

    if [[ "$result" == '-1' || "$result" == '0'  ]]; then
        return 0
    fi

    return 1
}

##
# Alias for semver::less_than_or_equals_to
#
semver::lte() {
    # shellcheck disable=SC2046
    return $('semver::less_than_or_equals_to' "$1" "$2")
}

##
# Determine if version a is greater than version b (a > b)
#
# Globals:
#   - SEMANTIC_VERSION_REGEX
# Arguments:
#   - Version string a, e.g. "1.2.3-alpha.beta+exp.sha.5114f85"
#   - Version string b, e.g. "1.2.3-alpha.1+exp.sha.6873f02"
# Outputs:
#   - Writes to stderr when version string(s) are invalid
# Returns:
#   - 0 (true) if a is greater than b
#   - 1 (false) if a is not greater than b
#
semver::greater_than() {
    local result=
    result=$('semver::compare' "$1" "$2")

    if [[ "$result" == '1'  ]]; then
        return 0
    fi

    return 1
}

##
# Alias for semver::greater_than
#
semver::gt() {
    # shellcheck disable=SC2046
    return $('semver::greater_than' "$1" "$2")
}

##
# Determine if version a is greater than or equal to version b (a > b | a = b)
#
# Globals:
#   - SEMANTIC_VERSION_REGEX
# Arguments:
#   - Version string a, e.g. "1.2.3-alpha.beta+exp.sha.5114f85"
#   - Version string b, e.g. "1.2.3-alpha.1+exp.sha.6873f02"
# Outputs:
#   - Writes to stderr when version string(s) are invalid
# Returns:
#   - 0 (true) if a is greater than or equal to b
#   - 1 (false) if a is not greater than or equal to b
#
semver::greater_than_or_equals_to() {
    local result=
    result=$('semver::compare' "$1" "$2")

    if [[ "$result" == '1' || "$result" == '0'  ]]; then
        return 0
    fi

    return 1
}

##
# Alias for semver::greater_than_or_equals_to
#
semver::gte() {
    # shellcheck disable=SC2046
    return $('semver::greater_than_or_equals_to' "$1" "$2")
}

##
# Determine if version a is equal to version b (a = b)
#
# Globals:
#   - SEMANTIC_VERSION_REGEX
# Arguments:
#   - Version string a, e.g. "1.2.3-alpha.beta+exp.sha.5114f85"
#   - Version string b, e.g. "1.2.3-alpha.1+exp.sha.6873f02"
# Outputs:
#   - Writes to stderr when version string(s) are invalid
# Returns:
#   - 0 (true) if a is equal to b
#   - 1 (false) if a is not equal to b
#
semver::equal_to() {
    local result=
    result=$('semver::compare' "$1" "$2")

    if [[ "$result" == '0'  ]]; then
        return 0
    fi

    return 1
}

##
# Alias for semver::equal_to
#
semver::eq() {
    # shellcheck disable=SC2046
    return $('semver::equal_to' "$1" "$2")
}

##
# Determine if version a is not equal to version b (a != b)
#
# Globals:
#   - SEMANTIC_VERSION_REGEX
# Arguments:
#   - Version string a, e.g. "1.2.3-alpha.beta+exp.sha.5114f85"
#   - Version string b, e.g. "1.2.3-alpha.1+exp.sha.6873f02"
# Outputs:
#   - Writes to stderr when version string(s) are invalid
# Returns:
#   - 0 (true) if a is not equal to b
#   - 1 (false) if a is equal to b
#
semver::not_equal_to() {
    local result=
    result=$('semver::compare' "$1" "$2")

    if [[ "$result" != '0'  ]]; then
        return 0
    fi

    return 1
}

##
# Alias for semver::not_equal_to
#
semver::ne() {
    # shellcheck disable=SC2046
    return $('semver::not_equal_to' "$1" "$2")
}

##
# Compare two versions against each other
#
# Resulting difference is written to stdout, using numeric
# values.
#
# Globals:
#   - SEMANTIC_VERSION_REGEX
# Arguments:
#   - Version string a, e.g. "1.2.3-alpha.beta+exp.sha.5114f85"
#   - Version string b, e.g. "1.2.3-alpha.1+exp.sha.6873f02"
# Outputs:
#   - "-1":  a is less than b     (a < b)  stdout
#   -  "0":  a equals b           (a = b)  stdout
#   -  "1":  a is greater than b  (a > b)  stdout
#   - Writes to stderr when version string(s) are invalid
# Returns:
#   - 0 when able to successfully compare versions
#   - 1 when invalid versions provided
#
semver::compare() {
    # Compare output values (for the sake of readability)
    local -r A_LESS_THAN_B='-1'
    local -r A_EQUALS_B='0'
    local -r A_GREATER_THAN_B='1'

    # Arrays to hold the parsed versions
    local -A version_a=()
    local -A version_b=()

    # Parse and populate local version arrays
    semver::parse "$1" "version_a" || return 1
    semver::parse "$2" "version_b" || return 1

    # ------------------------------------------------------------------------

    # Early out - if both versions are the same (full version strings comparison)
    # Here, eventual build meta-data is also part of the comparison, which is NOT
    # in accordance to Semantic Versioning 2.0.0 standard. Yet, its okay here...
    if [[ "${version_a['version']}" == "${version_b['version']}" ]]; then
        echo $A_EQUALS_B
        return 0
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
            return 0
        fi

        # When a is greater than b
        if [[ $vA > $vB ]]; then
            echo $A_GREATER_THAN_B
            return 0
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
        return 0
    fi

    # "[...] When major, minor, and patch are equal, a pre-release version has
    # lower precedence than a normal version:
    #
    # Example: 1.0.0-alpha < 1.0.0. [...]" (#spec-item-11.3)

    # When a has pre-release, but b does not... E.g. (a) 1.0.0-alpha < (b) 1.0.0
    if [[ -n "${pre_release_a}" && -z "${pre_release_b}"  ]]; then
        echo $A_LESS_THAN_B
        return 0
    fi

    # When a has no pre-release, but b does... E.g. (a) 1.0.0 > (b) 1.0.0-alpha
    if [[ -z "${pre_release_a}" && -n "${pre_release_b}"  ]]; then
        echo $A_GREATER_THAN_B
        return 0
    fi

    # ------------------------------------------------------------------------

    # "[..] Precedence for two pre-release versions [...] MUST be determined
    # by comparing each dot separated identifier from left to right until a
    # difference is found [...]" (#spec-item-11.4)

    # Split pre-release identifiers into arrays, using dot as separator
    read -r -a a_elements <<< "${pre_release_a//\./ }"
    read -r -a b_elements <<< "${pre_release_b//\./ }"

    # Ensure both pre-release arrays have equal amount of identifiers.
    # Push zero (0) into either array that is smaller than the other.
    # Note: "[...] Numeric identifiers always have lower precedence than
    # non-numeric identifiers[...]" (#spec-item-11.4.3)
    while [[ ${#a_elements[@]} < ${#b_elements[@]}  ]]; do
        a_elements+=('0')
    done
    while [[ ${#b_elements[@]} < ${#a_elements[@]}  ]]; do
        b_elements+=('0')
    done

    # Loop through pre-release identifiers, compare left to right.
    local -r IS_NUMERIC="^[0-9]*$"
    local -r IS_STRING="^[a-zA-Z-]*$"
    for (( i = 0; i < "${#a_elements[@]}"; i++ )); do
        local pA="${a_elements[$i]}"
        local pB="${b_elements[$i]}"

        # Debug
        # echo "$pA vs. $pB"

        # "[...] Numeric identifiers always have lower precedence than
        # non-numeric identifiers [...]" (#spec-item-11.4.3)

        # When a is numeric, but b is a string
        if [[ $pA =~ $IS_NUMERIC && $pB =~ $IS_STRING  ]]; then
            echo $A_LESS_THAN_B
            return 0
        fi

        # When a is string, but b is a numeric
        if [[ $pA =~ $IS_STRING && $pB =~ $IS_NUMERIC  ]]; then
            echo $A_GREATER_THAN_B
            return 0
        fi

        # When both identifiers are strings, compare them using ASCII order
        # (#spec-item-11.4.1, #spec-item-11.4.2)
        if [[ $pA =~ $IS_STRING && $pB =~ $IS_STRING ]]; then
            if [[ $pA < $pB ]]; then
                echo $A_LESS_THAN_B
                return 0
            fi

            if [[ $pA > $pB ]]; then
                echo $A_GREATER_THAN_B
                return 0
            fi
        else
            # Otherwise, identifiers are numeric...
            if [[ $pA -lt $pB ]]; then
                echo $A_LESS_THAN_B
                return 0
            fi

            if [[ $pA -gt $pB ]]; then
                echo $A_GREATER_THAN_B
                return 0
            fi
        fi

        # Botch pre-release identifiers are the same, continue to next set...
    done

    # ------------------------------------------------------------------------

    # Finally, both version and pre-release identifiers are the same. Output
    # and return accordingly.
    echo $A_EQUALS_B
    return 0
}

# TODO
semver::satisfies() {
    local version="$1"
    local constraints="$2"

    # TODO: Fail if version is not valid
    # TODO: Fail if no constraints given

    # Split constraints by logical OR
    mapfile -t or_constraints < <(semver::_split "${constraints}" "||")

    # Iterate through each group of constraints and match against version.
    for or_constraint in "${or_constraints[@]}"; do
        echo "constraint: $or_constraint"

        # TODO: Split "or constraint" further by comma or whitespace => and constraints

    done
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

##
# Split a string by a delimiter
#
# Method ensures each element is trimmed!
#
# Example:
# ```bash
# # Populate into an array
# mapfile -t arr < <(semver::_split "^1.0.0 || >=2.0.0 <3.0.0" "||")
#
# echo "${arr[@]}"
# ```
#
# Arguments:
#   - String to be split, e.g. "^1.0.0 || >=2.0.0 <3.0.0"
#   - delimiter, e.g. "||"
# Outputs:
#   - Writes each element on a new line, on stdout
# Returns:
#   - 0 when successful
#   - 1 on failure
#
semver::_split() {
    # TODO: Extract into own module?
    local str="$1"
    local delimiter="$2"

    mapfile -t arr < <(printf "%s" "${str//${delimiter}/$'\n'}")

    # Trim each element
    for i in "${arr[@]}"; do
        semver::_trim "$i"
    done
}

##
# Trim string for leading and trailing whitespace
#
# Arguments:
#   - string to be trimmed
# Outputs:
#   - Writes trimmed string to stdout
#
semver::_trim() {
    # TODO: replace with str::trim ?
    local str="$1"

    shopt -s extglob

    # Remove leading and trailing whitespaces
    str="${str##*( )}"
    str="${str%%*( )}"

    echo "$str"
}