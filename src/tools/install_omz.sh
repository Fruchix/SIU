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

    # install omz using its installation script, which only works with network connection
    ZSH="${SIU_DIR}/oh-my-zsh" sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc --skip-chsh
    _siu::check::return_code "omz install using \"https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh\" dit not work. Stopping installation." "Installed omz using \"https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh\"."

    cat << "EOF" >> "${SIU_ZSHRC}"

### Automaticaly added by _siu::install::omz ###
export ZSH=${SIU_DIR}/oh-my-zsh              ### _siu::install::omz
                                             ### _siu::install::omz
ZSH_THEME="robbyrussell"                     ### _siu::install::omz
                                             ### _siu::install::omz
plugins=(git)                                ### _siu::install::omz
. $ZSH/oh-my-zsh.sh                          ### _siu::install::omz
### Automaticaly added by _siu::install::omz ###
EOF
    _siu::check::return_code "Could not update siu_zshrc to add omz information." "Updated siu_exports to add omz information."
}

function _siu::uninstall::omz()
{
    local retcode=0
    rm -rf "${SIU_DIR}/oh-my-zsh"
    _siu::check::return_code "Could not remove omz directory from ${SIU_DIR}/." "Removed omz directory from ${SIU_DIR}/" --no-exit retcode

    sed -i '/_siu::install::omz/d' "${SIU_ZSHRC}"
    _siu::check::return_code "Could not remove omz information from siu_zshrc." "Removed omz information from siu_zshrc." --no-exit retcode

    return $retcode
}
