#!/bin/bash
# This install script includes the function to install the zsh, Oh My Zsh and
# other necessary plugins, and set up zsh as the default shell with a customised
# setting (.zshrc).

#######################################
# Install zsh via apt
#
# Returns:
#   0 if succeeded to install or 1 otherwise
#######################################
function install_zsh {
    app="zsh"
    attempt_apt_install $app
    if [ $? -eq 0 ]; then
        print_success "$app has been successfully installed via apt"
        true
        return
    else
        print_error "$app has failed to install via apt"
        false
        return
    fi
}

#######################################
# Set zsh as the default shell
#######################################
function set_zsh_default {
    print_info "Ready to set zsh as the default shell"
    chsh -s `which zsh`
}

#######################################
# Install Oh My Zsh by downloading and running its installer script
#
# Installation will be skiped if it's already installed by check existence of:
# ~/.oh-my-zsh
#
# Returns:
#   0 if succeeded to install or 1 otherwise
#######################################
function install_oh_my_zsh {
    app="Oh My Zsh"
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_info "$app has already been installed, please delete $HOME/.oh-my-zsh if you want to reinstall"
        true
        return
    fi
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    if [ $? -eq 0 ]; then
        print_success "$app has been successfully installed via online install script"
        true
        return
    else
        print_error "$app has failed to install via online install script"
        false
        return
    fi
}

#######################################
# Install Powerlevel10k by git cloning it to the correct location.
#
# Installation will be skiped if it's already installed by check existence of:
# ~/.oh-my-zsh/custom/themes/powerlevel10k
#
# Returns:
#   0 if succeeded to install or 1 otherwise
#######################################
function install_powerlevel10k {
    app="Powerlevel10k"
    if [ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        print_info "$app has already been installed, please delete $HOME/.oh-my-zsh/custom/themes/powerlevel10k if you want to reinstall"
        true
        return
    fi
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    if [ $? -eq 0 ]; then
        echo ZSH_THEME=\"powerlevel10k/powerlevel10k\" >> $HOME/.zshrc
        print_success "$app has been successfully installed via git clone"
        true
        return
    else
        print_error "$app has failed to install via git clone"
        false
        return
    fi
}

#######################################
# Install zsh and its tools (Oh My Zsh and Powerlevel10k) in one go.
#
# Arguments:
#   set_default_shell: true (by default) if setting zsh as the default shell or
#     false otherwise
# Returns:
#   0 if succeeded to install or 1 otherwise
#######################################
function install_zsh_and_more {
    print_info "Before installing zsh and necessary relevant tools..."
    install_zsh
    if [ $? -ne 0 ]; then
        false
        return
    fi
    install_oh_my_zsh
    if [ $? -ne 0 ]; then
        false
        return
    fi
    install_powerlevel10k
    if [ $? -ne 0 ]; then
        false
        return
    fi
    print_success "Succeeded in installing zsh and necessary relevant tools!"
    if [ ${1:-true} = true ]; then
        set_zsh_default
        if [ $? -ne 0 ]; then
            false
            return
        fi
        print_success "Zsh has been set as the default shell"
    fi
    true
}