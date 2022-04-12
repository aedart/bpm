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
# Output settings
# ------------------------------------------------------------------------

# Verbose mode
#
# Should be captured as option by your command and
# set to readonly thereafter!
#
# 0 = false, 1 = true
VERBOSE=0

# Quiet mode
#
# Should be captured as option by your command and
# set to readonly thereafter!
#
# 0 = false, 1 = true
QUIET=0

# ------------------------------------------------------------------------
# Output helper methods
# ------------------------------------------------------------------------

##
# Outputs success message
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
# Outputs:
#   - writes message to stdout
#
output_helpers::success() {
    output_helpers::write "[${colour_green}ok${restore}] ${colour_white}$1${restore}"
}

##
# Outputs success message (using a checkmark symbol as prefix)
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
# Outputs:
#   - writes message to stdout
#
output_helpers::successCheck() {
    output_helpers::write "${colour_green}\u2714 $1${restore}"
}

##
# Outputs failure message
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
# Outputs:
#   - writes message to stderr
#
output_helpers::fail() {
    output_helpers::write_stderr "[${colour_red}failed${restore}] ${colour_white}$1${restore}"
}

##
# Outputs failure message (using a cross symbol as prefix)
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
# Outputs:
#   - writes message to stderr
#
output_helpers::failCross() {
    output_helpers::write_stderr "${colour_red}\u2718 $1${restore}"
}

##
# Outputs a title
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
# Outputs:
#   - writes message to stdout
#
output_helpers::title() {
#    output_helpers::write
    output_helpers::write "${colour_green}${text_style_bold} $* ${restore}${colour_yellow}"
    output_helpers::line '-'
#    output_helpers::write "${restore}"
}

##
# Outputs a subtitle
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
# Outputs:
#   - writes message to stdout
#
output_helpers::subtitle() {
    output_helpers::write "${colour_yellow} $*"
    output_helpers::line '.'
    output_helpers::write "${restore}"
}

##
# Outputs a "section" title
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
# Outputs:
#   - writes message to stdout
#
output_helpers::section() {
    local message=${1:-""}

    output_helpers::write " [${colour_gray}$message${restore}]"
}

##
# Outputs a horizontal line
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string symbol [optional] A single character symbol to use for line
# Outputs:
#   - writes line to stdout
#
output_helpers::line() {
    local symbol=${1:-'-'}

    output_helpers::write "$(printf '%*s\n' "${COLUMNS:-$(tput cols)}" ' ' | tr ' ' "$symbol")"
}

# ------------------------------------------------------------------------
# Logging
#
# Output methods for log level that are inspired by RFC 5424
# @see https://datatracker.ietf.org/doc/html/rfc5424
# ------------------------------------------------------------------------

##
# Outputs emergency level message
#
# E.g. System is unusable
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
# Outputs:
#   - writes message to stderr
#
output_helpers::emergency() {
    local msg=`echo $1 | tr '[:lower:]' '[:upper:]'`
    output_helpers::write_stderr "[${colour_bg_red}${colour_white}${text_style_bold}${text_style_blink}EMERGENCY${restore}] ${colour_red}${text_style_bold}$msg${restore}"
}

##
# Outputs alert level message
#
# E.g. Alert condition, conditions that require immediate actions
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
# Outputs:
#   - writes message to stderr
#
output_helpers::alert() {
    output_helpers::write_stderr "[${colour_bg_white}${colour_red}${text_style_bold}alert${restore}] ${colour_red}${text_style_bold}$1${restore}"
}

##
# Outputs critical level message
#
# E.g. Critical conditions, when a component or service is unavailable.
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
# Outputs:
#   - writes message to stderr
#
output_helpers::critical() {
    output_helpers::write_stderr "[${colour_bg_red}${colour_white}critical${restore}] ${colour_red}${text_style_bold}$1${restore}"
}

##
# Outputs error level message
#
# E.g. Error conditions, such as runtime errors that do not require immediate,
# but should be logged and handled appropriately
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
# Outputs:
#   - writes message to stderr
#
output_helpers::error() {
    output_helpers::write_stderr "[${colour_red}error${restore}] ${colour_red}$1${restore}"
}

##
# Outputs warning level message
#
# E.g. Warning conditions
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
# Outputs:
#   - writes message to stdout
#
output_helpers::warn() {
    output_helpers::write "[${colour_yellow}warning${restore}] ${colour_yellow}$1${restore}"
}

##
# Outputs notice level message
#
# E.g. Normal but significant condition
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
# Outputs:
#   - writes message to stdout
#
output_helpers::notice() {
    output_helpers::write "[${colour_blue}${text_style_bold}notice${restore}] ${colour_white}$1${restore}"
}

##
# Outputs information level message
#
# E.g. Informational messages
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
# Outputs:
#   - writes message to stdout
#
output_helpers::info() {
    output_helpers::write "[${colour_blue}info${restore}] ${colour_blue}$1${restore}"
}

##
# Output debug level message
#
# Globals:
#   - $VERBOSE - message is only written to output if $VERBOSE = 1
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string message
#   - int force [optional] force write, regardless of verbose mode. NOTE: $QUITE is
#               still respected!
# Outputs:
#   - writes message to stdout
#
output_helpers::debug() {
    local force=${2:-0}

    if [ $VERBOSE -eq 1 ] || [ $force -eq 1 ]; then
        output_helpers::write "[${colour_gray}debug${restore}] ${colour_gray}$1${restore}"
    fi
}

# ------------------------------------------------------------------------
# Other Utilities
# ------------------------------------------------------------------------

##
# Writes a new line to stdout
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string text to output
# Outputs:
#   - Writes to stdout
#
output_helpers::write() {
    if [ $QUIET -ne 1 ]; then
        echo -e "$*"
    fi
}

##
# Writes a new line to stderr
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Arguments:
#   - string text to output
# Outputs:
#   - Writes to stderr
#
output_helpers::write_stderr() {
    if [ $QUIET -ne 1 ]; then
        echo -e "$*" >&2;
    fi
}

##
# Outputs a demo of the output helper methods
#
# Globals:
#   - $QUIET if set to 1, when method will NOT output!
# Outputs:
#   - Outputs to stdout and stderr
#
output_helpers::demo() {
    # Logging
    output_helpers::debug "Debug level" 1
    output_helpers::info "Info level"
    output_helpers::notice "Notice level"
    output_helpers::warn "Warning level"
    output_helpers::error "Error level"
    output_helpers::critical "Critical level"
    output_helpers::alert "Alert level"
    output_helpers::emergency "Emergency level"

    # Other util methods
    output_helpers::line

    output_helpers::success "Success message"
    output_helpers::successCheck "Success message"
    output_helpers::fail "Fail message"
    output_helpers::failCross "Fail message"

    output_helpers::title "Title"
    output_helpers::subtitle "Subtitle"
    output_helpers::section "Section"
}