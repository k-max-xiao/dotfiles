#!/usr/bin/env bats
#
# Unit test script for Python3 installer script
#
# This unit test script is using Bats as test framework
# Please refer to https://github.com/bats-core/bats-core for details

@test "test Python3 installer script" {
    # skip this test if installer testing not activated
    if [ -z ${DOT_TEST_INSTALLERS:+x} ]; then
        skip "Please set DOT_TEST_INSTALLERS to activate installer testings"
    fi
    # ensure .bashrc is the updated one
    source ~/.bashrc
    # source the necessary util functions
    source ${BATS_TEST_DIRNAME}/../util_funcs.sh
    # execute the python3 installer function
    source ${BATS_TEST_DIRNAME}/../installers/python3.sh
    run install_latest_python3
    # check the running is successful
    [ "$status" -eq 0 ]
    # check if the latest Python3 has been installed
    run python3${DOT_PYTHON3_VER:-.8} --version
    [ "$status" -eq 0 ]
    # check if pip has been installed
    run pip3 --version
    [ "$status" -eq 0 ]
    # check if pip has been globally disabled
    run pip3 install
    [ "$status" -ne 0 ]
    # check if pipenv has been installed
    LANG=C.UTF-8 pipenv --version >/dev/null 2>&1
    [[ $? -eq 0 ]]
    # check if virtualenv has been installed
    virtualenv --version >/dev/null 2>&1
    [[ $? -eq 0 ]]
    # check if virtualenvwrapper has been installed
    ~/.local/bin/virtualenvwrapper.sh --version >/dev/null 2>&1
    [[ $? -eq 0 ]]
}