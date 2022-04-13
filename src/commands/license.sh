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
license::name() {
    echo "$(basename "${BASH_SOURCE[0]}" ".sh")"
}

# Short description of this command
#
# WARNING: Must be a single line without any variables
# mangled into the string!
# Variable name MUST also be prefixed with command's name
#
#
license_short_description="Displays bpm's license file contents."

##
# Displays application's license file contents
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
#   - writes to stderr when license file cannot be located
#
license::main() {
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
        license::usage
        exit $EXIT_SUCCESS
    fi

    # Declare verbose and quiet modes for read-only!
    readonly VERBOSE
    readonly QUIET
    readonly ANSI

    # -------------------------------------------------------------------------------------------- #

    # Locate license file or fail
    local license_file="${BPM_LIBRARY_DIR}/LICENSE"
    if [[ ! -f "${license_file}" ]]; then
        output_helpers::critical "Unable to find license file (${license_file})"
        exit $EXIT_FAILURE
    fi

    # Show license file contents
    local contents=
    contents=$(cat "${license_file}")

    output_helpers::write "${contents}"
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
license::usage() {
    local short_desc=
    short_desc="${license_short_description}"

    local name=
    name="$(license::name)"

    output_helpers::write "
 ${colour_gray}${short_desc}${restore}

 ${colour_yellow}Usage:${restore}
    ${APP_NAME} ${name} [options]

 ${colour_yellow}Options:${restore}
    -h, --help              ${colour_white}Displays help text.${restore}
    -v, --verbose           ${colour_white}Outputs eventual debugging messages.${restore}
    -q, --quiet             ${colour_white}Disables all output (except for the --help option).${restore}
        --no-ansi           ${colour_white}Disables ANSI output.${restore}
"
}