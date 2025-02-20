#!/usr/bin/env bash

# this script should be run from this project's root directory
if ! [[ -d src/utils && -d src/tools && -d src/deps && -f src/env_siu.sh && -f src/setup_siu.sh ]]; then
    echo "This script should only be run from its directory."
    exit 1
fi

# TODO: get SIU_PREFIX from argument (default: $HOME) and overwrite it in env_siu.sh

. src/source_all.sh

if [[ -d "${SIU_DIR}" ]]; then
    _siu::log::error "SIU directory '${SIU_DIR}' already exist. Stopping installation."
    exit 1
fi

mv "${PWD}" "${SIU_DIR}" || {
    _siu::log::error "Could not create SIU directory '${SIU_DIR}'. Stopping installation."
    exit 1
}

cd "${SIU_DIR}" || {
    _siu::log::error "Could not cd into SIU directory '${SIU_DIR}'. Stopping installation."
    exit 1
}

_siu::init::siu
