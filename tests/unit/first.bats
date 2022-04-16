#!/bin/bash

setup() {
    load "../helpers/common"
    common_setup
}

@test "first test" {
    # Run
    # ... N/A

    # Assert
    assert_equal "sweet" 'sweet'
}