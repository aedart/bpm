#!/bin/bash

setup() {
    load "../helpers/unit"
    unit_setup
}

@test "second test" {
    # Run
    # ... N/A

    # Assert
    assert_equal "second" 'second'
}