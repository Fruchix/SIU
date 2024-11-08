#!/bin/bash

function _siu::prepare_install::tree()
{
    _siu::check::dependency::critical wget

    local TREE_LATEST_ARCHIVE
    # use ?ND to sort the table of archives according to names, then only take the first line of tgz archives
    TREE_LATEST_ARCHIVE=$(basename "$(wget -O- https://oldmanprogrammer.net/tar/tree/?ND | grep -e "href=.*\.tgz\"" | head -n 1 | cut -d\" -f4)")
    _siu::check::return_code "Could not get latest archive. Stopping installation preparation." "Latest archive is: ${TREE_LATEST_ARCHIVE}."

    wget -O archives/tree.tar.gz "https://oldmanprogrammer.net/tar/tree/${TREE_LATEST_ARCHIVE}"
    _siu::check::return_code "Could not download archive ${TREE_LATEST_ARCHIVE}. Stopping installation preparation." "Downloaded archive ${TREE_LATEST_ARCHIVE} from https://oldmanprogrammer.net/tar/tree/."
}

function _siu::install::tree()
{
    mkdir tree
    _siu::check::return_code
    tar -xvf archives/tree.tar.gz -C tree --strip-components 1
    _siu::check::return_code "Could not untar archive. Stopping installation." "Untarred tree archive."

    pushd tree || {
        _siu::log::error "Could not pushd into tree directory. Stopping installation."
        exit 1
    }

    make -j8
    _siu::check::return_code "\"make\" did not work. Stopping installation." "Successfully ran \"make\"."

    # install
    mv tree "${SIU_DIR}/bin/"
    _siu::check::return_code "Could not move tree binary to ${SIU_DIR}/bin. Stopping installation." "Moved tree binary to ${SIU_DIR}/bin."

    mv doc/tree.1 "${SIU_DIR}/man/man1/"
    _siu::check::return_code "Could not move tree manpage to ${SIU_DIR}/man/man1. Stopping installation." "Moved tree manpage to ${SIU_DIR}/man/man1"

    popd || {
        _siu::log::error "Could not popd out of tree directory. Stopping installation."
        exit 1
    }
}

function _siu::uninstall::tree()
{
    rm "${SIU_DIR}/bin/tree"
    _siu::check::return_code "Could not remove tree binary from ${SIU_DIR}/." "Removed tree binary from ${SIU_DIR}" --no-exit
    rm "${SIU_DIR}/man/man1/tree.1"
    _siu::check::return_code "Could not remove tree manpage from ${SIU_DIR}/man/man1/." "Removed tree manpage from ${SIU_DIR}/man/man1/" --no-exit
}
