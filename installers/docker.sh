#!/bin/bash
# This install script will:
# 1. set up docker's apt repository
# 2. install the latest docker engine
# 3. execute docker's post-installation steps (officially recommended)

#######################################
# Set up Docker's apt repository
#######################################
function set_up_docker_apt_repository {
    print_info "Ready to add Docker's apt repository"
    # update the apt package index
    sudo apt-get update >/dev/null
    # install necessary libraries
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common \
        lxc \
        iptables \
        >/dev/null
    # add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - >/dev/null
    # verify key's fingerprint
    test $(sudo apt-key fingerprint 0EBFCD88 | wc -l) -gt 0
    # set up Docker's stable repository
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable" \
        >/dev/null
    # print out message depending on result
    if [ $? -eq 0 ]; then
        print_success "Docker's apt repository has been successfully added"
        return 0
    else
        print_error "Failed to add Docker's apt repository"
        return 1
    fi
}

#######################################
# Install the latest docker engine
#######################################
function install_docker_engine {
    print_info "Ready to install docker"
    # update the apt package index
    sudo apt-get update >/dev/null
    # install docker
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io >/dev/null
    # print out message depending on result
    if [ $? -eq 0 ]; then
        print_success "Docker has been successfully installed"
        return 0
    else
        print_error "Failed to install Docker"
        return 1
    fi
}

#######################################
# Execute docker's post-installation steps as this is officially recommended
#######################################
function execute_docker_post_installation {
    print_info "Ready to execute Docker's post installation steps"
    # create the docker group
    if grep -q docker /etc/group; then
        print_info "docker group has been previously created"
    else
        print_info "creating docker group"
        sudo groupadd docker >/dev/null
    fi
    # add the user to the docker group
    if id -nG "$USER" | grep -qw docker; then
        print_info "$USER has been previously added into docker group"
    else
        print_info "adding $USER into group docker"
        sudo usermod -aG docker $USER >/dev/null
        # delete ~/.docker to avoid permission conflict if it's already created
        sudo rm -rf ~/.docker
        # configure docker to start on boot
        print_info "setting docker to start on boot"
        if [ -x "$(command -v systemctl)" ]; then
            sudo systemctl enable docker >/dev/null
        else
            sudo service docker start >/dev/null
        fi
    fi
    # print out message depending on result
    if [ $? -eq 0 ]; then
        print_info "Please restart or log out & in to enable docker service"
        print_success "Docker's post installation steps have been executed"
        return 0
    else
        print_error "Failed to execute Docker's post installation steps"
        return 1
    fi
}

#######################################
# Docker's installer function, which combines the three steps into one
#######################################
function install_docker_all_in_one {
    print_info "Starting to install Docker in 3 steps..."
    set_up_docker_apt_repository
    if [ $? -ne 0 ]; then
        print_error "Installing Docker failed at step 1: add apt repository"
        return 1
    fi
    install_docker_engine
    if [ $? -ne 0 ]; then
        print_error "Installing Docker failed at step 2: install libraries"
        return 1
    fi
    execute_docker_post_installation
    if [ $? -ne 0 ]; then
        print_error "Installing Docker failed at step 3: post installation"
        return 1
    fi
    print_success "Succeeded to install Docker!"
}