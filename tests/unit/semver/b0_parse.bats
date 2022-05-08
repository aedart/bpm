#!/bin/bash

setup() {
    load "../../helpers/semver/semver_setup"
    semver_setup

    # Debug
#    echo "Semver Parse" >&3
}

@test "Fails if version is invalid" {
    local input="1.0.0-beta%21"

    # Run
    run semver::parse "${input}" "my_parsed_version"

    # Assert
    assert_failure
    assert_output "${input} is not a valid version"
}

@test "Can parse major, minor and patch" {
    local input="2.3.4"
    local -A parsed=()

    # Run
    semver::parse "${input}" "parsed"

    # Assert
    [[ "${parsed['major']}" == '2' ]]
    [[ "${parsed['minor']}" == '3' ]]
    [[ "${parsed['patch']}" == '4' ]]
}

@test "Can parse with pre-release" {
    local input="2.3.4-beta.1"
    local -A parsed=()

    # Run
    semver::parse "${input}" "parsed"

    # Assert
    [[ "${parsed['pre_release']}" == 'beta.1' ]]
}

@test "Can parse with build meta" {
    local input="2.3.4+1a802-55113x"
    local -A parsed=()

    # Run
    semver::parse "${input}" "parsed"

    # Assert
    [[ "${parsed['build_meta']}" == '1a802-55113x' ]]
}

@test "Can parse full version" {
    local input="6.0.0-alpha+exp.sha.5114f85"
    local -A parsed=()

    # Run
    semver::parse "${input}" "parsed"

    # Assert
    [[ "${parsed['version']}" == '6.0.0-alpha+exp.sha.5114f85' ]]
    [[ "${parsed['major']}" == '6' ]]
    [[ "${parsed['minor']}" == '0' ]]
    [[ "${parsed['patch']}" == '0' ]]
    [[ "${parsed['pre_release']}" == 'alpha' ]]
    [[ "${parsed['build_meta']}" == 'exp.sha.5114f85' ]]
}