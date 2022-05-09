#!/bin/bash

setup() {
    load "../../helpers/semver/semver_setup"
    semver_setup

    # Debug
#    echo "Semver Compare less than" >&3
}

@test "less than" {
    # 0 = true, 1 = false
    local data_provider="
1.0.0             2.0.0                         0       # (a < b) major
1.1.0             1.2.0                         0       # (a < b) minor
1.2.1             1.2.2                         0       # (a < b) patch
1.2.1+132         1.2.2+abc                     0       # (a < b) build meta ignored
1.0.0-alpha       1.0.0                         0       # (a < b)
1.0.0-alpha       1.0.0-alpha.1                 0       # (a < b)
1.0.0-alpha.1     1.0.0-alpha.beta              0       # (a < b)
1.0.0-alpha.beta  1.0.0-beta                    0       # (a < b)
1.0.0-beta        1.0.0-beta.2                  0       # (a < b)
1.0.0-beta.2      1.0.0-beta.11                 0       # (a < b)
1.0.0-beta.11     1.0.0-rc.1                    0       # (a < b)
1.0.0-beta.11+abc 1.0.0-rc.1+123                0       # (a < b)

1.0.0             1.0.0                         1       # (a = b)
1.2.3             1.2.3                         1       # (a = b)
1.0.0-alpha       1.0.0-alpha                   1       # (a = b)
1.0.0-alpha.beta  1.0.0-alpha.beta              1       # (a = b)
1.0.0-beta.2      1.0.0-beta.2                  1       # (a = b)
1.0.0-beta        1.0.0-beta+202.205.08         1       # (a = b) build meta is ignored!
1.0.0+20220508    1.0.0+build.45                1       # (a = b) build meta is ignored!

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

    run_compare_method "semver::lt" "$data_provider"
}

@test "less than or equal to" {
    # 0 = true, 1 = false
    local data_provider="
1.0.0             2.0.0                         0       # (a < b) major
1.1.0             1.2.0                         0       # (a < b) minor
1.2.1             1.2.2                         0       # (a < b) patch
1.2.1+132         1.2.2+abc                     0       # (a < b) build meta ignored
1.0.0-alpha       1.0.0                         0       # (a < b)
1.0.0-alpha       1.0.0-alpha.1                 0       # (a < b)
1.0.0-alpha.1     1.0.0-alpha.beta              0       # (a < b)
1.0.0-alpha.beta  1.0.0-beta                    0       # (a < b)
1.0.0-beta        1.0.0-beta.2                  0       # (a < b)
1.0.0-beta.2      1.0.0-beta.11                 0       # (a < b)
1.0.0-beta.11     1.0.0-rc.1                    0       # (a < b)
1.0.0-beta.11+abc 1.0.0-rc.1+123                0       # (a < b)

1.0.0             1.0.0                         0       # (a = b)
1.2.3             1.2.3                         0       # (a = b)
1.0.0-alpha       1.0.0-alpha                   0       # (a = b)
1.0.0-alpha.beta  1.0.0-alpha.beta              0       # (a = b)
1.0.0-beta.2      1.0.0-beta.2                  0       # (a = b)
1.0.0-beta        1.0.0-beta+202.205.08         0       # (a = b) build meta is ignored!
1.0.0+20220508    1.0.0+build.45                0       # (a = b) build meta is ignored!

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

    run_compare_method "semver::lte" "$data_provider"
}