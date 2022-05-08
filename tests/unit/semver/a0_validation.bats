#!/bin/bash

setup() {
    load "../../helpers/semver/semver_setup"
    semver_setup

    # Debug
#    echo "Semver Validation" >&3
}

@test "Can validate versions" {

    # Version string and expected validation result
    # 0 = valid, 1 = invalid
    local data_provider="
1.0.0                                   0
2.2.3                                   0
10.91.105                               0
2.2.3-alpha                             0
2.2.3-alpha.1                           0
1.2.3-alpha.beta                        0
5.0.0-alpha.beta.3+exp.sha.5114f85      0
1.0.0+exp.sha.5114f85                   0
x                                       1
x.y.z                                   1
1.0                                     1
1.0.a                                   1
v1.0.0                                  1   # (v) prefix is actually not allowed!
1.0.0-                                  1
1.0.0-beta alpha                        1
1.0.0-beta_alpha                        1   # Underscore (_) is not allowed in pre-release identifier!
1.0.0-beta%21                           1
1.0.0@something                         1
1.0.0+@something                        1
1.0.0+exp_sha_5114f85                   1
"

    # Process data_provider
    while read -r line; do
        if [[ -z $line ]]; then
            continue
        fi

        # Extract data
        read -r -a data <<< "$line"

        local version="${data[0]}"
        local expected="${data[1]}"

        # Debug:
#        echo "version: ${version} | expected: ${expected}" >&3

        # Run and assert
        run semver::is_valid "${version}"

        if [[ "$status" -ne "${expected}" ]]; then
            fail "Expected '${expected}' as result for version: '${version}'. Received: ${status}"
        fi

    done <<<"$data_provider"
}