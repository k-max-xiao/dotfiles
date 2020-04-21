#!/bin/bash
# This install script includes the function to install software of a given name
# via apt.

#######################################
# Check if a software has been installed via apt or dpkg.
#
# Arguments:
#   name: the name of the software to check
# Returns:
#   0 if already installed or 1 otherwise
#######################################
function is_apt_installed {
    if [ -n ${1:+x} ]; then
        # there should be one parameter for the name of the software
        if [[ `dpkg -l | grep ^ii | awk '{print $2}' | grep ^$1$ | wc -l` -gt 0 ]]; then
            # case that the software is already installed
            print_info "$1 has ALREADY been installed via apt."
            return
        else
            # case that the software is not installed
            print_info "$1 has NOT been installed via apt."
        fi
    fi
    false
}

#######################################
# Attempt to install a software via apt.
#
# Arguments:
#   name: the name of the software to install
# Returns:
#   0 if succeeded to install or 1 otherwise
#######################################
function attempt_apt_install {
    # check if a software name has been given
    if [ -z ${1:+x} ]; then
        print_error "Must provide the software name to install!"
        false
        return
    fi
    # install the software if it has not been installed
    if ! is_apt_installed "$1"; then
        print_info "Ready to install $1 via apt"
		if sudo apt-get install -y $1; then
            # installation succeeded
			print_success "$1 has been successfully installed via apt!"
            return
		else
            # installation failed
			>&2 print_error "$1 installation via apt has failed..."
			false
			return
		fi
	fi
}

#######################################
# The array of apt software to install.
#######################################
APT_APPLICATIONS=(
    "git"
    "vim"
    "snapd"
    "unar"
    "terminator"
)