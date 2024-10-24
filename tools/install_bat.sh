#!/bin/bash

source env_siu.sh
source utils/check_utils.sh

install::bat()
{
    check::dependency::critical curl
    local BAT_VERSION=$(curl --silent --stderr - https://api.github.com/repos/sharkdp/bat/releases/latest | grep "tag_name" | cut -d\" -f4)
    local ARCH_VERSION="x86_64-unknown-linux-musl.tar.gz"

    local ARCHIVE="bat-${BAT_VERSION}-${ARCH_VERSION}"

    curl -L "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/${ARCHIVE}" -o "${ARCHIVE}"

    tar -xvf "${ARCHIVE}"
    mv "${ARCHIVE%".tar.gz"}" bat
    rm "${ARCHIVE}"

    mv bat/bat "${SIU_DIR}/bin"
    mv bat/bat.1 "${SIU_DIR}/man/man1"

    rm -r bat
}

uninstall::bat()
{
    rm "${SIU_DIR}/bin/bat"
    rm "${SIU_DIR}/man/man1/bat.1"
}
