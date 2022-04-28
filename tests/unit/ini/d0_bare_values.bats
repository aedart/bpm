#!/bin/bash

setup() {
    load "../../helpers/ini/ini_setup"
    ini_setup

    # Debug
#    echo "INI Bare values" >&3
}

@test "Can parse empty bare value" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/values_bare.ini" 'values'

    # Assert
    assert [ "${values_default['empty_value']+_}" ]
    assert [ -z "${values_default['empty_value']}" ]
}

@test "Can parse bare string value" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/values_bare.ini" 'values'

    # Assert
    assert [ "${values_default['name']+_}" ]
    assert_equal "${values_default['name']}" "John"
}

@test "Can parse bare integer value" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/values_bare.ini" 'values'

    # Assert
    assert [ "${values_default['age']+_}" ]
    assert_equal "${values_default['age']}" "31"
}

@test "Can parse bare float value" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/values_bare.ini" 'values'

    # Assert
    assert [ "${values_default['avg_level']+_}" ]
    assert_equal "${values_default['avg_level']}" "7.82"
}

@test "Ignores bare value that starts with hash symbol (#)" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/values_bare.ini" 'values'

    # Assert
    assert [ "${values_default['css_colour']+_}" ]
    assert [ -z "${values_default['css_colour']}" ]
}

@test "trims bare string value" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/values_bare.ini" 'values'

    # Assert
    assert [ "${values_default['trimmed']+_}" ]
    assert_equal "${values_default['trimmed']}" "a strange value, but valid"
}