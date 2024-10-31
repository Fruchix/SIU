#!/bin/bash

function _siu::prepare_install::ncurses()
{
    _siu::check::dependency::critical wget

    wget -P archives https://invisible-island.net/archives/ncurses/ncurses.tar.gz
    _siu::check::return_code "ncurses prepare_install: could not download archive. Stopping installation preparation."
}

function _siu::install::ncurses()
{
    echo "Installing ncurses from source."

    mkdir ncurses
    _siu::check::return_code
    tar -xvf archives/ncurses.tar.gz -C ncurses --strip-components 1
    _siu::check::return_code "ncurses install: could not untar archive. Stopping installation."

    pushd ncurses || return
    ./configure --prefix="${SIU_DEPS_DIR}" --with-shared --enable-widec
    _siu::check::return_code "ncurses install: \"./configure\" did not work. Stopping installation."

    make -j8
    _siu::check::return_code "ncurses install: \"make\" did not work. Stopping installation."

    make install
    _siu::check::return_code "ncurses install: \"make install\" did not work. Stopping installation."
    popd || return
}
