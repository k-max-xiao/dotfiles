#!/usr/bin/env bats
#
# Unit test script for installing software via apt
#
# This unit test script is using Bats as test framework
# Please refer to https://github.com/bats-core/bats-core for details

@test "test apt installer" {
    # skip this test if installer testing not activated
    if [ -z ${DOT_TEST_INSTALLERS:+x} ]; then
        skip "Please set DOT_TEST_INSTALLERS to activate installer testings"
    fi
    # ensure .bashrc is the updated one
    source ~/.bashrc
    # source the necessary util functions
    source ${BATS_TEST_DIRNAME}/../util_funcs.sh
    # source the apt installer script
    source ${BATS_TEST_DIRNAME}/../installers/apt.sh
    # prepare for the apt installation
    attempt_apt_install "gnupg"
    attempt_apt_install "wget"
    pre_install_apt
    # install tzdata in non interactive way to avoid prompt
    print_info "Ready to apt install tzdata"
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
    [[ "$?" -eq 0 ]]
    # iterate over all applications to install
    for app in "${APT_APPLICATIONS[@]}"; do
        # attempt to install
        print_info "Ready to apt install $app"
        run attempt_apt_install "$app"
        # check if install is successful
        [ "$status" -eq 0 ]
    done
}