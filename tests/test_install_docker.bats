#!/usr/bin/env bats
#
# Unit test script for Docker installer script
#
# This unit test script is using Bats as test framework
# Please refer to https://github.com/bats-core/bats-core for details

@test "test Docker installer script" {
    # skip this test if installer testing not activated
    if [ -z ${DOT_TEST_INSTALLERS:+x} ]; then
        skip "Please set DOT_TEST_INSTALLERS to activate installer testings"
    fi
    # ensure .bashrc is the updated one
    source ~/.bashrc
    # source the necessary util functions
    source ${BATS_TEST_DIRNAME}/../util_funcs.sh
    # source the installer script
    source ${BATS_TEST_DIRNAME}/../installers/docker.sh
    # add the apt repository
    run set_up_docker_apt_repository
    # check if the repository has been corrected added
    test $(grep -r --include '*.list' '^deb ' /etc/apt/sources.list* | \
        grep https://download.docker.com/linux/ubuntu | wc -l) -gt 0
    # install docker
    run install_docker_engine
    [ "$status" -eq 0 ]
    # check docker installation by getting its version
    run docker --version
    [ "$status" -eq 0 ]
    # only perform the following steps if not in a docker container
    if [ ! -f /.dockerenv ]; then
        # check if the docker has been installed by running hello world
        sudo docker run --rm hello-world
        # execute docker post-installation steps
        run execute_docker_post_installation
        # check if post installation are done by running hello world without sudo
        docker run --rm hello-world
    fi
}