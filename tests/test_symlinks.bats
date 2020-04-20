#!/usr/bin/env bats
#
# Unit test script for dotfile symlink creation feature
#
# This unit test script is using Bats as test framework
# Please refer to https://github.com/bats-core/bats-core for details

function setup {
    # remove previous test files
    if [[ -d ${BATS_TEST_DIRNAME}/symlinks ]]; then
        rm -r ${BATS_TEST_DIRNAME}/symlinks
    fi
    # initiate directory for test intermediate files
    mkdir ${BATS_TEST_DIRNAME}/symlinks
    touch ${BATS_TEST_DIRNAME}/symlinks/.bashrc
}

function teardown {
    # clean up all test intermediate files
    if [[ -d ${BATS_TEST_DIRNAME}/symlinks ]]; then
        rm -r ${BATS_TEST_DIRNAME}/symlinks
    fi
}

# function check_result {
#     local bashrc_path="${1}/.bashrc"
#     for f in ${BATS_TEST_DIRNAME}/../basics/.[^.]*; do
#         local file_name=`basename ${f}`
#         [ -f ${file_name} ]
#         [[ `grep -Fx "source *${file_name} # Custom Dotfiles" ${bashrc_path} | wc -l` -gt 0 ]]
#         echo "${file_name} has been checked"
#     done
#     return 1
# }

@test "test function setup_symlinks" {
    # load the setup_symlinks script
    source ${BATS_TEST_DIRNAME}/../setup_symlinks.sh
    # run the setup_symlinks function with temporary test folder
    run setup_symlinks ${BATS_TEST_DIRNAME}/symlinks/
    # check the running is successful
    [ "$status" -eq 0 ]
    # start to verify the results
    local bashrc_path="${BATS_TEST_DIRNAME}/symlinks/.bashrc"
    # check over all dotfiles
    for f in ${BATS_TEST_DIRNAME}/../basics/.[^.]*; do
        # file name of the dotfile
        local file_name=$(basename ${f})
        echo "Checking ${BATS_TEST_DIRNAME}/symlinks/${file_name}"
        # check the soft link exists at the expected location
        [ -f ${BATS_TEST_DIRNAME}/symlinks/${file_name} ]
        # check the soft link has been sourced in .bashrc
        [[ `grep -Ex "(# )?source [/_[:alnum:]]*/${file_name} # Custom Dotfiles" ${bashrc_path} | wc -l` -gt 0 ]]
    done
}