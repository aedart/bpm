#!/bin/bash

setup() {
    load "../../helpers/ini/ini_setup"
    ini_setup

    # Debug
#    echo "INI Invalid arguments" >&3
}

@test "Fails when no arguments provided" {
    # Run
    run ini::parse

    # Assert
    assert_failure
    assert_output --partial 'No arguments provided'
}

@test "Fails path to ini file is empty" {
    # Run
    run ini::parse ""

    # Assert
    assert_failure
    assert_output --partial 'Path to ini file is empty'
}

@test "Fails when path is invalid" {
    # Run
    run ini::parse "/some/path/to/ini/file/that-does-not-exist.ini"

    # Assert
    assert_failure
    assert_output --partial 'does not exist'
}

@test "Fails when filename is invalid" {
    # Run
    run ini::parse "${INI_FILES_DIR}/invalid @ filename.ini"

    # Assert
    assert_failure
    assert_output --partial 'Please provide a valid name argument'
}

@test "Fails when invalid default section name given" {
    local invalid_default_section='[My @ invalid default section'

    # Run
    run ini::parse "${INI_FILES_DIR}/simple.ini" "simple" "${invalid_default_section}"

    # Assert
    assert_failure
    assert_output "Unable to use '${invalid_default_section}' as default section name."
}