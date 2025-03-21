#!/usr/bin/env bash

function _siu::get_latest_version::omz()
{
    local latest_version
    if latest_version="0.0.0"; then
        echo "${latest_version}"
    else
        return 1
    fi
}

function _siu::prepare_install::omz()
{
    _siu::log::warning "Cannot prepare installation for omz as it requires zsh to be installed."
}

function _siu::install::omz()
{
    if [[ ${OFFLINE_INSTALL} == yes ]]; then
        _siu::log::error "Cannot install Oh-my-zsh while offline."
        return 1
    fi

    # needed as omz installer won't overwrite directory
    rm -rf "${SIU_UTILITIES_DIR}/omz"

    # install omz using its installation script, which only works with network connection
    ZSH="${SIU_UTILITIES_DIR}/omz" sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc --skip-chsh
    _siu::check::return_code "omz install using \"https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh\" dit not work. Stopping installation." "Installed omz using \"https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh\"."

    cat << "EOF" >> "${SIU_ZSHRC}"

### Automaticaly added by _siu::install::omz ###
export ZSH=${SIU_UTILITIES_DIR}/omz          ### _siu::install::omz
                                             ### _siu::install::omz
ZSH_THEME="robbyrussell"                     ### _siu::install::omz
                                             ### _siu::install::omz
plugins=(git)                                ### _siu::install::omz
. $ZSH/oh-my-zsh.sh                          ### _siu::install::omz
### Automaticaly added by _siu::install::omz ###
EOF
    _siu::check::return_code "Could not update siu_zshrc to add omz information." "Updated siu_exports to add omz information."
}
