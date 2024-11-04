#!/bin/bash

function _siu::prepare_install::zsh()
{
    _siu::check::dependency::critical wget

    # download archive, should create an archive named zsh.tar.xz
    wget -O archives/zsh.tar.xz https://sourceforge.net/projects/zsh/files/latest/download
    _siu::check::return_code "Could not download archive. Stopping installation preparation." "Downloaded latest zsh archive from https://sourceforge.net/projects/zsh/files/latest/download."

    # in case we need it, download ncurses dependency
    _siu::log::info "Starting preparing ncurses install"
    . deps/install_ncurses.sh
    _siu::prepare_install::ncurses
    _siu::log::info "Finished preparing ncurses install"
}

function _siu::install::zsh()
{
    # checking dependencies
    _siu::check::dependency::critical make
    _siu::check::dependency::ncurses

    # install all missing dependencies
    for dependency in "${missing_dependencies[@]}"; do
        _siu::log::info "Installing missing dependency: ${dependency}"
        . "deps/install_${dependency}.sh"
        "_siu::install::${dependency}"
        _siu::check::return_code "An unexpected error happened during the installation of dependency: $dependency"
    done

    # untar zsh archive into a directory named zsh
    # (by default, untarring the archive gives a zsh directory containing the whole version number)
    mkdir zsh
    _siu::check::return_code "Could not create zsh directory."
    tar -xvf archives/zsh.tar.xz -C zsh --strip-components 1
    _siu::check::return_code "Could not untar archive. Stopping installation." "Untarred archive."

    pushd zsh || {
        _siu::log::error "Could not pushd into zsh directory. Stopping installation."
        exit 1
    }

    ./configure --prefix="${SIU_DIR}" CPPFLAGS=-I"${SIU_DEPS_DIR}"/include LDFLAGS=-L"${SIU_DEPS_DIR}"/lib
    _siu::check::return_code "\"./configure\" did not work. Stopping installation."

    make -j8
    _siu::check::return_code "\"make\" did not work. Stopping installation."

    make install
    _siu::check::return_code "\"make install\" did not work. Stopping installation."
    popd || {
        _siu::log::error "Could not popd out of zsh directory. Stopping installation."
        exit 1
    }
}
