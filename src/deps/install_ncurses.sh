#!/usr/bin/env bash

function _siu::check_installed::ncurses()
{
    if [[ -f /usr/include/ncurses/ncurses.h || -f /usr/include/ncursesw/ncurses.h ]]; then
        return 0
    fi

    return 1
}

function _siu::prepare_install::ncurses()
{
    wget -P "${SIU_SOURCES_DIR}" https://invisible-island.net/archives/ncurses/ncurses.tar.gz
    _siu::check::return_code "Could not download archive. Stopping installation preparation." "Downloaded latest ncurses archive from https://invisible-island.net/archives/ncurses/ncurses.tar.gz."
}

function _siu::install::ncurses()
{
    _siu::log::info "Installing ncurses from source."

    # untar ncurses archive into a directory named ncurses
    # (by default, untarring the archive gives a ncurses directory containing the whole version number)
    mkdir ncurses
    _siu::check::return_code "Could not create ncurses directory."
    tar -xvf "${SIU_SOURCES_DIR}"/ncurses.tar.gz -C ncurses --strip-components 1
    _siu::check::return_code "Could not untar archive. Stopping installation." "Untarred archive"

    pushd ncurses || {
        _siu::log::error "Could not pushd into ncurses directory. Stopping installation."
        exit 1
    }

    ./configure --prefix="${SIU_DEPS_DIR}" --with-shared --enable-widec
    _siu::check::return_code "\"./configure\" did not work. Stopping installation." "Successfully ran \"./configure\"."

    make -j8
    _siu::check::return_code "\"make\" did not work. Stopping installation." "Successfully ran \"make\"."

    make install
    _siu::check::return_code "\"make install\" did not work. Stopping installation." "Successfully ran \"make install\"."
    popd || {
        _siu::log::error "Could not popd out of ncurses directory. Stopping installation."
        exit 1
    }
}
