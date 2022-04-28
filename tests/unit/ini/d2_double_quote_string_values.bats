#!/bin/bash

setup() {
    load "../../helpers/ini/ini_setup"
    ini_setup

    # Debug
#    echo "INI Double quite string values" >&3
}

@test "Fails when value incorrect quoted" {
    # Run
    run ini::parse "${INI_FILES_DIR}/value_string_double_quote_invalid.ini" 'values'

    # Assert
    assert_failure
    assert_output --partial "Invalid string value. Start or end quote (\") is missing"
}

@test "Can parse double quote string value" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/values_string_double_quote.ini" 'values'

    # Assert
    assert [ "${values_default['foo']+_}" ]
    assert_equal "${values_default['foo']}" "bar"
}

@test "Trims double quote string value" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/values_string_single_quote.ini" 'values'

    # Assert
    assert [ "${values_default['zen']+_}" ]
    assert_equal "${values_default['zen']}" "trimmed value"
}

@test "Can parse escaped double quotes" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/values_string_double_quote.ini" 'values'

    # Assert
    assert [ "${values_default['bar']+_}" ]
    assert_equal "${values_default['bar']}" 'My "double quoted" value'
}

@test "Can parse escaped characters" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/values_string_double_quote.ini" 'values'

    # Debug
#    echo "${values_default['escaped']}" >&3

    # Assert
    assert [ "${values_default['escaped']+_}" ]

    local expected=
    expected=$(echo -e "\tValue with\nescaped \\\characters")

    assert_equal "${expected}" "${values_default['escaped']}"
}