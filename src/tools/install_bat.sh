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
    _siu::arch::get_yaml_info "bat"
    # shellcheck disable=SC2154
    archive="${_siu_arch_get_yaml_info_return_value//<VERSION>/$bat_version}"

    wget -O "${SIU_SOURCES_DIR_CURTOOL}/bat.tar.gz" "https://github.com/sharkdp/bat/releases/download/v${bat_version}/${archive}"
    _siu::check::return_code "Could not download archive ${archive}. Stopping installation preparation." "Downloaded archive ${archive} from https://github.com/sharkdp/bat/releases/download/."
}

function _siu::install::bat()
{
    tar -xvf "${SIU_SOURCES_DIR_CURTOOL}/bat.tar.gz" -C "${SIU_UTILITIES_DIR}/bat/" --strip-components 1
    _siu::check::return_code "Could not untar archive. Stopping installation." "Untarred bat archive."

    ln -s "$(realpath "${SIU_UTILITIES_DIR}/bat/bat")" "${SIU_BIN_DIR}/bat"
    ln -s "$(realpath "${SIU_UTILITIES_DIR}/bat/bat.1")" "${SIU_MAN_DIR}/man1/bat.1"
}
