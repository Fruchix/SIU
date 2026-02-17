#!/usr/bin/env bash

function _siu::setup::init_siu_dirs()
{
    _siu::log::info "Initializing SIU directories"
    mkdir -p "${SIU_DIR}"
    mkdir -p "${SIU_BIN_DIR}"

    # dependencies
    mkdir -p "${SIU_DEPS_DIR}"
    # will be useful if stow is used to install at least ncurses
    # mkdir -p "${SIU_DEPS_DIR}/bin"
    # mkdir -p "${SIU_DEPS_DIR}/include"
    # mkdir -p "${SIU_DEPS_DIR}/lib"
    # mkdir -p "${SIU_DEPS_DIR}/share"

    # manpages
    mkdir -p "${SIU_MAN_DIR}"
    mkdir -p "${SIU_MAN_DIR}/man1"

    mkdir -p "${SIU_PROFILE_DIR}"
    mkdir -p "${SIU_SOURCES_DIR}"
    mkdir -p "${SIU_UTILITIES_DIR}"
    _siu::log::info "Finished SIU directories initialization"
}

function _siu::setup::init_siu_rc_files()
{
    _siu::log::info "Creating SIU rc files"
    touch "${SIU_BASHRC}"
    touch "${SIU_ZSHRC}"
    touch "${SIU_EXPORTS}"
    _siu::log::info "Finished creating SIU rc files"
}

function _siu::setup::init_siu_exports()
{
    _siu::log::info "Initializing ${SIU_EXPORTS}"
    echo "export SIU_DIR=${SIU_DIR}" >> "${SIU_EXPORTS}"
    cat << "EOF" >> "${SIU_EXPORTS}"
. ${SIU_DIR}/src/env_siu.sh

export PATH="${SIU_DIR}/bin:${SIU_DEPS_DIR}/bin:$PATH"
EOF
    . "${SIU_EXPORTS}"
    _siu::log::info "Finished ${SIU_EXPORTS} initialization"
}

function _siu::setup::init_siu_bashrc()
{
    _siu::log::info "Initializing ${SIU_BASHRC}"
    echo ". $SIU_EXPORTS" > "${SIU_BASHRC}"
    _siu::log::info "Finished ${SIU_BASHRC} initialization"
}

function _siu::setup::init_siu_zshrc()
{
    _siu::log::info "Initializing ${SIU_ZSHRC}"
    echo ". $SIU_EXPORTS" > "${SIU_ZSHRC}"

    cat << EOF >> "${SIU_ZSHRC}"
# Activate bash completion compatibility
autoload -U +X bashcompinit
bashcompinit
autoload -U +X compinit
compinit
EOF
    _siu::log::info "Finished ${SIU_ZSHRC} initialization"
}

function _siu::setup::init_siu()
{
    _siu::log::info "Starting SIU initialization"

    if [[ -f "$HOME/.zshrc"  ]] && ! grep -q "_siu::setup::init_siu" "$HOME/.zshrc"; then
        {
            echo -e "\n### Automatically added by _siu::setup::init_siu ###"
            echo ". $SIU_ZSHRC     ### _siu::setup::init_siu"
            echo "### Automatically added by _siu::setup::init_siu ###"
        } >> "$HOME"/.zshrc
    fi

    if [[ -f "$HOME/.bashrc"  ]] && ! grep -q "_siu::setup::init_siu" "$HOME/.bashrc"; then
        {
            echo -e "\n### Automatically added by _siu::setup::init_siu ###"
            echo ". $SIU_BASHRC    ### _siu::setup::init_siu"
            echo "### Automatically added by _siu::setup::init_siu ###"
        } >> "$HOME"/.bashrc
    fi

    _siu::setup::init_siu_dirs
    _siu::setup::init_siu_rc_files
    _siu::setup::init_siu_exports
    _siu::setup::init_siu_bashrc
    _siu::setup::init_siu_zshrc

    _siu::log::info "Finished SIU initialization"
}

_siu::setup::clean_rc_files()
{
    _siu::log::debug "Starting cleaning rc files."
    for rc in $HOME/.bashrc $HOME/.zshrc; do
        sed -i "/_siu::setup::/d" "${rc}"
        _siu::log::info "Removed SIU setup lines from '${rc}'."
    done
    _siu::log::debug "Finished cleaning rc files."
}
