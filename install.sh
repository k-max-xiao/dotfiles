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