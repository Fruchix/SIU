#!/bin/bash

source env_siu.sh

function _siu::init::siu_dirs()
{
    mkdir -p "${SIU_DIR}"
    mkdir -p "${SIU_DIR}"/bin
    mkdir -p "${SIU_DIR}"/man/man1
    mkdir -p "${SIU_DEPS_DIR}"
}

function _siu::init::siu_exports()
{
    echo "export SIU_DIR=${SIU_DIR}" >> "${SIU_EXPORTS}"
    cat << "EOF" >> "${SIU_EXPORTS}"
export SIU_EXPORTS=$SIU_DIR/siu_exports
export SIU_ZSHRC=$SIU_DIR/siu_zshrc
export SIU_BASHRC=$SIU_DIR/siu_bashrc

export PATH=$PATH:$SIU_DIR/bin:$SIU_DEPS_DIR/bin
EOF
    source "${SIU_EXPORTS}"
}

function _siu::init::siu_rc_files()
{
    touch "${SIU_BASHRC}"
    touch "${SIU_ZSHRC}"
    touch "${SIU_EXPORTS}"
}

function _siu::init::siu_bashrc()
{
    echo "source $SIU_EXPORTS" > "${SIU_BASHRC}"
}

function _siu::init::siu_zshrc()
{
    echo "source $SIU_EXPORTS" > "${SIU_ZSHRC}"

    cat << EOF >> "${SIU_ZSHRC}"
# Activate bash completion compatibility
autoload -U +X bashcompinit
bashcompinit
autoload -U +X compinit
compinit
EOF
}

function _siu::init::siu()
{
    {
        echo -e "\n### Automaticaly added by _siu::init::siu ###"
        echo "source $SIU_ZSHRC     ### _siu::init::siu"
        echo "### Automaticaly added by _siu::init::siu ###"
    } >> ~/.zshrc

    {
        echo -e "\n### Automaticaly added by _siu::init::siu ###"
        echo "source $SIU_BASHRC    ### _siu::init::siu"
        echo "### Automaticaly added by _siu::init::siu ###"
    } >> ~/.bashrc
    
    _siu::init::siu_dirs
    _siu::init::siu_rc_files
    _siu::init::siu_exports
    _siu::init::siu_bashrc
    _siu::init::siu_zshrc
}
