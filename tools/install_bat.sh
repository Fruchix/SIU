#!/bin/bash

source env_siu.sh
source utils/check_utils.sh

install::bat()
{
    check::dependency::critical cargo
    cargo install --root "${SIU_DIR}" --no-track --locked bat
}

uninstall::bat()
{
    rm "${SIU_DIR}/bin/bat"
}
