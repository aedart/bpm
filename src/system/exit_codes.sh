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
# Success Exit Codes
# ------------------------------------------------------------------------

# Successful exit
declare -i -r EXIT_SUCCESS=0

# ------------------------------------------------------------------------
# Failure Exit Codes
#
# Exit codes 1-2, 126-165, and 255 have special meanings. These SHOULD BE
# avoided used!
#
# Exit code 1, however, is considered a special case that
# can be used, if no other exit code seems suitable.
#
# @see https://tldp.org/LDP/abs/html/exitcodes.html
# ------------------------------------------------------------------------

# A general error
#
# Miscellaneous errors, such as "divide by zero" and other impermissible operations
declare -i -r EXIT_FAILURE=1

# Misuse of shell builtins (according to Bash documentation)
# (Reserved)
#
# Missing keyword or command, or permission problem (and diff return code on a failed binary file comparison).
declare -i -r EXIT_MISUSE_OF_SHELL_BUILTINS=2

# Command invoked cannot execute
# (Reserved)
#
# Permission problem or command is not an executable
declare -i -r EXIT_CANNOT_EXECUTE=126

# Command not found
# (Reserved)
#
# Possible problem with $PATH or a typo
declare -i -r EXIT_NOT_FOUND=127

# Invalid argument to exit
# (Reserved)
#
# exit takes only integer args in the range 0 - 255
declare -i -r EXIT_INVALID_EXIT_CODE=128

# ------------------------------------------------------------------------
# TODO: Port sysexits.h ???
# TODO: @see https://github.com/freebsd/freebsd-src/blob/master/include/sysexits.h
# ------------------------------------------------------------------------

# TODO: Hmmm...
declare -i -r EXIT_ERROR_USAGE=64