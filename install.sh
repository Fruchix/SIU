#!/bin/bash

# source all required environment and utils files
. env_siu.sh
. setup_siu.sh
for u in utils/*; do
    . "${u}"
done

tools=(zsh omz bat pure star fzf)

function _siu::prepare_install()
{
    mkdir archives
    for tool in "${tools[@]}"; do
        . "tools/install_${tool}.sh"
        "_siu::prepare_install::${tool}"
    done
}

function _siu::install()
{
    _siu::init::siu
    for tool in "${tools[@]}"; do
        . "tools/install_${tool}.sh"
        "_siu::install::${tool}"
    done
}

export OFFLINE_INSTALL=no

_siu::prepare_install
_siu::install
