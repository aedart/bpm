#!/bin/bash

setup() {
    load "../../helpers/ini/ini_setup"
    ini_setup

    # Debug
#    echo "INI Mixed" >&3
}

@test "Can parse sections, keys and values" {
    # Run (in same process)
    ini::parse "${INI_FILES_DIR}/sections.ini" "config"

    # Assert sections
    assert [ "${#config[@]}" -eq 3 ]
    assert [ "${config[0]}" = "config_default" ]
    assert [ "${config[1]}" = "config_section_a" ]
    assert [ "${config[2]}" = "config_section_b" ]

    # Assert amount of elements
    assert [ "${#config_default[@]}" -eq 1 ]
    assert [ "${#config_section_a[@]}" -eq 2 ]
    assert [ "${#config_section_b[@]}" -eq 3 ]

    # Assert values
    assert_equal "${config_default['name']}" "Tim"

    assert_equal "${config_section_a['age']}" "42"
    assert_equal "${config_section_a['job.title']}" "Senior Consultant"

    assert_equal "${config_section_b['email']}" "test@example.org"
    assert_equal "${config_section_b['work_mail']}" "other@example.org"
    assert_equal "${config_section_b['alt_mail']}" "alternative@example.org"
}