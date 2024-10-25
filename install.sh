#!/bin/bash

source env_siu.sh
source setup_siu.sh

tools=(zsh omz bat pure star fzf)

prepare_install()
{
    mkdir archives

    for tool in "${tools[@]}"; do
        source "tools/install_${tool}.sh"
        "prepare_install::${tool}"
    done
}

install()
{
    init::siu

    for tool in "${tools[@]}"; do
        source "tools/install_${tool}.sh"
        "install::${tool}"
    done
}

export OFFLINE_INSTALL=yes

prepare_install
install
