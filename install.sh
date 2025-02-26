#!/usr/bin/env bash

# this script should be run from this project's root directory
if ! [[ -d src/utils && \
        -d src/tools && \
        -d src/deps && \
        -f src/source_all.sh ]]; then
    echo "This script should only be run from its directory."   
    exit 1
fi

# TODO: get SIU_PREFIX from argument (default: $HOME) and overwrite it in env_siu.sh

export SIU_PREFIX="${HOME}"

(
    . src/source_all.sh
    _siu::log::info "Starting SIU installation in '${SIU_DIR}'."

    if [[ -d "${SIU_DIR}" ]]; then
        _siu::log::error "SIU directory '${SIU_DIR}' already exist. Stopping installation."
        exit 1
    fi

    mv "${PWD}" "${SIU_DIR}" || {
        _siu::log::error "Could not create SIU directory '${SIU_DIR}'. Stopping installation."
        exit 1
    }

    _siu::init::siu

    ln -s "$(realpath "${SIU_DIR}/siu.sh")" "${SIU_BIN_DIR}/siu"
    _siu::log::info "SIU has been installed in '${SIU_DIR}'."
)
