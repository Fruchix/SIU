#!/bin/bash

source env_siu.sh
source utils/check_utils.sh

install::bat()
{
    check::dependency::critical wget

    local BAT_VERSION, ARCH_VERSION, ARCHIVE
    BAT_VERSION=$(wget -q -O - https://api.github.com/repos/sharkdp/bat/releases/latest | grep "tag_name" | cut -d\" -f4)
    check::return_code "bat install: could not get latest version. Stopping installation."

    ARCH_VERSION="x86_64-unknown-linux-musl.tar.gz"

    ARCHIVE="bat-${BAT_VERSION}-${ARCH_VERSION}"

    wget "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/${ARCHIVE}"
    check::return_code "bat install: could not download archive ${ARCHIVE}. Stopping installation."

    tar -xvf "${ARCHIVE}"
    check::return_code "fzf install: could not untar archive. Stopping installation."

    mv "${ARCHIVE%".tar.gz"}" bat
    check::return_code "fzf install: could not rename archive. Stopping installation."

    mv bat/bat "${SIU_DIR}/bin"
    check::return_code "fzf install: could not move bat binary to ${SIU_DIR}/bin. Stopping installation."
    mv bat/bat.1 "${SIU_DIR}/man/man1"
    check::return_code "fzf install: could not move bat manpage to ${SIU_DIR}/man/man1. Stopping installation."
}

uninstall::bat()
{
    rm "${SIU_DIR}/bin/bat"
    rm "${SIU_DIR}/man/man1/bat.1"
}
