#!/bin/bash
# This install script includes the function to install the appropriate version
# of the nvidia driver via the new software ubuntu-drivers

function install_nvidia_driver {
    print_info "Ready to install the appropriate nvidia driver"
    sudo ubuntu-drivers autoinstall
    if [ $? -eq 0 ]; then
        print_success "The nvidia driver has been installed via ubuntu-drivers"
    else
        print_error "The nvidia driver has failed to install via ubuntu-drivers"
    fi
}