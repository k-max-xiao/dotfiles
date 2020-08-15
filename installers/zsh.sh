#!/bin/bash
# This install script includes the function to install the zsh, Oh My Zsh and
# other necessary plugins, and set up zsh as the default shell with a customised
# setting (.zshrc).

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

function set_zsh_default {
    print_info "Ready to set zsh as the default shell"
    chsh -s `which zsh`
}

function install_oh_my_zsh {
    app="Oh My Zsh"
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_info "$app has already been installed, please delete $HOME/.oh-my-zsh if you want to reinstall"
        true
        return
    fi
    # sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
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