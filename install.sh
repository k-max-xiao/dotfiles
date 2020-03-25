#!/bin/bash
# This install file will execute the following tasks:
# 1. clean and setup soft links for dotfiles

# to import the funtions of setting up soft links
source setup_symlinks.sh
# actually call and execute the task
dir=${1:=$HOME}
setup_symlinks $dir
