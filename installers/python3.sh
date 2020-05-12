#!/bin/bash
# This install script will:
# 1. install the latest Python3
# 2. disable pip globally for both Python 2 and 3
# 3. set up virtualenv, virtualenvwrapper and pipenv

#######################################
# Install Python3 into the system. It will also install pip and the
# virtual environment tools like virtualenv, virtualenvwrapper and pipenv.
#
# Env:
#   DOT_PYTHON3_VER: the version of Python3 to install, defaults to Python 3.8.
#######################################
function install_latest_python3 {
    print_info "Ready to install Python${DOT_PYTHON3_VER:-3.8} and pip"
    sudo apt-get update
    sudo apt-get install -y python${DOT_PYTHON3_VER:-3.8} python3-pip
    print_info "Ready to disable pip globally for both python 2 and 3"
    if [ "$PIP_REQUIRE_VIRTUALENV" == true ]; then
        print_success "Pip was already disabled globally"
    else
        print_question "Pip was not yet disabled by dotfiles?"
        echo "" >> ~/.bashrc
        echo "###### disable 'pip' command if not in a virtual env" >> ~/.bashrc
        echo "export PIP_REQUIRE_VIRTUALENV=true" >> ~/.bashrc
        echo ""  >> ~/.bashrc
        print_success "Pip has been disabled globally"
    fi
    print_info "Ready to install pipenv"
    sudo -H pip3 install -U pipenv
    print_info "Ready to install virtualenv and virtualenvwrapper"
    pip3 install virtualenv virtualenvwrapper
    if [ -n ${WORKON_HOME:+x} ]; then
        print_success "Virtualenvwrapper workon home was already defined"
    else
        print_question "Virtualenvwrapper workon home was not yet defined?"
        echo "" >> ~/.bashrc
        echo "###### set virtualenvwrapper's WORKON_HOME" >> ~/.bashrc
        echo "export WORKON_HOME=~/Workspace/PyEnvs" >> ~/.bashrc
        echo ""  >> ~/.bashrc
        print_success "Virtualenvwrapper workon home has been defined"
    fi
    print_success "Python${DOT_PYTHON3_VER:-3.8} and pip have been installed"
    return 0
}