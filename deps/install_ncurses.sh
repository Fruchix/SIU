#!/bin/bash

source env_siu.sh

prepare_install::ncurses()
{
    check::dependency::critical wget

    wget -P archives https://invisible-island.net/archives/ncurses/ncurses.tar.gz
    check::return_code "ncurses prepare_install: could not download archive. Stopping installation preparation."
}

install::ncurses()
{
    echo "Installing ncurses from source."

    mkdir ncurses
    check::return_code
    tar -xvf archives/ncurses.tar.gz -C ncurses --strip-components 1
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
