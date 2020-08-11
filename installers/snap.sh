#!/bin/bash
# This install script includes the function to install software of a given name
# via snap.

#######################################
# Check if a software has been installed via snap.
#
# Arguments:
#   name: the name of the software to check
# Returns:
#   0 if already installed or 1 otherwise
#######################################
function is_snap_installed {
    if [ -n ${1:+x} ]; then
        # there should be one parameter for the name of the software
        if [[ `snap list | grep $1 | wc -l` -gt 0 ]]; then
            # case that the software is already installed
            print_info "$1 has ALREADY been installed via snap."
            return
        else
            # case that the software is not installed
            print_info "$1 has NOT been installed via snap."
        fi
    fi
    false
}

#######################################
# Attempt to install a software via snap.
#
# Arguments:
#   name: the name of the software to install
# Returns:
#   0 if succeeded to install or 1 otherwise
#######################################
function attempt_snap_install {
    # check if a software name has been given
    if [ -z ${1:+x} ]; then
        print_error "Must provide the software name to install!"
        false
        return
    fi
    # install the software if it has not been installed
    if ! is_snap_installed "$1"; then
        print_info "Ready to install $1 via snap"
		if sudo snap install $@; then
            # installation succeeded
			print_success "$1 has been successfully installed via snap!"
            return
		else
            # installation failed
			>&2 print_error "$1 installation via snap has failed..."
			false
			return
		fi
	fi
}

#######################################
# The array of snap software to install.
#######################################
SNAP_APPLICATIONS=(
    "cmake --classic"
	# "pycharm-community --classic"
	"slack --classic"
	"sublime-text --classic"
	"gitkraken --classic"
	"code --classic"
	"postman"
	"ffmpeg"
	"skype --classic"
	"clementine"
	"wonderwall"
	"easy-disk-cleaner"
)

#######################################
# Install all snap software in one go.
#######################################
function install_snap_all_in_one {
    for app in "${SNAP_APPLICATIONS[@]}"; do
        attempt_snap_install $app
        if [ $? -eq 0 ]; then
            print_success "$app has been successfully installed via snap"
        else
            print_error "$app has failed to install via snap"
        fi
    done
}
