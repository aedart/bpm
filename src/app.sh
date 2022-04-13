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
# Error Handling
# ------------------------------------------------------------------------

# Set error handling
set -o errexit  # abort on nonzero exit status
set -o nounset  # abort on unbound variable
set -o pipefail # don't hide errors within pipes

# ------------------------------------------------------------------------
# Static variables
# ------------------------------------------------------------------------

# Application script location
readonly BPM_APP_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Location where command scripts are located
readonly COMMANDS_DIR="${BPM_APP_DIR}/commands"

# Application name
readonly APP_NAME="$(basename "$0")"

# ------------------------------------------------------------------------
# Load resources
# ------------------------------------------------------------------------

source "${BPM_APP_DIR}/output/ansi.sh"
source "${BPM_APP_DIR}/output/helpers.sh"
source "${BPM_APP_DIR}/system/exit_codes.sh"

# ------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------

##
# Runs the main application logic
#
# Globals:
#   - exit codes
#   - APP_NAME
#   - COMMANDS_DIR
# Arguments:
#   - name of command to invoke
# Outputs:
#   - write to stdout on normal execution
#   - writes to stderr on error
#
bpm::main() {
    # Capture the "command" argument that must be invoked
    local name="${1:-}"
    if [[ -n "$name" ]]; then
        shift 1;
    else
        # Default to help command
        name='help'
    fi

    # Match and execute requested command
    #
    # NOTE: Using the "list" command, one could automate this processing.
    # However, it does feel risky to automatically allow commands to be
    # invokable just by being located in the "commands" directory.
    #
    case $name in
        # TODO:
#        -i | install)
#            echo "run installing... "
#            exit $EXIT_SUCCESS
#            ;;

        # Show application help
        -h | --help | help)
            bpm::run_command 'help' "$@"
            exit $EXIT_SUCCESS # Help command does not exit with status code!
            ;;

        # Show this application's license
        license)
            bpm::run_command 'license' "$@"
            ;;

        # List available commands
        list)
            bpm::run_command 'list' "$@"
            ;;

        # Show version
        version)
            bpm::run_command 'version' "$@"
            ;;

        # Show application help, without ANSI
        # (note that this isn't a real option handling...)
        --no-ansi)
            ANSI=0
            bpm::run_command 'help' "$@"
            exit $EXIT_SUCCESS # Help command does not exit with status code!
            ;;

        # Fallback, in case command was not recognised
        *)
            output_helpers::error "Command \`${name}\` is unknown. Run \`bpm help\` to list available commands"
            exit $EXIT_ERROR_USAGE
            ;;
    esac
}

##
# Run application command
#
# Method will attempt to find "[command].sh" within the commands directory
# and invoke it's "main" function
#
# Globals:
#   - COMMANDS_DIR
# Arguments:
#   - name of command to invoke
#   - arguments and options to pass on to command
# Outputs:
#   - write to stdout on normal execution
#   - writes to stderr on error
#
bpm::run_command() {
    local name=${1:-}

    # Fail if name of command was not given
    if [[ -z "$name" ]]; then
        output_helpers::critical "\`bpm::run_command\` invoked without command name"
        exit $EXIT_FAILURE
    fi

    # Shift off the command "name" argument.
    shift;

    # Declare source file of requested command and abort if it does not exist
    local command_script="${COMMANDS_DIR}/${name}.sh"
    if [[ ! -f "${command_script}" ]]; then
        output_helpers::critical "Unable to find source file (${command_script}) for \`${name}\` command in \`bpm::run_command\`"
        exit $EXIT_FAILURE
    fi

    # Source in the command script
    source "${command_script}"

    # Declare "main" method name to invoke. Fail if it does not exist.
    local main="${name}::main"
    if [[ $(type -t "${main}") != function ]]; then
        output_helpers::alert "\`${name}\` command does not have a \"main\" method declared in ${command_script}"
        exit $EXIT_FAILURE
    fi

    # Finally, invoke the "main" method for the command and pass in
    # any given arguments
    ${main} "$@"
}

# ------------------------------------------------------------------------
# Run
# ------------------------------------------------------------------------

bpm::main "$@"