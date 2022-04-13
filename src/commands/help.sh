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
help::name() {
    echo "$(basename "${BASH_SOURCE[0]}" ".sh")"
}

# Short description of this command
#
# WARNING: Must be a single line without any variables
# mangled into the string!
#
help_short_description='Displays help text.'

##
# Displays application's help text
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
help::main() {
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
                # Ignore this option, because this command should ALWAYS be able
                # to write to stdout!
                shift 1;
                ;;

            # show help
            -h | --help)
                # Well... this is getting a bit meta... we ignore
                # this --help for the help command, yet leave it be
                # available...
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

    # Declare verbose and quiet modes for read-only!
    readonly VERBOSE
    readonly QUIET
    readonly ANSI

    # -------------------------------------------------------------------------------------------- #

    # Output application's help text
    # NOTE: This command will NOT exit, in case that application desires a different exit code!
    help::usage
}

##
# Displays application's help text
#
# Globals:
#   - APP_NAME
# Outputs:
#   - writes to stdout
#
help::usage() {
    local description='A tool for managing dependencies of your bash script application.'

    # Obtain application version
    local version=
    version=$('help::app_version')

    # Obtain list of available commands
    local available_commands=
    available_commands=$('help::available_commands')

    # Obtain legal notice text
    local license_notice=
    license_notice=$('help::license_notice')

    # Output application title
    output_helpers::title "Bashy Package Manager (BPM)${restore} \n ${colour_gray}Version: ${colour_white}${version}${restore}"

    # Output help text body
    output_helpers::write " ${colour_gray}${description}${restore}

 ${colour_yellow}Usage:${restore}
    ${APP_NAME} [command] [options]

 ${colour_yellow}Available commands:${restore}
${available_commands}

 ${colour_yellow}Options:${restore}
    -h, --help                  ${colour_white}Displays help text.${restore}
    -v, --verbose               ${colour_white}Outputs eventual debugging messages.${restore}
    -q, --quiet                 ${colour_white}Disables all output (except for the --help option).${restore}
        --no-ansi               ${colour_white}Disables ANSI output.${restore}

 ${colour_yellow}License notice:${restore}
 ${colour_gray}${license_notice}${restore}
"
}

##
# Outputs formatted list of available commands
#
# Outputs:
#   - writes list of commands to stdout
#
help::available_commands() {
    local commands=
    commands=$('bpm::run_command' 'list' || test $? = 1)

    echo "${commands}" | sed 's/^/    /'
}

##
# Outputs application's version
#
# Outputs:
#   - writes version to stdout
#
help::app_version() {
    local version=
    version=$('bpm::run_command' 'version' || test $? = 1)

    echo "$version"
}

##
# Outputs application license notice
#
# Globals:
#   - APP_NAME
# Outputs:
#   - writes to stdout
#
help::license_notice() {
    echo "Copyright (C) 2022  Alin Eugen Deac <aedart@gmail.com>
 This program comes with ABSOLUTELY NO WARRANTY; for details type \`${APP_NAME} license\`.
 This is free software, and you are welcome to redistribute it
 under certain conditions; type \`${APP_NAME} license\` for details."
}