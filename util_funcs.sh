#!/bin/bash

# This script provides the utility functions to facilitate the installer
# scripts of this dotfiles project

######### Utils Functions #########

#######################################
# Define shortcuts to printing style control commands.
#
# This function will define the shortcuts in global scope, so please use
# the following unset_styles() function to unset when no longer needed.
#######################################
function define_styles() {
    # define the font colors
    black=${black:-$(tput setaf 0)}
    red=${red:-$(tput setaf 1)}
    green=${green:-$(tput setaf 2)}
    yellow=${yellow:-$(tput setaf 3)}
    blue=${blue:-$(tput setaf 4)}
    magenta=${magenta:-$(tput setaf 5)}
    cyan=${cyan:-$(tput setaf 6)}
    white=${white:-$(tput setaf 7)}
    # define the font styles
    bold=${bold:-$(tput bold)}
    underline=${underline:-$(tput smul)}
    blink=${blink:-$(tput blink)}
    rev=${rev:-$(tput rev)}
    invis=${invis:-$(tput invis)}
    # define reset to normal
    reset=${reset:-$(tput sgr 0)}
}

#######################################
# Unset the previous defined printing style control commands from global scope.
#######################################
function unset_styles() {
    # unset defined font colors
    unset black
    unset red
    unset green
    unset yellow
    unset blue
    unset magenta
    unset cyan
    unset white
    # unset defined font styles
    unset bold
    unset underline
    unset blink
    unset rev
    unset invis
    # unset defined reset to normal
    unset reset
}

#######################################
# Giving colors to echo
# Arguments:
#   color: the color of the line to print
#   text...: the content to print
# Outputs:
#   Output the texts in the given color to screen
#######################################
function color_echo() {
    # create an associative array to store the available colors
    # this can avoid using `eval` for recursive substitution
    typeset -A colors
    local colors=(
        [black]=${black:-$(tput setaf 0)}
        [red]=${red:-$(tput setaf 1)}
        [green]=${green:-$(tput setaf 2)}
        [yellow]=${yellow:-$(tput setaf 3)}
        [blue]=${blue:-$(tput setaf 4)}
        [magenta]=${magenta:-$(tput setaf 5)}
        [cyan]=${cyan:-$(tput setaf 6)}
        [white]=${white:-$(tput setaf 7)}
        [reset]=${reset:-$(tput sgr 0)}
    )
    # set the color at the start and reset to non color at the end
    echo "${colors[$1]}${@:2}${colors[reset]}"
}

#######################################
# Print the error text in red with cross mark in front
# Arguments:
#   text...: the error text to output on screen
# Outputs:
#   Output the error text in red with cross mark in front on screen
#######################################
function print_error {
    color_echo red [✖] ${@}
}

#######################################
# Print the information text in cyan with exclamation mark in front
# Arguments:
#   text...: the information text to output on screen
# Outputs:
#   Output the information text in cyan with exclamation mark in front on screen
#######################################
function print_info {
    color_echo cyan [!] ${@}
}

#######################################
# Print the success text in green with check mark in front
# Arguments:
#   text...: the success text to output on screen
# Outputs:
#   Output the success text in green with check mark in front on screen
#######################################
function print_success {
    color_echo green [✔] ${@}
}

#######################################
# Print the question text in yellow with question mark in front
# Arguments:
#   text...: the question text to output on screen
# Outputs:
#   Output the question text in yellow with question mark in front on screen
#######################################
function print_question {
    color_echo yellow [?] ${@}
}

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
        # return true if result if good
        return 0
    else
        print_error "${@:2}"
        # return false if not good
        return 1
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
    # print error and exit if no argument is given
    if [[ $# < 1 ]]; then
        print_error "USAGE: execute command (message)"
        return 1
    fi
    # print starting task message
    print_info "Now starting ${2:-1}"
    if [ "$DOTFILES_DEBUG" = true ]; then
        # execute the command with normal output if DEBUG on
        $1
    else
        # execute the command with muted output if DEBUG off
        $1 &>/dev/null
    fi
    # print an informtaion as success or failure according to result status
    # if a second argument is provided then print it, otherwise the original
    # command
    print_result $? "${2:-1}"
    return $?
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
                return 1
            else
                # if the given path exists and is a directory then print
                # success without mkdir
                print_success "$1 already created"
                return 0
            fi
        else
            # if the given path does not exist then create it and print result
            execute "mkdir -p $1" "$1"
        fi
    fi
}
