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
# Name of this command
#
# Globals:
#   - BASH_SOURCE
# Outputs:
#   - write name of command to stdout
#
version::name() {
    echo "$(basename "${BASH_SOURCE[0]}" ".sh")"
}

# Short description of this command
#
# WARNING: Must be a single line without any variables
# mangled into the string!
#
version_short_description="Shows bpm's version"

##
# Shows application's version
#
# Globals:
#   - VERBOSE
#   - QUIET
#   - ANSI
#   - APP_NAME
#   - BPM_LIBRARY_DIR
#   - exit codes
# Arguments:
#   - options
# Outputs:
#   - writes to stdout on normal execution
#   - writes to stderr on error
#
version::main() {
    # Capture evt. arguments before handling options
    # ...

    # State if command help is requested via option
    local help_requested=0

    # Capture command options
    local short_options=vqh
    local long_options=verbose,quiet,help,no-ansi
    local captured_options=
    captured_options="$(getopt -a -n "$APP_NAME" --options $short_options --longoptions $long_options -- "$@")"

    eval set -- "$captured_options"
    while : ; do
        case "$1" in
            # Set verbose mode
            -v | --verbose)
                VERBOSE=1
                QUIET=0
                shift 1;
                ;;

            # Set quiet mode
            -q | --quiet)
                QUIET=1
                VERBOSE=0
                shift 1;
                ;;

            # show help
            -h | --help)
                help_requested=1
                shift 1;
                ;;

            # Disable ANSI output
            --no-ansi)
                ANSI=0
                shift 1;
                ;;

            # -- means the end of the arguments; drop this, and break out of the while loop
            --)
                break
                ;;
        esac
    done

    # -------------------------------------------------------------------------------------------- #

    if [[ $help_requested -eq 1 ]]; then
         # Ensure that command is not running in quiet mode
        QUIET=0

        # Display help...
        version::usage
        exit $EXIT_SUCCESS
    fi

    # Declare verbose and quiet modes for read-only!
    readonly VERBOSE
    readonly QUIET
    readonly ANSI

    # -------------------------------------------------------------------------------------------- #

    # Locate version file or fail
    local version_file="${BPM_LIBRARY_DIR}/version"
    if [[ ! -f "${version_file}" ]]; then
        output_helpers::critical "Unable to find version file (${version_file})"
        exit $EXIT_FAILURE
    fi

    # Obtain version from file. This contains the latest tag.
    local version=
    version=$(cat "${version_file}")

    # In case that the application is "in development", then should be located within a git
    # repository. If that is the case, then there is a change that an incorrect version is
    # shown (version file only contains "latest version" from the "./bin/build-version executable).
    # Therefore, if the application is in a git repository, show the "correct" version.
    if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]; then

        # Compare latest commit on HEAD with tag's hash. If they do not match, then we
        # Re-write the version to reflect that application is in a development state.
        tag_hash=$(git log "${version}" -1 --pretty=%H)
        latest_commit_hash=$(git rev-parse --verify HEAD)

        if [[ "${tag_hash}" != "${latest_commit_hash}" ]]; then
            # This means that version is a developer version. For this reason,
            # we change the version to reflect this, e.g. "dev-main@5a038a5"
            branch=$(git branch --show-current)
            version="dev-${branch}@$(git rev-parse --short HEAD)"
        fi

        # Otherwise, we default to whatever was obtained from the version file.
    fi

    # Output version
    output_helpers::write "${version}"
    exit $EXIT_SUCCESS
}

##
# Displays this command's help text
#
# Globals:
#   - APP_NAME
# Outputs:
#   - writes to stdout
#
version::usage() {
    local short_desc=
    short_desc="${version_short_description}"

    local name=
    name="$(version::name)"

    output_helpers::write "
 ${colour_gray}${short_desc}${restore}

 ${colour_yellow}Usage:${restore}
    ${APP_NAME} ${name} [options]

 ${colour_yellow}Options:${restore}
    -h, --help              ${colour_white}Displays help text.${restore}
    -v, --verbose           ${colour_white}Outputs eventual debugging messages.${restore}
    -q, --quiet             ${colour_white}Disables all output (except for the --help option).${restore}
        --no-ansi           ${colour_white}Disable ANSI output.${restore}
"
}