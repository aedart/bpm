#!/bin/bash

setup() {
    load "../../helpers/ini/ini_setup"
    ini_setup

    # Debug
#    echo "INI String Keys" >&3
}

@test "Fails if string key is empty" {
    # Run
    run ini::parse "${INI_FILES_DIR}/key_string_empty.ini"

    # Assert
    assert_failure
    assert_output --partial 'Invalid key name'
}

@test "Fails if string key contains at symbol (@)" {
    # Run
    run ini::parse "${INI_FILES_DIR}/key_string_at_symbol.ini"

    # Assert
    assert_failure
    assert_output --partial 'Invalid key name'
}

@test "Fails malformed key (bare and string format)" {
    # Run
    run ini::parse "${INI_FILES_DIR}/key_invalid_formatted.ini"

    # Assert
    assert_failure
    assert_output --partial 'Invalid key name'
}

@test "Can parse string key using single quote (')" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/keys.ini"

    # Assert
    assert [ "${keys_default['single_quote_key']+_}" ]
}

@test "Can parse string key using double quote (\")" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/keys.ini"

    # Assert
    assert [ "${keys_default['double-quote key']+_}" ]
}

@test "Can parse string key containing 'special' symbols" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/keys.ini"

    # Assert
    assert [ "${keys_default['special -_- @ STRING : .key?']+_}" ]
}