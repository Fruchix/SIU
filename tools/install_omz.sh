#!/bin/bash

source env_siu.sh
source utils/check_utils.sh

function _siu::prepare_install::omz()
{
    echo "Cannot prepare installation for omz as it requires zsh to be installed."
}

function _siu::install::omz()
{
    if [[ ${OFFLINE_INSTALL} == yes ]]; then
        echo "Cannot install Oh-my-zsh while offline."
        return 1
    fi
    _siu::check::dependency::critical git
    _siu::check::dependency::critical wget

    ZSH="${SIU_DIR}/oh-my-zsh" sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc --skip-chsh

    cat << "EOF" >> "${SIU_ZSHRC}"

### Automaticaly added by _siu::install::omz ###
export ZSH=${SIU_DIR}/oh-my-zsh             ### _siu::install::omz
                                            ### _siu::install::omz
ZSH_THEME="robbyrussell"                    ### _siu::install::omz
                                            ### _siu::install::omz
plugins=(git)                               ### _siu::install::omz
source $ZSH/oh-my-zsh.sh                    ### _siu::install::omz
### Automaticaly added by _siu::install::omz ###
EOF
}

function _siu::uninstall::omz()
{
    rm -rf "${SIU_DIR}/oh-my-zsh"
    sed -i '/_siu::install::omz/d' "${SIU_ZSHRC}"
}
