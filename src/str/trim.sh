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
# Trim given string
#
# Arguments:
#   - string to be trimmed
# Outputs:
#   - Writes trimmed string to stdout
#
str::trim() {
    local str="$1"

    shopt -s extglob

    # Remove leading and trailing whitespaces
    str="${str##*( )}"
    str="${str%%*( )}"

    # Alternative, but very slow, because we need to pipe...
    # echo "${str}" | sed 's/^ *\| *$//g'

    echo "$str"
}