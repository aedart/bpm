#!/bin/bash

setup() {
    load "../../helpers/ini/ini_setup"
    ini_setup

    # Debug
#    echo "INI Default section" >&3
}

@test "Parses ini file and creates arrays" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/simple.ini"

    # Assert
#    assert_success

    # If able to return amount of elements, then array was created
    assert [ "${#simple[@]}" -eq 1 ]

    # Name of default section should be included in array
    assert [ "${simple[0]}" = "simple_default" ]
}

@test "Creates default section array" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/simple.ini"

    # Assert
#    assert_success

    # If the default section has elements, then we know that array
    # was created successfully...
    assert [ "${#simple_default[@]}" -eq 3 ]
}

@test "Creates custom named arrays" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/simple.ini" "config" "common"

    # Assert
#    assert_success

    assert [ "${#config[@]}" -eq 1 ]
    assert [ "${config[0]}" = "config_common" ]
    assert [ "${#config_common[@]}" -eq 3 ]
}