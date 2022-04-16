#!/bin/bash

setup() {
    load "../helpers/common"
    common_setup
}

@test "second test" {
    # Run
    # ... N/A

    # Assert
    assert_equal "second" 'second'
}