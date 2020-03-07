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
alias print_error="color_echo red"
alias print_info="color_echo cyan"
alias print_success="color_echo green"
alias print_question="color_echo yellow"

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
# Check if the last command line input is Y or y
#######################################
function is_answer_yes() {
    # $REPLY will fetch the last read input
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        return 0  # 0 is true (exit without error)
    else
        return 1  # 1 is false (having error)
    fi
}