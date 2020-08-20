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
		if sudo apt-get install -y $@; then
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
    "winehq-devel"
    "winetricks"
)

#######################################
# The array of apt software installation options.
# The size of this array should match the size of APT_APPLICATIONS.
# Most of the values are empty (no special installation option).
#######################################
APT_OPTIONS=(
    ""
    ""
    ""
    ""
    ""
    ""
    "--install-recommends"
    ""
)

#######################################
# Check if the repository has already been added into the source list
#
# Arguments:
#   repo: the repository to check
# Returns:
#   0 if succeeded to install or 1 otherwise
#######################################
function repository_already_added {
    if [[ $(find /etc/apt/ -name "*.list" | xargs cat | grep "^[[:space:]]*deb" | grep -v "deb-src" | grep "$1" | wc -l) -gt 0 ]]; then
        true
        return
    else
        false
        return
    fi
}

#######################################
# Necessary preparations, like adding repository to source,
# for installing Wine.
#######################################
function pre_wine_apt {
    # enable 32-bit support
    sudo dpkg --add-architecture i386
    # add wine's repository to the source
    if repository_already_added "deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main"; then
        print_info "Wine's repository has already been added"
    else
        print_info "Adding Wine's repository into source"
        wget -q -O - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -
        sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'
    fi
    # add OpenSUSE Wine repository to the source for dependency libraries
    if repository_already_added "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04 ./"; then
        print_info "OpenSUSE Wine repository has already been added"
    else
        print_info "Adding OpenSUSE Wine repository into source for Wine's dependencies"
        wget -q -O - https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/Release.key | sudo apt-key add -
        echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04 ./" | sudo tee /etc/apt/sources.list.d/wine-obs.list
    fi
}

#######################################
# Necessary preparations, like adding repository to source,
# for installing Chrome.
#######################################
function pre_chrome_apt {
    # add chrome's repository to the source
    if repository_already_added "deb https://dl.google.com/linux/chrome/deb/ stable main"; then
        print_info "Google Chrome's repository has already been added"
    else
        print_info "Adding Google Chrome's repository into source"
        wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
        sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
    fi
}

#######################################
# Necessary preparations, like adding repository to source,
# before the all-in-one installation.
#######################################
function pre_install_apt {
    print_info "Starting preparations before apt installations..."
    pre_chrome_apt
    pre_wine_apt
    # update the apt cache
    print_info "Updating apt cache"
    sudo apt-get update >/dev/null
    print_info "Finished preparations for apt installation."
}

#######################################
# Install all apt software in one go.
#######################################
function install_apt_all_in_one {
    pre_install_apt
    for idx in "${!APT_APPLICATIONS[@]}"; do
        app=${APT_APPLICATIONS[$idx]}
        option=${APT_OPTIONS[$idx]}
        attempt_apt_install $app $option
        if [ $? -eq 0 ]; then
            print_success "$app has been successfully installed via apt"
        else
            print_error "$app has failed to install via apt"
        fi
    done
}