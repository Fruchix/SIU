#!/bin/bash

source env_siu.sh
source utils/check_utils.sh

prepare_install::fzf()
{
    if [[ ${OFFLINE_INSTALL} == yes ]]; then
        check::dependency::critical wget

        local FZF_VERSION ARCH_VERSION ARCHIVE
        FZF_VERSION=$(wget -qO- https://api.github.com/repos/junegunn/fzf/releases/latest | grep "tag_name" | cut -d\" -f4)
        check::return_code "fzf prepare_install: could not get latest version. Stopping installation preparation."

        ARCH_VERSION="linux_amd64.tar.gz"
        ARCHIVE="fzf-${FZF_VERSION#"v"}-${ARCH_VERSION}"

        wget -O archives/fzf.tar.gz "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/${ARCHIVE}"
        check::return_code "fzf prepare_install: could not download archive ${ARCHIVE}. Stopping installation preparation."
    fi

    check::dependency::critical git

    git clone --depth 1 https://github.com/junegunn/fzf.git archives/fzf
    check::return_code "fzf prepare_install: \"git clone\" dit not work. Stopping installation preparation."
}

install::fzf()
{
    if [[ ${OFFLINE_INSTALL} == yes ]]; then
        tar -xvf archives/fzf.tar.gz
        check::return_code "fzf install: could not untar archive. Stopping installation."
        mv fzf "${SIU_DIR}/bin"
        check::return_code "fzf install: could not move fzf to ${SIU_DIR}/bin. Stopping installation."

        # copy the manpages from the git repository, as fzf.tar.gz only contains a binary
        cp archives/fzf/man/man1/* "${SIU_DIR}/man/man1/"
        check::return_code "fzf install: could not copy manpages to ${SIU_DIR}/man/man1. Stopping installation."
    else
        cp -r archives/fzf "${SIU_DIR}/fzf"

        # install fzf with key bindings, completion and man files
        # but without modifying shell configuration files nor generating ~/.fzf.{bash,zsh}
        "$SIU_DIR/fzf/install" --key-bindings --completion --xdg --no-update-rc --bin
        check::return_code "fzf prepare_install: \"$SIU_DIR/fzf/install\" dit not work. Stopping installation."

        cat << "EOF" >> "${SIU_EXPORTS}"

### Automaticaly added by SIU::install::fzf ###
export PATH="$PATH:$SIU_DIR/fzf/bin"        ### SIU::install::fzf
### Automaticaly added by SIU::install::fzf ###
EOF
    fi
}

uninstall::fzf()
{
    if [[ ! -d "${SIU_DIR}/fzf" ]]; then
        rm "${SIU_DIR}/bin/fzf"
    else
        "${SIU_DIR}/fzf/uninstall"
        sed -i '/SIU::install::fzf/d' "${SIU_EXPORTS}"
    fi
}
