#!/bin/bash

setup() {
    load "../../helpers/ini/ini_setup"
    ini_setup

    # Debug
#    echo "INI Single quite string values" >&3
}

@test "Fails when value incorrect quoted" {
    # Run
    run ini::parse "${INI_FILES_DIR}/value_string_single_quote_invalid.ini" 'values'

    # Assert
    assert_failure
    assert_output --partial "Invalid string value. Start or end quote (') is missing"
}

@test "Can parse single quote string value" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/values_string_single_quote.ini" 'values'

    # Assert
    assert [ "${values_default['foo']+_}" ]
    assert_equal "${values_default['foo']}" "bar"
}

@test "Trims single quote string value" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/values_string_single_quote.ini" 'values'

    # Assert
    assert [ "${values_default['zen']+_}" ]
    assert_equal "${values_default['zen']}" "trimmed value"
}

@test "Can parse escaped single quotes" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/values_string_single_quote.ini" 'values'

    # Assert
    assert [ "${values_default['bar']+_}" ]
    assert_equal "${values_default['bar']}" "My 'single quoted' value"
}

@test "Ignores other escaped characters" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/values_string_single_quote.ini" 'values'

    # Assert
    assert [ "${values_default['other_escaped_chars']+_}" ]
    assert_equal "${values_default['other_escaped_chars']}" "Other \n\t escaped characters are ignored"
}