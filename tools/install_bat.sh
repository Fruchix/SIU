#!/bin/bash

function _siu::check_installed::bat()
{
    if [[ -f ${SIU_DIR}/bin/bat ]]; then
        _siu::log::info "Installed using SIU."
        return 0
    fi

    if _siu::check::command_exists bat; then
        return 0
    fi

    return 1
}

function _siu::prepare_install::bat()
{
    _siu::check::dependency::critical wget

    local BAT_VERSION ARCH_VERSION ARCHIVE
    BAT_VERSION=$(wget -qO- https://api.github.com/repos/sharkdp/bat/releases/latest | grep "tag_name" | cut -d\" -f4)
    _siu::check::return_code "Could not get latest version. Stopping installation preparation." "Latest version of bat is: ${BAT_VERSION}."

    ARCH_VERSION="x86_64-unknown-linux-musl.tar.gz" # get a static version of bat (musl)
    ARCHIVE="bat-${BAT_VERSION}-${ARCH_VERSION}"

    wget -O archives/bat.tar.gz "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/${ARCHIVE}"
    _siu::check::return_code "Could not download archive ${ARCHIVE}. Stopping installation preparation." "Downloaded archive ${ARCHIVE} from https://github.com/sharkdp/bat/releases/download/."
}

function _siu::install::bat()
{
    mkdir bat
    _siu::check::return_code
    tar -xvf archives/bat.tar.gz -C bat --strip-components 1
    _siu::check::return_code "Could not untar archive. Stopping installation." "Untarred bat archive."

    mv bat/bat "${SIU_DIR}/bin"
    _siu::check::return_code "Could not move bat binary to ${SIU_DIR}/bin. Stopping installation." "Moved bat binary to ${SIU_DIR}/bin."
    mv bat/bat.1 "${SIU_DIR}/man/man1"
    _siu::check::return_code "Could not move bat manpage to ${SIU_DIR}/man/man1. Stopping installation." "Moved bat manpage to ${SIU_DIR}/man/man1"
}

function _siu::uninstall::bat()
{
    rm "${SIU_DIR}/bin/bat"
    _siu::check::return_code "Could not remove bat binary from ${SIU_DIR}/." "Removed bat binary from ${SIU_DIR}" --no-exit
    rm "${SIU_DIR}/man/man1/bat.1"
    _siu::check::return_code "Could not remove bat manpage from ${SIU_DIR}/man/man1/." "Removed bat manpage from ${SIU_DIR}/man/man1/" --no-exit
}
