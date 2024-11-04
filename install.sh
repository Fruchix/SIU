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
    _siu::log::info "Starting preparing SIU install"
    mkdir archives

    for tool in "${tools[@]}"; do
        _siu::log::info "Starting preparing ${tool} install"
        . "tools/install_${tool}.sh"
        "_siu::prepare_install::${tool}"
        _siu::log::info "Finished preparing ${tool} install"
    done
    _siu::log::info "Finished preparing SIU install"
}

function _siu::install()
{
    _siu::log::info "Starting SIU install"
    _siu::init::siu

    for tool in "${tools[@]}"; do
        _siu::log::info "Starting ${tool} install"
        . "tools/install_${tool}.sh"
        "_siu::install::${tool}"
        _siu::log::info "Finished ${tool} install"
    done
    _siu::log::info "Finished SIU install"
}

export OFFLINE_INSTALL=no

_siu::log::info "Starting installation script"
_siu::prepare_install
_siu::install
_siu::log::info "Finished installation script"
