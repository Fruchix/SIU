#!/usr/bin/env bash

function _siu::get_latest_version::bat()
{
    local latest_version
    if latest_version=$(wget -qO- https://api.github.com/repos/sharkdp/bat/releases/latest); then
        echo "${latest_version}" | grep "tag_name" | cut -d\" -f4 | tr -d v
    else
        return 1
    fi
}

function _siu::prepare_install::bat()
{
    local bat_version archive
    bat_version=$(_siu::get_latest_version::bat)
    _siu::check::return_code "Could not get latest version. Stopping installation preparation." "Latest version of bat is: ${bat_version}."

    # get archive according to architecture
    archive="$(_siu::arch::get_yaml_info "bat")"
    archive="${archive//<VERSION>/$bat_version}"

    wget -O "${SIU_SOURCES_DIR}"/bat.tar.gz "https://github.com/sharkdp/bat/releases/download/v${bat_version}/${archive}"
    _siu::check::return_code "Could not download archive ${archive}. Stopping installation preparation." "Downloaded archive ${archive} from https://github.com/sharkdp/bat/releases/download/."
}

function _siu::install::bat()
{
    mkdir bat
    _siu::check::return_code
    tar -xvf "${SIU_SOURCES_DIR}"/bat.tar.gz -C bat --strip-components 1
    _siu::check::return_code "Could not untar archive. Stopping installation." "Untarred bat archive."

    mv bat/bat "${SIU_BIN_DIR}"
    _siu::check::return_code "Could not move bat binary to ${SIU_BIN_DIR}. Stopping installation." "Moved bat binary to ${SIU_BIN_DIR}."

    mv bat/bat.1 "${SIU_MAN_DIR}/man1"
    _siu::check::return_code "Could not move bat manpage to ${SIU_MAN_DIR}/man1. Stopping installation." "Moved bat manpage to ${SIU_MAN_DIR}/man1"
}

function _siu::uninstall::bat()
{
    local retcode=0
    rm "${SIU_BIN_DIR}/bat"
    _siu::check::return_code "Could not remove bat binary from ${SIU_BIN_DIR}/." "Removed bat binary from ${SIU_BIN_DIR}" --no-exit retcode

    rm "${SIU_MAN_DIR}/man1/bat.1"
    _siu::check::return_code "Could not remove bat manpage from ${SIU_MAN_DIR}/man1/." "Removed bat manpage from ${SIU_MAN_DIR}/man1/" --no-exit retcode

    return $retcode
}
