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

# TODO
ini::parse() {
    # Abort if no arguments are given
    if [[ $# -eq 0 ]]; then
        ini::_output_error "No arguments provided. You must at least specify path to ini file!"
        exit 1
    fi

    # Full path to ini file
    local file="$1"

    # Ensure file exists
    ini::assert_ini_file_exists "$file"

    # ------------------------------------------------------------------------

    # Name used for prefixing sections, so that an array per section can be
    # created.
    # E.g. "config" as name will be used to prefix section "section_a",
    # resulting in a "config_section_a" array.
    # Defaults to filename without file extension.
    local name=${2:-$('ini::_resolve_default_prefix' "$file")}

    # Name of the "default" section to create, for key-value pairs in
    # ini-file that do not explicitly belong to a section.
    local default_section_name=${3:-'default'}

    # Assert provided names are valid
    ini::assert_valid_name "$name" "Unable to use '${name}' as array variable name. Please provide a valid name argument."
    ini::assert_valid_name "$default_section_name" "Unable to use '${default_section_name}' as default section name."

    # ------------------------------------------------------------------------

    # Declare global array that contains all section names for the given ini
    # file.
    # Notice that the "sections_" is used as a name, to avoid evt. naming
    # conflict with sections in ini file.
    declare -g -a "${name}"
    local -n all_sections="${name}"

    # Name of the current "section" array.
    # This name will be updated each time a section is encountered.
    local section_name="${name}_${default_section_name}"

    # ------------------------------------------------------------------------

    # Clean the ini file's content
    local cleaned=
    cleaned=$('ini::_clean_file_contents' "$file")

    # Process the ini file contents
    readarray -t lines < <( echo "$cleaned" )
    for line in "${lines[@]}"; do

        line=$('str::trim' "${line}")

        # Resolve section name, if line contains such.
        # If section name is invalid, then script fails.
        if ini::_is_line_a_section "${line}"; then
            section_name=$('ini::_resolve_section_name' "${line}" "${name}")
            continue;
        fi

        # Create "section name" array if it does not exist
        if ! ini::_is_section_array "$section_name"; then
            # Declare section using global modifier
            declare -g -A "$section_name"

            # Add section name to list of sections
            all_sections+=( "${section_name}" )
        fi

        # Create a local reference to the section
        local -n section=$section_name

        # Obtain key and value, trim leading and trailing whitespace
        local key=
        key=$('ini::_resolve_key' "$line")

        local value=
        value=$('ini::_resolve_value' "$line")

        # Add key-value pair to section
        # shellcheck disable=SC2034
        section["$key"]=$value
    done

    return 0
}

##
# Assert ini file exists
#
# Arguments:
#   - Path to ini file
# Outputs:
#   - Writes to stderr if file does not exist
# Returns:
#   - 1 if file does not exist
#
ini::assert_ini_file_exists(){
    local file="$1"

    # Fail if file argument is empty
    if [[ -z $file ]]; then
        ini::_output_error 'Path to ini file is empty'
        exit 1
    fi

    # Fail if file does not exist
    if [[ ! -f $file ]]; then
        ini::_output_error "${file} does not exist"
        exit 1
    fi
}

##
# Assert given name is valid
#
# (Ensures name can be used as bash variable name)
#
# Arguments:
#   - string name
#   - string message [optional]
# Outputs:
#   - Writes to stderr if name is invalid
# Returns:
#   - 1 if name is invalid
#
ini::assert_valid_name() {
    local name="$1"
    local msg=${2:-"Invalid name: ${name}"}

    local regex='^[a-zA-Z_][a-zA-Z0-9_]*$'
    if [[ ! ${name} =~ $regex ]]; then
        ini::_output_error "${msg}"
        exit 1;
    fi
}

##
# Assert that given "normal" key is valid
#
# Normal in this context means a bare (not quoted key)
#
# Arguments:
#   - string key
#   - string message [optional]
# Outputs:
#   - Writes to stderr if key is invalid
# Returns:
#   - 1 if key is invalid
#
ini::assert_bare_key() {
    local key="$1"
    local msg=${2:-"Invalid key name: '${key}'"}

    if [[ -z $key ]]; then
        ini::_output_error "${msg}"
        exit 1;
    fi

    # Prevent '@' from being used as a key name
    if [[ $key == "@" ]]; then
        # Use a slightly different error msg here...
        ini::_output_error "@ cannot be used as a key name! - ${msg}"
        exit 1;
    fi

    # Use same validation as toml, for bare key
    local regex='^[A-Za-z0-9_-]*$'
    if [[ ! ${key} =~ $regex ]]; then
        ini::_output_error "${msg}"
        exit 1;
    fi
}

##
# Assert that given "string" key is valid
#
# Arguments:
#   - string key
#   - string message [optional]
# Outputs:
#   - Writes to stderr if key is invalid
# Returns:
#   - 1 if key is invalid
#
ini::assert_string_key() {
    local key="$1"
    local msg=${2:-"Invalid key name: '${key}'"}

    if [[ -z $key ]]; then
        ini::_output_error "${msg}"
        exit 1;
    fi

    # Prevent '@' from being used as a key name
    if [[ $key == "@" ]]; then
        ini::_output_error "@ cannot be used as a key name! - ${msg}"
        exit 1;
    fi

    # Other than the above, a string key may contains whatever character is
    # desired...
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
ini::_output_error() {
    echo -e "$*" >&2;
}

##
# Resolves the default "section_name" arrays name name
#
# Arguments:
#   - Path to ini file
# Outputs:
#   - writes default name to stdout
#   - writes to stderr when path to file is not provided
# Returns:
#   - 0 on success
#   - 1 on failure
#
ini::_resolve_default_prefix() {
    local file="$1"

    if [[ -z "$file" ]]; then
        ini::_output_error "Unable to resolve default name. Please specify valid ini filename!"
        exit 1
    fi

    # Get basename of file
    local filename=
    filename=$(basename -- "$file")

    # Remove file extension
    filename="${filename%.*}"

    # Replace whitespaces with underscore
    filename="${filename// /_}"

    # Replace dashes with underscore
    filename="${filename//-/_}"

    echo "${filename}"
}

##
# Cleans the given ini file
#
# Arguments:
#   - Path to ini file
# Outputs:
#   - Writes cleaned file contents to stdout
#
ini::_clean_file_contents() {
    local file="$1"

    # Remove comments and blank lines
    local output=
    output=$(sed '/^[\s\t]*[#;]/d' "$file" | sed '/^[[:space:]]*$/d')

    echo "${output}";
}

##
# Determine if section_name array exists
#
# Arguments:
#   - Name of section_name array
# Returns:
#   - 0 if section_name array exists
#   - 1 if section_name array does not exist
#
ini::_is_section_array() {
    local name="$1"
    local regex="^declare -[aA] ${name}(=|$)"

    if [[ $(declare -p "$name" 2> /dev/null) =~ $regex ]]; then
        return 0
    fi

    return 1;
}

##
# Determine if given line defines a "section"
#
# Arguments:
#   - Line from ini file
# Returns:
#   - 0 if line defines a section
#   - 1 if line does not define a section
#
ini::_is_line_a_section() {
    local line="$1"

    local regex='^\[(.+)\]'
    if [[ $line =~ $regex ]]; then
        return 0
    fi

    return 1
}

##
# Resolves the section name from given line
#
# Arguments:
#   - line from ini file
#   - section name
# Outputs:
#   - Writes prefixed section to stdout
#   - Writes error to stderr, if section name is invalid in ini file
# Returns:
#   - 1 on invalid section name
#
ini::_resolve_section_name() {
    local line="$1"
    local prefix="$2"

    local section_name="${line}"

    # Remove evt. inline comments after the section
    section_name="${section_name%%\;*}"
    section_name="${section_name%%\#*}"

    # Remove []
    section_name="${section_name#[}"
    #section_name="${section_name%]}" # Hmmm... does not appear to always work!?
    section_name="${section_name/]/ }"

    # Trim and lower case
    section_name=$('str::trim' "$section_name" | tr '[:upper:]' '[:lower:]')

    # Validate
    ini::assert_valid_name "${section_name}" "Invalid section name: ${line}"

    # Finally, output the section name with given name...
    echo "${prefix}_${section_name}"
}

##
# Resolves the key from given line
#
# Arguments:
#   - line from ini file
# Outputs:
#   - Writes resolved key to stdout
#   - Writes error to stderr, if key name is invalid
# Returns:
#   - 1 on invalid key
#
ini::_resolve_key() {
    local line="$1"

    # Obtain the key
    local key="${line%%=*}"

    # trim key
    key=$('str::trim' "$key")

    # When key is a string, using double quotes or single quotes
    local regex="^(\"|')"
    if [[ $key =~ $regex ]]; then
        # Remove double quotes
        key="${key#\"}"
        key="${key%\"}"

        # Remove single quotes
        key="${key#\'}"
        key="${key%\'}"

        # Assert string key
        ini::assert_string_key "${key}" "Invalid key name '${key}', in line: ${line}"
    else
        # Otherwise it means that the key should follow a more strict
        ini::assert_bare_key "${key}" "Invalid key name '${key}', in line: ${line}\nDouble or single quotes can perhaps be used for key name (@ is not included)."
    fi

    # Finally, output resolved key
    echo "${key}";
}

# TODO:
ini::_resolve_value() {
    local line="$1"

    # Obtain the value
    local value="${line#*=}"

    # Trim value
    value=$('str::trim' "$value")

    # Finally, output resolved value
    echo "${value}"

    # TODO: Clean, trim, sanitise this ...
#    value=$(echo ${line#*=} | sed 's/^ *\| *$//g')
}