#!/bin/bash
# This install file will execute the following tasks:
# 1. clean and setup soft links for dotfiles

###### to import the funtions of setting up soft links
source setup_symlinks.sh
# actually call and execute the task
dir=${1:-$HOME}
setup_symlinks $dir
# source the updated .bashrc file
source $dir/.bashrc

###### to install the necessary softwares

### to install Python3, pip and virtual environment tools
source ./installers/python3.sh
install_latest_python3
# source the updated .bashrc file
source $dir/.bashrc

### to install all apt applications
source ./installers/apt.sh
# install all applications one by one
for app in "${APT_APPLICATIONS[@]}"; do
    attempt_apt_install $app
    if [ $? -eq 0 ]; then
        print_success "$app has been successfully installed via apt"
    else
        print_error "$app has failed to install via apt"
    fi
done

### to install all snap applications
# this should be placed after apt installations as snapd will be installed via 
# apt
source ./installers/snap.sh
# install all applications one by one
for app in "${SNAP_APPLICATIONS[@]}"; do
    attempt_snap_install $app
    if [ $? -eq 0 ]; then
        print_success "$app has been successfully installed via snap"
    else
        print_error "$app has failed to install via snap"
    fi
done