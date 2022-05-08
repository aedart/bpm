#!/bin/bash

setup() {
    load "../../helpers/semver/semver_setup"
    semver_setup

    # Debug
#    echo "Semver Compare" >&3
}

@test "Fails when input are not valid semantic versions" {
    # Run
    run semver::compare "1.0.0" "1.x"

    # Assert
    assert_failure
    assert_output --partial "1.x is not a valid version"
}

@test "Can compare versions" {

    # Version strings and compare result expectation
    #   - "-1":  a is less than b     (a < b)  stdout
    #   -  "0":  a equals b           (a = b)  stdout
    #   -  "1":  a is greater than b  (a > b)  stdout

    local data_provider="
1.0.0             1.0.0                         0       # (a = b)
1.2.3             1.2.3                         0       # (a = b)
1.0.0-alpha       1.0.0-alpha                   0       # (a = b)
1.0.0-alpha.beta  1.0.0-alpha.beta              0       # (a = b)
1.0.0-beta.2      1.0.0-beta.2                  0       # (a = b)
1.0.0-beta        1.0.0-beta+202.205.08         0       # (a = b) build meta is ignored!
1.0.0+20220508    1.0.0+build.45                0       # (a = b) build meta is ignored!

1.0.0             2.0.0                         -1      # (a < b) major
1.1.0             1.2.0                         -1      # (a < b) minor
1.2.1             1.2.2                         -1      # (a < b) patch
1.2.1+132         1.2.2+abc                     -1      # (a < b) build meta ignored
1.0.0-alpha       1.0.0                         -1      # (a < b)
1.0.0-alpha       1.0.0-alpha.1                 -1      # (a < b)
1.0.0-alpha.1     1.0.0-alpha.beta              -1      # (a < b)
1.0.0-alpha.beta  1.0.0-beta                    -1      # (a < b)
1.0.0-beta        1.0.0-beta.2                  -1      # (a < b)
1.0.0-beta.2      1.0.0-beta.11                 -1      # (a < b)
1.0.0-beta.11     1.0.0-rc.1                    -1      # (a < b)
1.0.0-beta.11+abc 1.0.0-rc.1+123                -1      # (a < b)

2.0.0             1.0.0                         1       # (a > b) major
1.1.0             1.0.0                         1       # (a > b) minor
1.2.1             1.2.0                         1       # (a > b) patch
1.2.1+abc         1.2.0+132                     1       # (a > b) build meta ignored
1.0.0             1.0.0-alpha                   1       # (a > b)
1.0.0             1.0.0-rc.1                    1       # (a > b)
1.0.0-rc.1        1.0.0-beta.11                 1       # (a > b)
1.0.0-beta.11     1.0.0-beta.2                  1       # (a > b)
1.0.0-beta.2      1.0.0-beta                    1       # (a > b)
1.0.0-beta        1.0.0-alpha.beta              1       # (a > b)
1.0.0-alpha.beta  1.0.0-alpha.1                 1       # (a > b)
1.0.0-alpha.1     1.0.0-alpha                   1       # (a > b)
1.0.0-alpha.1+123 1.0.0-alpha+abc               1       # (a > b)
"

    # Process data_provider
    while read -r line; do
        local ignore="^\#"
        if [[ -z $line || $line =~ $ignore ]]; then
            continue
        fi

        # Extract data
        read -r -a data <<< "$line"

        local a="${data[0]}"
        local b="${data[1]}"
        local expected="${data[2]}"

        # Debug:
        # echo "${a} vs. ${b} | expected: ${expected}" >&3

        # Run and assert
        run semver::compare "${a}" "${b}"

        if [[ "$output" != "${expected}" ]]; then
            fail "Expected '${expected}'. Got '${output}' for '${a}' vs. '${b}'"
        fi

    done <<<"$data_provider"
}