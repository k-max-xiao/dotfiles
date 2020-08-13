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
    "google-chrome-stable"
)

#######################################
# Necessary preparations, like adding repository to source,
# before the all-in-one installation.
#######################################
function pre_install_apt {
    print_info "Starting preparations before apt installations..."
    # add chrome's repository to the source
    print_info "Adding Google Chrome's repository into source"
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
    sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
    # update the apt cache
    print_info "Updating apt cache"
    sudo apt-get update
    print_info "Finished preparations for apt installation."
}

#######################################
# Install all apt software in one go.
#######################################
function install_apt_all_in_one {
    pre_install_apt
    for app in "${APT_APPLICATIONS[@]}"; do
        attempt_apt_install $app
        if [ $? -eq 0 ]; then
            print_success "$app has been successfully installed via apt"
        else
            print_error "$app has failed to install via apt"
        fi
    done
}