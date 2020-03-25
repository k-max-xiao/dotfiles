#!/bin/bash

# This script symlinks all the dotfiles and dot folders in ./basics to ~/
# TODO: It will also symlinks ./bin to ~/bin for easy updating

# This script is idempotent, so you can safely run it for multiple times and
# it has the same result as only running it for once.

# This script provides interactive prompts to ask your decision for uncertain
# situation.

# This script is heavily inspired by alrra's nice work here:
# https://raw.githubusercontent.com/alrra/dotfiles/master/os/create_symbolic_links.sh

# Get the full path of the current script, no matter whre it is called from.
#
# This feature is script dependent. It will fail to work if it is defined in
# another script and called here.
#
# ${BASH_SOURCE[0]} is a bash-specific variable which contains the (potentially
# relative) path of the containing script in all invocation scenarios, notably
# also when the script is sourced, which is not true for $0.
#
# >/dev/null will redirect all STDOUT to the /dev/null black hole where all
# messages written to it will be discarded.
#
# 2>&1 will redirect all the STDERR to STDOUT. 2 is the handle for STDERR and
# 1 is the handle for STDOUT. & signals that 1 is a hanlder, otherwise 1 will
# be treated as a file name.
#
# In total, >/dev/null 2>&1 means to discard all standard output and error,
# resulting in no output to the screen.
#
# The nested double quotes are valid because once inside $( ... ), quoting
# starts all over from scratch. In other words, "..." and $( ... ) can nest
# within each other.
_SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

source $_SCRIPT_PATH/util_funcs.sh

# find all dotfiles to symlink and store them in an array
declare -a FILES_TO_SYMLINK=$(find $_SCRIPT_PATH/basics/ -type f)

# an array to store all the full paths of the soft links to create
declare -a LINK_PATHS

# flag for debug mode
# in debug mode, all sub level details will be printed on screen
DOTFILES_DEBUG=false

#######################################
# Create the soft links of the dotfiles in the given directory
# Arguments:
#   dir: The directory to create the soft links
#######################################
function create_symlinks() {
    # local variables so no need to unset
    local sourceFile=""
    local targetFile=""
    local message=""
    local targetDir="$1"
    # initialise the full paths array to empty array before creating new links
    LINK_PATHS=()
    # symlink the dotfiles one by one
    for sourceFile in ${FILES_TO_SYMLINK[@]}; do
        # construct the target file path
        targetFile="$targetDir/$(basename $sourceFile)"
        LINK_PATHS+=($targetFile)
        # construct the message to print
        message="$targetFile -> $sourceFile"
        if [ -e "$targetFile" ]; then
            # if the target file exists
            if [ "$(readlink "$targetFile")" != "$sourceFile" ]; then
                # if the target file is not linked to the source file
                # then ask user if want to override the link
                ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
                if answer_is_yes; then
                    # override the existing target file if permitted
                    # remove the existing target file at first
                    rm -rf "$targetFile"
                    # force (-f) to create a soft/symbolic (-s) link by 'ln'
                    execute "ln -fs $sourceFile $targetFile" "$message"
                else
                    # print error message if not permitted
                    print_error "$message"
                fi
            else
                # print success message if target symbolic link already exists
                print_success "$message"
            fi
        else
            # the target file does not exist yet
            # force (-f) to create a soft/symbolic (-s) link by 'ln'
            execute "ln -fs $sourceFile $targetFile" "$message"
        fi
    done
    return
}

#######################################
# Safely add the sourcing commends for the soft links in .bashrc
# Arguments:
#   dir: The directory of .bashrc
#######################################
function safe_update_bashrc {
    # local variables so no need to unset
    local link
    local line
    if [ ! -f $1/.bashrc ]; then
        # return false if .bashrc does not exist or is not a file
        print_error "$1/.bashrc doesn't exist!"
        return 1
    fi
    for link in ${LINK_PATHS[@]}; do
        # iterate over all dotfiles
        # the actual line to add into .bashrc
        line="source $link # Custom Dotfiles"
        if [[ `grep -Fx "$line" $1/.bashrc | wc -l` -gt 0 ]]; then
            # if the target line already exists, print information
            print_info "$link has already been sourced, safely skip it"
        elif [[ `grep -x "^# *${line}$" $1/.bashrc | wc -l` -gt 0 ]]; then
            # if the target line has been commented, print question
            print_question "$link has been commented in $1/.bashrc, please check manually"
        else
            # if the target line is not in .bashrc
            if echo $line >> $1/.bashrc; then
                print_success "$link has been successfully sourced in $1/.bashrc"
            else
                print_error "Failed to source $link into $1/.bashrc"
            fi
        fi
    done
}

#######################################
# Back up the original dotfiles
#######################################
function backup_original_dotfiles {
    # the folder to store the original dotfiles
    local DOTFILES_BACKUP_DIR=$_SCRIPT_PATH/backup
    # the array of dotfiles to backup
    local DOTFILES_TO_BACKUP=(
        .bashrc
        .profile
    )
    if (execute "safe_mkdir $DOTFILES_BACKUP_DIR" "Create backup folder"); then
        # if the backup folder exists or can be created
        print_success "$DOTFILES_BACKUP_DIR created"
        local file
        for file in ${DOTFILES_TO_BACKUP[@]}; do
            # perform backup for each target original dotfile
            execute "cp -Rp $HOME/$file $DOTFILES_BACKUP_DIR/$file" "Backup $file"
        done
    fi
}

#######################################
# The main program to setup the symlink task
# Arguments:
#   dir (optional): the target directory of .bashrc, also the directory to 
#       create the soft links; it will be $HOME by default
#######################################
function setup_symlinks {
    local targetDir
    # set target directory
    if [ "$#" -gt 0 ]; then
        # if at least one argument is given
        if [ -d "$1" ]; then
            # if the first argument is a directory, then it's the target folder
            targetDir="$1"
        else
            # if the first argument is not a directory, then print error & exit
            print_error "$1 is not a directory!"
            return
        fi
    else
        # if no argument is given, then use home folder as the target folder
        targetDir="$HOME"
    fi
    # firstly backup the original dotfiles
    execute backup_original_dotfiles "Backup original dotfiles"
    # secondly create soft links in the target directory
    execute "create_symlinks $targetDir" "Soft link dotfiles to home folder"
    # lastly safely update .bashrc to source the soft links
    execute "safe_update_bashrc $targetDir" "Safely update symlinks into bashrc"
}
