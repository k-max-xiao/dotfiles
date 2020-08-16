#!/bin/bash
# This install script will:
# 1. install the latest Python3
# 2. disable pip globally for both Python 2 and 3
# 3. set up virtualenv, virtualenvwrapper and pipenv

#######################################
# Install pyenv and its tools via its installer script
#
# Returns:
#   0 if succeeded to install or 1 otherwise
#######################################
function install_pyenv {
    # install pyenv using its auto-installer
    print_info "Start to install pyenv and its tools"
    if [ -d "$HOME/.pyenv" ]; then
        print_info "Pyenv has already been installed, will skip"
    else
        curl https://pyenv.run | bash
        if [ $? -eq 0 ]; then
            print_success "Pyenv has been successfully installed via its installer script"
        else
            print_error "Pyenv has failed to install via its installer script"
            false
            return
        fi
    fi
    if [ -z ${PYENV_ROOT+x} ]; then
        print_success "\$PYENV_ROOT has already been set"
    else
        print_question "\$PYENV_ROOT has not beend set yet?"
        echo "" >> ~/.bashrc
        echo "###### setting path and root for pyenv" >> ~/.bashrc
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
        echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\n  eval "$(pyenv virtualenv-init -)"\nfi' >> ~/.bashrc
        echo ""  >> ~/.bashrc
        print_success "\$PYENV_ROOT has been set"
    fi
    true
    return
}

#######################################
# Install Python3 into the system. It will also install pip and the
# virtual environment tools like virtualenv, virtualenvwrapper and pipenv.
#
# Env:
#   DOT_PYTHON3_VER: the version of Python3 to install, defaults to Python 3.8.
#######################################
function install_latest_python3 {
    # install python3 and its pip
    print_info "Ready to install Python${DOT_PYTHON3_VER:-3.8} and pip"
    sudo apt-get update
    sudo apt-get install -y python${DOT_PYTHON3_VER:-3.8} python3-pip
    # disable global pip
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
    # install pipenv
    print_info "Ready to install pipenv"
    sudo -H pip3 install -U pipenv
    # install virtualenv and virtualenvwrapper
    print_info "Ready to install virtualenv and virtualenvwrapper"
    PIP_REQUIRE_VIRTUALENV="" pip3 install virtualenv virtualenvwrapper
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
    # install pyenv
    print_info "Ready to install pyenv and its tools"
    install_pyenv
    if [ $? -eq 0 ]; then
        print_success "pyenv has been successfully installed"
    else
        print_error "pyenv has failed to install"
    fi
    return 0
}