#!/bin/bash

function _siu::prepare_install::fzf()
{
    # if this installation is offline,
    # then download the pre built binary, as the git repository uses an installation script that requires online connection
    if [[ ${OFFLINE_INSTALL} == yes ]]; then
        _siu::check::dependency::critical wget

        local FZF_VERSION ARCH_VERSION ARCHIVE
        FZF_VERSION=$(wget -qO- https://api.github.com/repos/junegunn/fzf/releases/latest | grep "tag_name" | cut -d\" -f4)
        _siu::check::return_code "Could not get latest version. Stopping installation preparation." "Latest version of bat is: ${FZF_VERSION}."

        ARCH_VERSION="linux_amd64.tar.gz"
        ARCHIVE="fzf-${FZF_VERSION#"v"}-${ARCH_VERSION}"

        wget -O archives/fzf.tar.gz "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/${ARCHIVE}"
        _siu::check::return_code "Could not download archive ${ARCHIVE}. Stopping installation preparation." "Downloaded archive ${ARCHIVE} from https://github.com/junegunn/fzf/releases/download/."
    fi

    _siu::check::dependency::critical git

    # even if the installation is offline, clone the git repository, as it contains the manpages
    git clone --depth 1 https://github.com/junegunn/fzf.git archives/fzf
    _siu::check::return_code "\"git clone\" dit not work. Stopping installation preparation." "Cloned https://github.com/junegunn/fzf.git."
}

function _siu::install::fzf()
{
    # if the installation is offline,
    # untar the archive and copy the manpage from the git repository
    # else just copy the git repository and use the installation script
    if [[ ${OFFLINE_INSTALL} == yes ]]; then
        tar -xvf archives/fzf.tar.gz
        _siu::check::return_code "Could not untar archive. Stopping installation." "Untarred fzf archive."
        mv fzf "${SIU_DIR}/bin"
        _siu::check::return_code "Could not move fzf to ${SIU_DIR}/bin. Stopping installation." "Moved fzf binary to ${SIU_DIR}/bin."

        # copy the manpages from the git repository, as fzf.tar.gz only contains a binary
        cp archives/fzf/man/man1/* "${SIU_DIR}/man/man1/"
        _siu::check::return_code "Could not copy manpages to ${SIU_DIR}/man/man1. Stopping installation." "Copied fzf manpage to ${SIU_DIR}/man/man1"
    else
        cp -r archives/fzf "${SIU_DIR}/fzf"
        _siu::check::return_code "Could not copy fzf repository to ${SIU_DIR}/fzf. Stopping installation." "Copied fzf repository to ${SIU_DIR}/fzf"

        # install fzf with key bindings, completion and man files
        # but without modifying shell configuration files nor generating ~/.fzf.{bash,zsh}
        "$SIU_DIR/fzf/install" --key-bindings --completion --xdg --no-update-rc --bin
        _siu::check::return_code "\"$SIU_DIR/fzf/install\" dit not work. Stopping installation." "Installed fzf with key bindings, completion and man files."

        cat << "EOF" >> "${SIU_EXPORTS}"

### Automaticaly added by _siu::install::fzf ###
export PATH="$PATH:$SIU_DIR/fzf/bin"        ### _siu::install::fzf
### Automaticaly added by _siu::install::fzf ###
EOF
        _siu::check::return_code "Could not update siu_exports to add fzf information." "Updated siu_exports to add fzf information."
    fi
}

function _siu::uninstall::fzf()
{
    # if the installation did not use the git repository,
    # then remove fzf binary and manpage
    # else remove fzf repository
    if [[ ! -d "${SIU_DIR}/fzf" ]]; then
        rm "${SIU_DIR}/bin/fzf"
        _siu::check::return_code "Could not remove fzf binary from ${SIU_DIR}/." "Removed fzf binary from ${SIU_DIR}/" --no-exit
        rm "${SIU_DIR}/man/man1/fzf*"
        _siu::check::return_code "Could not remove fzf manpage from ${SIU_DIR}/man/man1/." "Removed fzf manpage from ${SIU_DIR}/man/man1/" --no-exit
    else
        "${SIU_DIR}/fzf/uninstall"
        _siu::check::return_code "\"$SIU_DIR/fzf/uninstall\" dit not work." "Uninstalled fzf." --no-exit
        sed -i '/_siu::install::fzf/d' "${SIU_EXPORTS}"
        _siu::check::return_code "Could not remove fzf information from siu_exports." "Removed fzf information from siu_exports." --no-exit
    fi
}
