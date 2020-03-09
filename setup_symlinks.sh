#!/bin/bash

# This script symlinks all the dotfiles and dot folders in ./basics to ~/
# TODO: It will also symlinks ./bin to ~/bin for easy updating

# This script is idempotent, so you can safely run it for multiple times and
# it has the same result as only running it for once.

# This script provides interactive prompts to ask your decision for uncertain
# situation.

# This script is heavily inspired by alrra's nice work here:
# https://raw.githubusercontent.com/alrra/dotfiles/master/os/create_symbolic_links.sh

######### Utils Functions #########

#######################################
# using alias instead of functions to define the simple printing commands
#######################################
alias print_error="color_echo red [✖]"
alias print_info="color_echo cyan [!]"
alias print_success="color_echo green [✔]"
alias print_question="color_echo yellow [?]"

#######################################
# Print the result text in correspondent color depending on the result
# Arguments:
#   result: normally the execution return, 0 for all good and other for error
#   text...: the result texts to output on screen
# Outputs:
#   Output the result texts on screen with appropriate colors
#######################################
function print_result() {
    # check if result is good (equals 0)
    if [ $1 -eq 0 ]; then
        print_success "${@:2}"
    else
        print_error "${@:2}"
    fi
}

#######################################
# Prompt a question on screen to user and read user's answer
# Arguments:
#   question: the question to ask
# Outputs:
#   Output the question in red on screen and read user's answer
#######################################
function ask() {
    # print
    print_question "$1"
    read
    # the result of read can be fetched by $REPLY
}

#######################################
# Prompt some information on screen then ask for user's confirmation (Y/N)
# Arguments:
#   infos: the informtaion to print
# Outputs:
#   Output the question in red on screen and read user's answer
#######################################
function ask_for_confirmation() {
    # print out the question
    print_question "$@ (y/n) "
    # just read one character
    # the result will be stored in $REPLY
    read -n 1
    # finish the input line
    printf "\n"
}

#######################################
# Check if the last command line input is Y or y
# Outputs:
#   0 (true) if exists or 1 (false) otherwise
#######################################
function answer_is_yes() {
    # $REPLY will fetch the last read input
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        return 0 # 0 is true (exit without error)
    else
        return 1 # 1 is false (having error)
    fi
}

#######################################
# Ask for sudo credentials and keep-alive sudo status until task finishes.
# Good for long-running script that need sudo internally but shouldn't be run
# with sudo.
# Original idea from: https://gist.github.com/cowboy/3118588
#######################################
function ask_and_update_sudo() {
    # Ask user for sudo credentials and update it in cache.
    # The cache is valid for 15 minutes by default, so we need to keep updating
    # it continuously until the task is finished
    sudo -v
    # to keep updating the sudo status
    while true; do
        # update sudo status in --non-interactive way
        sudo -n true
        # update the status every 60 seconds
        sleep 60
        # $$ is the PID of the parent process. 'kill -0 PID' exits with an exit
        # code of 0 if the PID is of a running process, otherwise exits with an
        # exit code of 1. So basically, 'kill -0 "$$" || exit' aborts the while
        # loop child process as soon as the parent process is no longer
        # running.
        #
        # kill -0 will send signal 0 to the given PID and just checks if the
        # process is running and you have the permission to send a signal to it
        # This signal will not terminate the process
        kill -0 "$$" || exit
        # &>/dev/null is an abbreviation for >/dev/null 2>&1, to silence all output
    done &>/dev/null &
}

#######################################
# Check if a command exists or not
# Arguments:
#   command: the command to check
# Outputs:
#   0 (true) if exists or 1 (false) otherwise
#######################################
function command_exist() {
    # -v option makes `command` to return the name of the command in query if
    # it exists, then -x tests if it is executable by user
    if [ -x "$(command -v ${1})" ]; then
        return 0
    else
        return 1
    fi
}

#######################################
# Execute a command and print out result
# Arguments:
#   command: the command to execute
#   message: optional, the message to print out after execution
# Outputs:
#   the given message or the original command if not given
#######################################
function execute() {
    # execute the command then redirect STDOUT and STDERR to be discarded
    $1 &>/dev/null
    # print an informtaion as success or failure according to result status
    # if a second argument is provided then print it, otherwise the original
    # command
    print_result $? "${2:-1}"
}

#######################################
# Check if inside a git repository
#######################################
function is_git_repository() {
    # git rev-parse --git-dir will return with an exit code of 0 if inside a
    # git repository, no matter the top level or not.
    if [ "$(
        git rev-parse --git-dir &>/dev/null
        print $?
    )" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

#######################################
# Safely create a directory and print out result.
# Arguments:
#   dir: directory to create, using 'mkdir -p' behind the scene
# Outputs:
#   Success or failure message
#######################################
function safe_mkdir() {
    if [ -n "$1" ]; then
        # only proceed if an argument is given
        if [ -e "$1" ]; then
            # if the given path exists
            if [ ! -d "$1" ]; then
                # if the given path exists and is a file then print error
                print_error "$1 - a file with the same name already exists!"
            else
                # if the given path exists and is a directory then print
                # success without mkdir
                print_success "$1"
            fi
        else
            # if the given path does not exist then create it and print result
            execute "mkdir -p $1" "$1"
        fi
    fi
}

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

# find all dotfiles to symlink and store them in an associative array
declare -a FILES_TO_SYMLINK=$(find $_SCRIPT_PATH/basics/ -type f)

# clear up viriable
unset _SCRIPT_PATH

#######################################
# Main program to symlink the dotfiles
#
# This should be tested by calling with a temperory folder as argument
#######################################
function setup_symlinks() {
    # local variables so no need to unset
    local sourceFile=""
    local targetFile=""
    local message=""
    local targetDir=""
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
    # symlink the dotfiles one by one
    for sourceFile in ${FILES_TO_SYMLINK[@]}; do
        # construct the target file path
        targetFile="$targetDir/$(basename $sourceFile)"
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
