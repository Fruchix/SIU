#!/usr/bin/env bash

function _siu::get_latest_version::fzf()
{
    local latest_version
    if latest_version=$(wget -qO- https://api.github.com/repos/junegunn/fzf/releases/latest); then
        echo "${latest_version}" | grep "tag_name" | cut -d\" -f4 | tr -d v
    else
        return 1
    fi
}

function _siu::prepare_install::fzf()
{
    git clone --depth 1 https://github.com/junegunn/fzf.git "${SIU_SOURCES_DIR_CURTOOL}/fzf.gitclone"
    _siu::check::return_code "\"git clone\" dit not work. Stopping installation preparation." "Cloned https://github.com/junegunn/fzf.git."

    # if this installation is offline,
    # then download the pre built binary, as the git repository uses an installation script that requires online connection
    if [[ ${OFFLINE_INSTALL} == yes ]]; then
        local fzf_version archive
        fzf_version=$(_siu::get_latest_version::fzf)
        _siu::check::return_code "Could not get latest version. Stopping installation preparation." "Latest version of fzf is: ${fzf_version}."

        # get archive according to architecture
        _siu::arch::get_yaml_info "fzf"
        # shellcheck disable=SC2154
        archive="${_siu_arch_get_yaml_info_return_value//<VERSION>/$bat_version}"

        wget -O "${SIU_SOURCES_DIR_CURTOOL}/fzf.tar.gz" "https://github.com/junegunn/fzf/releases/download/${fzf_version}/${archive}"
        _siu::check::return_code "Could not download archive ${archive}. Stopping installation preparation." "Downloaded archive ${archive} from https://github.com/junegunn/fzf/releases/download/."
    fi
}

function _siu::install::fzf()
{
    cp -rT "${SIU_SOURCES_DIR_CURTOOL}/fzf.gitclone" "${SIU_UTILITIES_DIR}/fzf"
    _siu::check::return_code "Could not copy fzf repository to ${SIU_UTILITIES_DIR}/fzf. Stopping installation." "Copied fzf repository to ${SIU_UTILITIES_DIR}/fzf."

    # if the installation is offline,
    # then untar the archive to get fzf pre built binary
    # else use the installation script
    if [[ ${OFFLINE_INSTALL} == yes ]]; then
        tar -xvf "${SIU_SOURCES_DIR_CURTOOL}/fzf.tar.gz"
        _siu::check::return_code "Could not untar archive. Stopping installation." "Untarred fzf archive."
        mv fzf "${SIU_UTILITIES_DIR}/fzf/bin"
        _siu::check::return_code "Could not move fzf to ${SIU_UTILITIES_DIR}/fzf/bin. Stopping installation." "Moved fzf binary to ${SIU_UTILITIES_DIR}/fzf/bin."
    else
        # install fzf with key bindings, completion and man files
        # but without modifying shell configuration files nor generating ~/.fzf.{bash,zsh}
        "${SIU_UTILITIES_DIR}/fzf/install" --key-bindings --completion --xdg --no-update-rc --bin
        _siu::check::return_code "\"${SIU_UTILITIES_DIR}/fzf/install\" dit not work. Stopping installation." "Installed fzf with key bindings, completion and man files."
    fi

    # create symlinks
    for f in "${SIU_UTILITIES_DIR}"/fzf/bin/*; do
        ln -s "$(realpath "${f}")" "${SIU_BIN_DIR}/${f##*/}"
    done
    for f in "${SIU_UTILITIES_DIR}"/fzf/man/man1/*; do
        ln -s "$(realpath "${f}")" "${SIU_MAN_DIR}/man1/${f##*/}"
    done

    # update all rc files

    # activate bash completion and keybindings
    cat << "EOF" >> "${SIU_BASHRC}"

### Automaticaly added by _siu::install::fzf         ###
for i in "${SIU_UTILITIES_DIR}"/fzf/shell/*.bash; do ### _siu::install::fzf
    . $i                                             ### _siu::install::fzf
done                                                 ### _siu::install::fzf
### Automaticaly added by _siu::install::fzf         ###
EOF

    # activate zsh completion and keybindings
    cat << "EOF" >> "${SIU_ZSHRC}"

### Automaticaly added by _siu::install::fzf        ###
for i in "${SIU_UTILITIES_DIR}"/fzf/shell/*.zsh; do ### _siu::install::fzf
    . $i                                            ### _siu::install::fzf
done                                                ### _siu::install::fzf
### Automaticaly added by _siu::install::fzf        ###
EOF
}

function _siu::uninstall::fzf()
{
    local retcode=0
    rm -rf "${SIU_UTILITIES_DIR}/fzf"
    _siu::check::return_code "Could not remove fzf directory from ${SIU_UTILITIES_DIR}/." "Removed fzf directory from ${SIU_UTILITIES_DIR}/" --no-exit retcode

    sed -i '/_siu::install::fzf/d' "${SIU_BASHRC}"
    _siu::check::return_code "Could not remove fzf information from siu_bashrc." "Removed fzf information from siu_bashrc." --no-exit retcode

    sed -i '/_siu::install::fzf/d' "${SIU_ZSHRC}"
    _siu::check::return_code "Could not remove fzf information from siu_zshrc." "Removed fzf information from siu_zshrc." --no-exit retcode

    return $retcode
}
