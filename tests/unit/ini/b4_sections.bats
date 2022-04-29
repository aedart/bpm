#!/bin/bash

setup() {
    load "../../helpers/ini/ini_setup"
    ini_setup

    # Debug
#    echo "INI Sections" >&3
}

@test "Parses all sections" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/sections.ini" "config"

    # Assert
    assert [ "${#config[@]}" -eq 3 ]
    assert [ "${config[0]}" = "config_default" ]
    assert [ "${config[1]}" = "config_section_a" ]
    assert [ "${config[2]}" = "config_section_b" ]
}

@test "Parses all sections' elements" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/sections.ini" "config"

    # Assert - Note that this test does not check if keys
    # and values are parsed correctly, only that each section
    # has the appropriate amount of elements
    assert [ "${#config_default[@]}" -eq 1 ]
    assert [ "${#config_section_a[@]}" -eq 2 ]
    assert [ "${#config_section_b[@]}" -eq 3 ]
}