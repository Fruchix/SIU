#!/bin/bash

source env_siu.sh
source setup_siu.sh

tools=(zsh omz bat pure star fzf)

function _siu::prepare_install()
{
    mkdir archives

    for tool in "${tools[@]}"; do
        source "tools/install_${tool}.sh"
        "_siu::prepare_install::${tool}"
    done
}

function _siu::install()
{
    _siu::init::siu

    for tool in "${tools[@]}"; do
        source "tools/install_${tool}.sh"
        "_siu::install::${tool}"
    done
}

export OFFLINE_INSTALL=no

_siu::prepare_install
_siu::install
