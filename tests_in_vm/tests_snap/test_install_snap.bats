#!/usr/bin/env bats
#
# Unit test script for installing software via snap
#
# This unit test script is using Bats as test framework
# Please refer to https://github.com/bats-core/bats-core for details

@test "test snap installer" {
    # skip this test if installer testing not activated
    if [ -z ${DOT_TEST_SNAP:+x} ]; then
        skip "Please set DOT_TEST_SNAP to activate installer testings"
    fi
    # ensure .bashrc is the updated one
    source ~/.bashrc
    # source the necessary util functions
    source ${BATS_TEST_DIRNAME}/../../util_funcs.sh
    # source the snap installer script
    source ${BATS_TEST_DIRNAME}/../../installers/snap.sh
    # iterate over all applications to install
    for app in "${SNAP_APPLICATIONS[@]}"; do
        # attempt to install
        print_info "Ready to snap install $app"
        run attempt_snap_install "$app"
        # check if install is successful
        [ "$status" -eq 0 ]
    done
}