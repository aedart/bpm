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
list::name() {
    echo "$(basename "${BASH_SOURCE[0]}" ".sh")"
}

# Short description of this command
#
# WARNING: Must be a single line without any variables
# mangled into the string!
#
list_short_description='List available commands.'

##
# Lists available commands for application
#
# Globals:
#   - VERBOSE
#   - QUIET
#   - ANSI
#   - APP_NAME
#   - COMMANDS_DIR
#   - exit codes
# Arguments:
#   - options
# Outputs:
#   - writes to stdout on normal execution
#   - writes to stderr on error
#
list::main() {
    local help_requested=0
    local show_description=1

    # Capture command options
    local short_options=vqhw
    local long_options=verbose,quiet,help,no-ansi,without-description
    local captured_options=
    captured_options="$(getopt -a -n "$APP_NAME" --options $short_options --longoptions $long_options -- "$@")"

    eval set -- "$captured_options"
    while : ; do
        case "$1" in
            -w | --without-description)
                show_description=0
                shift 1;
                ;;

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
        list::usage
        exit $EXIT_SUCCESS
    fi

    # Declare verbose and quiet modes for read-only!
    readonly VERBOSE
    readonly QUIET
    readonly ANSI

    # -------------------------------------------------------------------------------------------- #

    # Output all available commands
    files=$(ls $COMMANDS_DIR/*.sh)
    for command_file in $files; do
        list::output_command "${command_file}" "${show_description}"
    done

    exit $EXIT_SUCCESS
}

##
# Outputs command name and evt. short description
#
# Method skips all commands that are prefixed with "_" symbol!
#
# Globals:
#   - exit codes
# Arguments:
#   - command file path
#   - show description, 1 will output short description, 0 will omit it
# Outputs:
#   - writes to stdout
# Returns:
#   - 0 in case that command was skipped
#
list::output_command() {
    local file="$1"
    local show_description="$2"

    # Command's name (file without file extension)
    local name=
    name="$(basename "${file}" ".sh")"

    # Command's short description
    local description=''

    # Skip if name starts with "_"
    if [[ $name = _* ]]; then
        output_helpers::debug "Skipping \`${name}\` command"
        return $EXIT_SUCCESS
    fi

    # Resolve command's short description
    if [[ $show_description -eq 1 ]]; then

        # To avoid sourcing in the command and potentially trigger
        # something unwanted, we extract a predefined "short description"
        # variable value from the source file.

        # Name of predefined short description variable
        local description_identifier="${name}_short_description="

        # Length of identifier
        local desc_identifier_length="${#description_identifier}"

        # Capture first matching short description line
        local captured_desc=
        captured_desc=$(grep -m 1 "${description_identifier}" "${file}" || test $? = 1)

        # If captured, then assign description without variable name prefix and quotes
        if [[ -n $captured_desc ]]; then
            description="${captured_desc:$desc_identifier_length +1 :-1}"
        else
            # Otherwise, well... command does not follow this convention so given warning about it...
            output_helpers::warning "Command \`${name}\` is missing a \"${description_identifier}\" variable"
        fi
    fi

    # Create formatted output
    local formatted=
    formatted=$(printf "%-28s%-12s" "${name}" "${colour_white}${description}${restore}")

    # Finally, output command and evt. short description
    output_helpers::write "${formatted}"
}

##
# Displays this command's help text
#
# Globals:
#   - APP_NAME
# Outputs:
#   - writes to stdout
#
list::usage() {
    local short_desc=
    short_desc="${list_short_description}"

    local name=
    name="$(list::name)"

    output_helpers::write "
 ${colour_gray}${short_desc}${restore}

 ${colour_yellow}Usage:${restore}
    ${APP_NAME} ${name} [options]

 ${colour_yellow}Options:${restore}
    -w, --without-description   ${colour_white}Output list of commands without their short descriptions.${restore}
    -h, --help                  ${colour_white}Displays help text.${restore}
    -v, --verbose               ${colour_white}Outputs eventual debugging messages.${restore}
    -q, --quiet                 ${colour_white}Disables all output (except for the --help option).${restore}
        --no-ansi               ${colour_white}Disables ANSI output.${restore}
"
}