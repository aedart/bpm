#!/bin/bash

setup() {
    load "../../helpers/ini/ini_setup"
    ini_setup

    # Debug
#    echo "INI Bare Keys" >&3
}

@test "Fails if bare key is empty" {
    # Run
    run ini::parse "${INI_FILES_DIR}/key_bare_empty.ini"

    # Assert
    assert_failure
    assert_output --partial 'Invalid key name'
}

@test "Fails if bare key contains space" {
    # Run
    run ini::parse "${INI_FILES_DIR}/key_bare_with_space.ini"

    # Assert
    assert_failure
    assert_output --partial 'Invalid key name'
}

@test "Fails if bare key contains at symbol (@)" {
    # Run
    run ini::parse "${INI_FILES_DIR}/key_bare_at_symbol.ini"

    # Assert
    assert_failure
    assert_output --partial 'Invalid key name'
}

@test "Fails if bare key contains invalid symbol" {
    # Run
    run ini::parse "${INI_FILES_DIR}/key_bare_invalid_symbol.ini"

    # Assert
    assert_failure
    assert_output --partial 'Invalid key name'
}

@test "Can parse bare key" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/keys.ini"

    # Assert
    assert [ "${keys_default['bare']+_}" ]
}

@test "Can parse bare key with underscore" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/keys.ini"

    # Assert
    assert [ "${keys_default['bare_key']+_}" ]
}

@test "Can parse bare key with dot" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/keys.ini"

    # Assert
    assert [ "${keys_default['bare_key.with_dot']+_}" ]
}

@test "Can parse bare key with minus hyphen (-)" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/keys.ini"

    # Assert
    assert [ "${keys_default['bare_key-with-hyphen']+_}" ]
}

@test "Can parse bare key numeric" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/keys.ini"

    # Assert
    assert [ "${keys_default['23']+_}" ]
}

@test "Can parse bare key uppercase" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/keys.ini"

    # Assert
    assert [ "${keys_default['BARE_UPPER.CASE-KEY']+_}" ]
}

@test "Can parse bare key indented" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/keys.ini"

    # Assert
    assert [ "${keys_default['bare_indented']+_}" ]
}

@test "Can parse bare key mixed formatted" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/keys.ini"

    # Assert
    assert [ "${keys_default['bare_MIXED-42.key']+_}" ]
}