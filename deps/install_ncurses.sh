#!/bin/bash

source env_siu.sh

install::ncurses()
{
    echo "Installing ncurses from source."

    check::dependency::critical wget

    # get ncurses archive
    wget https://invisible-island.net/archives/ncurses/ncurses.tar.gz
    check::return_code "ncurses install: could not download archive. Stopping installation."

    mkdir ncurses
    check::return_code
    tar -xvf ncurses.tar.gz -C ncurses --strip-components 1
    check::return_code "ncurses install: could not untar archive. Stopping installation."

    pushd ncurses || return
    ./configure --prefix="${SIU_DEPS_DIR}" --with-shared --enable-widec
    check::return_code "ncurses install: \"./configure\" did not work. Stopping installation."

    make -j8
    check::return_code "ncurses install: \"make\" did not work. Stopping installation."

    make install
    check::return_code "ncurses install: \"make install\" did not work. Stopping installation."
    popd || return
}
