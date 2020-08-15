#!/usr/bin/env bats
#
# Unit test script for installing zsh and its tools
#
# This unit test script is using Bats as test framework
# Please refer to https://github.com/bats-core/bats-core for details

@test "test zsh installer" {
    # skip this test if installer testing not activated
    if [ -z ${DOT_TEST_INSTALLERS:+x} ]; then
        skip "Please set DOT_TEST_INSTALLERS to activate installer testings"
    fi
    # ensure .bashrc is the updated one
    source ~/.bashrc
    # source the necessary util functions
    source ${BATS_TEST_DIRNAME}/../util_funcs.sh
    source ${BATS_TEST_DIRNAME}/../installers/apt.sh  # for attempt_apt_install
    # source the zsh installer script
    source ${BATS_TEST_DIRNAME}/../installers/zsh.sh
    # install wget
    attempt_apt_install "gnupg"
    attempt_apt_install "wget"
    # attempt to install
    print_info "Ready to test installing zsh and its tools"
    run install_zsh_and_more false
    # check if install is successful
    [ "$status" -eq 0 ]
}