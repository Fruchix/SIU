#!/bin/bash

source env_siu.sh
source utils/check_utils.sh

install::omz()
{
    ZSH="${SIU_DIR}/oh-my-zsh" sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

    cat << "EOF" >> "${SIU_ZSHRC}"

### Automaticaly added by SIU::install::omz ###
export ZSH=${SIU_DIR}/oh-my-zsh             ### SIU::install::omz
                                            ### SIU::install::omz
ZSH_THEME="robbyrussell"                    ### SIU::install::omz
                                            ### SIU::install::omz
plugins=(git)                               ### SIU::install::omz
source $ZSH/oh-my-zsh.sh                    ### SIU::install::omz
### Automaticaly added by SIU::install::omz ###
EOF
}

uninstall::omz()
{
    rm -rf "${SIU_DIR}/oh-my-zsh"
    sed -i '/SIU::install::omz/d' "${SIU_ZSHRC}"
}
