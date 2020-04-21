#!/bin/bash
# This install file will execute the following tasks:
# 1. clean and setup soft links for dotfiles

# to import the funtions of setting up soft links
source setup_symlinks.sh
# actually call and execute the task
dir=${1:-$HOME}
setup_symlinks $dir
# source the updated .bashrc file
source $dir/.bashrc

# to install the necessary softwares

# to install Python3, pip and virtual environment tools
source ./installers/python3.sh
install_latest_python3
# source the updated .bashrc file
source $dir/.bashrc

# to install all snap applications
source ./installers/snap.sh
# install snap (in case it's not installed, like in a docker)
sudo apt-get install -y snapd
# install all applications one by one
for app in "${SNAP_APPLICATIONS[@]}"; do
    run attempt_snap_install $app
    if [ $? -eq 0 ]; then
        print_success "$app has been successfully installed via snap"
    else
        print_error "$app has failed to install via snap"