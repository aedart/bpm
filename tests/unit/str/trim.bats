#!/bin/bash

setup() {
    load "../../helpers/unit"
    unit_setup

    # Source in the trim method
    source "${PROJECT_ROOT}/src/str/trim.sh"

    # Debug
#    echo "String Trim Tests" >&3
}

@test "Can trim string" {
    # Run
    run str::trim "   Hi there...   "

    # Assert
    assert_success
    assert_output 'Hi there...'
}
