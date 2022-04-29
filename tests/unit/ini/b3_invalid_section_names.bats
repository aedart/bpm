#!/bin/bash

setup() {
    load "../../helpers/ini/ini_setup"
    ini_setup

    # Debug
#    echo "INI Invalid section names" >&3
}

@test "Fails when section name starts with a number" {
    # Run
    run ini::parse "${INI_FILES_DIR}/section_invalid_number.ini"

    # Assert
    assert_failure
    assert_output --partial "Invalid section name"
}

@test "Fails when section name contains at symbol (@)" {
    # Run
    run ini::parse "${INI_FILES_DIR}/section_invalid_at_symbol.ini"

    # Assert
    assert_failure
    assert_output --partial "Invalid section name"
}

@test "Fails when section name contains dot (.)" {
    # Run
    run ini::parse "${INI_FILES_DIR}/section_invalid_dot.ini"

    # Assert
    assert_failure
    assert_output --partial "Invalid section name"
}

@test "Fails when section name contains minus hyphen (-)" {
    # Run
    run ini::parse "${INI_FILES_DIR}/section_invalid_hyphen.ini"

    # Assert
    assert_failure
    assert_output --partial "Invalid section name"
}

@test "Fails when section name contains whitespace" {
    # Run
    run ini::parse "${INI_FILES_DIR}/section_invalid_whitespace.ini"

    # Assert
    assert_failure
    assert_output --partial "Invalid section name"
}

@test "Fails when section name contains other invalid characters" {
    # Run
    run ini::parse "${INI_FILES_DIR}/section_invalid_other.ini"

    # Assert
    assert_failure
    assert_output --partial "Invalid section name"
}