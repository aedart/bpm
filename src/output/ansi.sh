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
# Restore / Reset
# ------------------------------------------------------------------------

# Restore - turn off all colour and text attributes
readonly restore=$(tput sgr0)

# ------------------------------------------------------------------------
# Text
# ------------------------------------------------------------------------

# Bold text
text_style_bold=$(tput bold)

# Underlined text
text_style_underline=$(tput smul)

# Blinking text
text_style_blink=$(tput blink)

# Reversed text
text_style_reverse=$(tput rev)

# Standout text
text_style_standout=$(tput smso)

# ------------------------------------------------------------------------
# Colours
# ------------------------------------------------------------------------

# Foreground colours
colour_black=$(tput setaf 0)
colour_red=$(tput setaf 1)
colour_green=$(tput setaf 2)
colour_yellow=$(tput setaf 3)
colour_blue=$(tput setaf 4)
colour_magenta=$(tput setaf 5)
colour_cyan=$(tput setaf 6)
colour_white=$(tput setaf 7)
colour_gray=$(tput setaf 247)

# Background colours
colour_bg_black=$(tput setab 0)
colour_bg_red=$(tput setab 1)
colour_bg_green=$(tput setab 2)
colour_bg_yellow=$(tput setab 3)
colour_bg_blue=$(tput setab 4)
colour_bg_magenta=$(tput setab 5)
colour_bg_cyan=$(tput setab 6)
colour_bg_white=$(tput setab 7)
colour_bg_gray=$(tput setab 247)

# ------------------------------------------------------------------------
# Utilities
# ------------------------------------------------------------------------

##
# Outputs a demo of the theme
#
# Outputs:
#   - Theme demo
#
output_colours::demo() {

    # Text
    echo "${text_style_bold}Bold text style${restore}"
    echo "${text_style_underline}Underlined text style${restore}"
    echo "${text_style_blink}Blinking text style${restore}"
    echo "${text_style_reverse}\"Reversed\" text style${restore}"
    echo "${text_style_standout}\"standout\" text style${restore}"
    echo ""
    echo "${text_style_bold}${text_style_underline}Bold underline text style${restore}"
    echo ""

    # Colours
    echo "${colour_black}Black${restore}"
    echo "${colour_bg_black}Black background${restore}"

    echo "${colour_red}Red${restore}"
    echo "${colour_bg_red}Red background${restore}"

    echo "${colour_green}Green${restore}"
    echo "${colour_bg_green}Green background${restore}"

    echo "${colour_yellow}Yellow${restore}"
    echo "${colour_bg_yellow}Yellow background${restore}"

    echo "${colour_blue}Blue${restore}"
    echo "${colour_bg_blue}Blue background${restore}"

    echo "${colour_magenta}Magenta${restore}"
    echo "${colour_bg_magenta}Magenta background${restore}"

    echo "${colour_cyan}Cyan${restore}"
    echo "${colour_bg_cyan}Cyan background${restore}"

    echo "${colour_white}White${restore}"
    echo "${colour_bg_white}White background${restore}"

    echo "${colour_gray}Gray${restore}"
    echo "${colour_bg_gray}Gray background${restore}"

    echo ""
    echo "${colour_blue}${colour_bg_white}${text_style_bold}Mixed output effect${restore}"
    echo ""
}

##
# Outputs available colours via `tput`
#
# Outputs:
#   - Colours and their ANSI code
#
output_colours::available_colours() {
    # Amount of available colours
    local amount

    amount=$(tput colors)

    for c in $(seq 0 "$amount"); do
        tput setaf "$c";
        tput setaf "$c" | cat -v;

        echo "$c";
    done
}