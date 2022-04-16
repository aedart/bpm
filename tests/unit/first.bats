#!/bin/bash

setup() {
    load "../helpers/unit"
    unit_setup
}

@test "first test" {
    # Run
    # ... N/A

    # Assert
    assert_equal "sweet" 'sweet'
}