#!/bin/bash

setup() {
    load "../../helpers/ini/ini_setup"
    ini_setup

    # Debug
#    echo "INI Invalid array names" >&3
}

@test "Fails when array name starts with a number" {
    local name='01_config'

    # Run
    run ini::parse "${INI_FILES_DIR}/simple.ini" "${name}"

    # Assert
    assert_failure
    assert_output --partial "Unable to use '${name}' as array variable name"
}

@test "Fails when array name contains at symbol (@)" {
    local name='my@config'

    # Run
    run ini::parse "${INI_FILES_DIR}/simple.ini" "${name}"

    # Assert
    assert_failure
    assert_output --partial "Unable to use '${name}' as array variable name"
}

@test "Fails when array name contains dot (.)" {
    local name='my.config'

    # Run
    run ini::parse "${INI_FILES_DIR}/simple.ini" "${name}"

    # Assert
    assert_failure
    assert_output --partial "Unable to use '${name}' as array variable name"
}

@test "Fails when array name contains minus hyphen (-)" {
    local name='my-config'

    # Run
    run ini::parse "${INI_FILES_DIR}/simple.ini" "${name}"

    # Assert
    assert_failure
    assert_output --partial "Unable to use '${name}' as array variable name"
}

@test "Fails when array name contains other invalid characters" {
    local name='my[config\/&$£!'

    # Run
    run ini::parse "${INI_FILES_DIR}/simple.ini" "${name}"

    # Assert
    assert_failure
    assert_output --partial "Unable to use '${name}' as array variable name"
}