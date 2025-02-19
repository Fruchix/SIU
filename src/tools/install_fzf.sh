#!/bin/bash

function _siu::get_latest_version::fzf()
{
    local latest_version
    if latest_version=$(wget -qO- https://api.github.com/repos/junegunn/fzf/releases/latest); then
        echo "${latest_version}" | grep "tag_name" | cut -d\" -f4 | tr -d v
    else
        return 1
    fi
}

function _siu::check_installed::fzf()
{
    if [[ -d ${SIU_DIR}/fzf ]]; then
        _siu::log::info "Installed using SIU."
        return 0
    fi

    if _siu::check::command_exists fzf; then
        return 0
    fi

    return 1
}

function _siu::prepare_install::fzf()
{
    git clone --depth 1 https://github.com/junegunn/fzf.git archives/fzf.gitclone
    _siu::check::return_code "\"git clone\" dit not work. Stopping installation preparation." "Cloned https://github.com/junegunn/fzf.git."

    # if this installation is offline,
    # then download the pre built binary, as the git repository uses an installation script that requires online connection
    if [[ ${OFFLINE_INSTALL} == yes ]]; then
        local FZF_VERSION ARCH_VERSION ARCHIVE
        FZF_VERSION=$(_siu::get_latest_version::fzf)
        _siu::check::return_code "Could not get latest version. Stopping installation preparation." "Latest version of fzf is: ${FZF_VERSION}."

        ARCH_VERSION="linux_amd64.tar.gz"
        ARCHIVE="fzf-${FZF_VERSION}-${ARCH_VERSION}"

        wget -O archives/fzf.tar.gz "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/${ARCHIVE}"
        _siu::check::return_code "Could not download archive ${ARCHIVE}. Stopping installation preparation." "Downloaded archive ${ARCHIVE} from https://github.com/junegunn/fzf/releases/download/."
    fi
}

function _siu::install::fzf()
{
    # copy the git repository to $SIU_DIR
    cp -r archives/fzf.gitclone "${SIU_DIR}/fzf"
    _siu::check::return_code "Could not copy fzf repository to ${SIU_DIR}/fzf. Stopping installation." "Copied fzf repository to ${SIU_DIR}/fzf"

    # if the installation is offline,
    # then untar the archive to get fzf pre built binary
    # else use the installation script
    if [[ ${OFFLINE_INSTALL} == yes ]]; then
        tar -xvf archives/fzf.tar.gz
        _siu::check::return_code "Could not untar archive. Stopping installation." "Untarred fzf archive."
        mv fzf "${SIU_DIR}/fzf/bin"
        _siu::check::return_code "Could not move fzf to ${SIU_DIR}/fzf/bin. Stopping installation." "Moved fzf binary to ${SIU_DIR}/fzf/bin."

        # copy the manpages from the git repository, as fzf.tar.gz only contains a binary
        # cp archives/fzf/man/man1/* "${SIU_DIR}/man/man1/"
        # _siu::check::return_code "Could not copy manpages to ${SIU_DIR}/man/man1. Stopping installation." "Copied fzf manpage to ${SIU_DIR}/man/man1"
    else
        # install fzf with key bindings, completion and man files
        # but without modifying shell configuration files nor generating ~/.fzf.{bash,zsh}
        "$SIU_DIR/fzf/install" --key-bindings --completion --xdg --no-update-rc --bin
        _siu::check::return_code "\"$SIU_DIR/fzf/install\" dit not work. Stopping installation." "Installed fzf with key bindings, completion and man files."
    fi

    # update all rc files

    cat << "EOF" >> "${SIU_EXPORTS}"

### Automaticaly added by _siu::install::fzf ###
export PATH="$SIU_DIR/fzf/bin:$PATH"         ### _siu::install::fzf
### Automaticaly added by _siu::install::fzf ###
EOF
    _siu::check::return_code "Could not update siu_exports to add fzf information." "Updated siu_exports to add fzf information."

    # activate bash completion and keybindings
    cat << "EOF" >> "${SIU_BASHRC}"

### Automaticaly added by _siu::install::fzf ###
for i in $SIU_DIR/fzf/shell/*.bash; do       ### _siu::install::fzf
. $i                                     ### _siu::install::fzf
done                                         ### _siu::install::fzf
### Automaticaly added by _siu::install::fzf ###
EOF

    # activate zsh completion and keybindings
    cat << "EOF" >> "${SIU_ZSHRC}"

### Automaticaly added by _siu::install::fzf ###
for i in $SIU_DIR/fzf/shell/*.zsh; do        ### _siu::install::fzf
    . $i                                     ### _siu::install::fzf
done                                         ### _siu::install::fzf
### Automaticaly added by _siu::install::fzf ###
EOF
}

function _siu::uninstall::fzf()
{
    rm -rf "${SIU_DIR}/fzf"
    _siu::check::return_code "Could not remove fzf directory from ${SIU_DIR}/." "Removed fzf directory from ${SIU_DIR}/" --no-exit

    sed -i '/_siu::install::fzf/d' "${SIU_EXPORTS}"
    _siu::check::return_code "Could not remove fzf information from siu_exports." "Removed fzf information from siu_exports." --no-exit

    sed -i '/_siu::install::fzf/d' "${SIU_BASHRC}"
    _siu::check::return_code "Could not remove fzf information from siu_bashrc." "Removed fzf information from siu_bashrc." --no-exit

    sed -i '/_siu::install::fzf/d' "${SIU_ZSHRC}"
    _siu::check::return_code "Could not remove fzf information from siu_zshrc." "Removed fzf information from siu_zshrc." --no-exit
}
