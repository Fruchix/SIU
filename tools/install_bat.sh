#!/bin/bash

function _siu::prepare_install::bat()
{
    _siu::check::dependency::critical wget

    local BAT_VERSION ARCH_VERSION ARCHIVE
    BAT_VERSION=$(wget -qO- https://api.github.com/repos/sharkdp/bat/releases/latest | grep "tag_name" | cut -d\" -f4)
    _siu::check::return_code "bat prepare_install: could not get latest version. Stopping installation preparation."

    ARCH_VERSION="x86_64-unknown-linux-musl.tar.gz"
    ARCHIVE="bat-${BAT_VERSION}-${ARCH_VERSION}"

    wget -O archives/bat.tar.gz "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/${ARCHIVE}"
    _siu::check::return_code "bat prepare_install: could not download archive ${ARCHIVE}. Stopping installation preparation."
}

function _siu::install::bat()
{
    mkdir bat
    _siu::check::return_code
    tar -xvf archives/bat.tar.gz -C bat --strip-components 1
    _siu::check::return_code "bat install: could not untar archive. Stopping installation."

    mv bat/bat "${SIU_DIR}/bin"
    _siu::check::return_code "bat install: could not move bat binary to ${SIU_DIR}/bin. Stopping installation."
    mv bat/bat.1 "${SIU_DIR}/man/man1"
    _siu::check::return_code "bat install: could not move bat manpage to ${SIU_DIR}/man/man1. Stopping installation."
}

function _siu::uninstall::bat()
{
    rm "${SIU_DIR}/bin/bat"
    rm "${SIU_DIR}/man/man1/bat.1"
}
