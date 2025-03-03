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
    wget -P "${SIU_SOURCES_DIR_CURTOOL}" https://invisible-island.net/archives/ncurses/ncurses.tar.gz
    _siu::check::return_code "Could not download archive. Stopping installation preparation." "Downloaded latest ncurses archive from https://invisible-island.net/archives/ncurses/ncurses.tar.gz."
}

function _siu::install::ncurses()
{
    _siu::log::info "Installing ncurses from source."

    tar -xvf "${SIU_SOURCES_DIR_CURTOOL}/ncurses.tar.gz" -C . --strip-components 1
    _siu::check::return_code "Could not untar archive. Stopping installation." "Untarred archive"

    # currently installing directly in dependencies: no way of doing a proper uninstallation
    # As ncurses is not a tool but a deps, cannot be uninstalled using siu uninstall command, so not having an uninstallation method is fine
    # a solution would be to install deps (such as ncurses) in the utilities dir, then use stow to create symlinks and such in the global SIU deps directory
    ./configure --prefix="${SIU_DEPS_DIR}" --with-shared --enable-widec
    _siu::check::return_code "\"./configure\" did not work. Stopping installation." "Successfully ran \"./configure\"."

    make -j8
    _siu::check::return_code "\"make\" did not work. Stopping installation." "Successfully ran \"make\"."

    make install
    _siu::check::return_code "\"make install\" did not work. Stopping installation." "Successfully ran \"make install\"."
}
