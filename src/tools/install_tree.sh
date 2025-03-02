#!/usr/bin/env bash

function _siu::get_latest_version::tree()
{
    local latest_version
    if latest_version="0.0.0"; then
        echo "${latest_version}"
    else
        return 1
    fi
}

function _siu::prepare_install::tree()
{
    local TREE_LATEST_ARCHIVE
    # use ?ND to sort the table of archives according to names, then only take the first line of tgz archives
    TREE_LATEST_ARCHIVE=$(basename "$(wget -O- https://oldmanprogrammer.net/tar/tree/?ND | grep -e "href=.*\.tgz\"" | head -n 1 | cut -d\" -f4)")
    _siu::check::return_code "Could not get latest archive. Stopping installation preparation." "Latest archive is: ${TREE_LATEST_ARCHIVE}."

    wget -O "${SIU_SOURCES_DIR_CURTOOL}/tree.tar.gz" "https://oldmanprogrammer.net/tar/tree/${TREE_LATEST_ARCHIVE}"
    _siu::check::return_code "Could not download archive ${TREE_LATEST_ARCHIVE}. Stopping installation preparation." "Downloaded archive ${TREE_LATEST_ARCHIVE} from https://oldmanprogrammer.net/tar/tree/."
}

function _siu::install::tree()
{
    _siu::check::return_code
    tar -xvf "${SIU_SOURCES_DIR_CURTOOL}/tree.tar.gz" -C . --strip-components 1
    _siu::check::return_code "Could not untar archive. Stopping installation." "Untarred tree archive."

    make -j8
    _siu::check::return_code "\"make\" did not work. Stopping installation." "Successfully ran \"make\"."

    # install
    mv tree "${SIU_UTILITIES_DIR}/tree/"
    _siu::check::return_code "Could not move tree binary to ${SIU_UTILITIES_DIR}/tree/. Stopping installation." "Moved tree binary to ${SIU_UTILITIES_DIR}/tree/."

    mv doc/tree.1 "${SIU_UTILITIES_DIR}/tree/"
    _siu::check::return_code "Could not move tree manpage to ${SIU_UTILITIES_DIR}/tree/. Stopping installation." "Moved tree manpage to ${SIU_UTILITIES_DIR}/tree/"

    # symlinks
    ln -s "$(realpath "${SIU_UTILITIES_DIR}/tree/tree")" "${SIU_BIN_DIR}/tree"
    ln -s "$(realpath "${SIU_UTILITIES_DIR}/tree/tree.1")" "${SIU_MAN_DIR}/man1/tree.1"
}
