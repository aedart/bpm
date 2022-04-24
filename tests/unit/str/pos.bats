#!/bin/bash

setup() {
    load "../../helpers/unit"
    unit_setup

    # Source in the pos method
    source "${PROJECT_ROOT}/src/str/pos.sh"

    # Debug
#    echo "String Position Tests" >&3
}

@test "Can find position of needle" {
    local haystack='my string a'
    local needle='g'

    # Run
    run str::pos "${haystack}" "${needle}"

    # Assert
    assert_output '8'
}

@test "Returns -1 when needle not found" {
    local haystack='my string a'
    local needle='x'

    # Run
    run str::pos "${haystack}" "${needle}"

    # Assert
    assert_output '-1'
}

@test "Can find position of * symbol" {
    local haystack='my* string'
    local needle='*'

    # Run
    run str::pos "${haystack}" "${needle}"

    # Assert
    assert_output '2'
}