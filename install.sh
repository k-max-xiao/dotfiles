#!/bin/bash
# This install file will execute the following tasks:
# 1. back up the original dotfiles files which will be impacted
# 2. create soft links of the custom dotfiles in home directory
# 3. source these soft links in the relevant

# to import the common functions before execute tasks
source ./basics/.functions

# get the root path to the folder of this file
export DOTFILES_ROOT=$(realpath `dirname $0`)
color_echo green "Dotfiles root directory identified: $DOTFILES_ROOT"
