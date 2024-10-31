#!/bin/bash

source env_siu.sh
source utils/check_utils.sh

function _siu::prepare_install::zsh()
{
    _siu::check::dependency::critical wget

    # download archive, should create an archive named zsh.tar.xz
    wget -O archives/zsh.tar.xz https://sourceforge.net/projects/zsh/files/latest/download
    _siu::check::return_code "zsh prepare_install: could not download archive. Stopping installation preparation."

    source deps/install_ncurses.sh
    _siu::prepare_install::ncurses
}

function _siu::install::zsh()
{
    # checking dependencies
    _siu::check::dependency::critical make
    _siu::check::dependency::ncurses

    # install all missing dependencies
    for dependency in "${missing_dependencies[@]}"; do
        source "deps/install_${dependency}.sh"
        "_siu::install::${dependency}"
        _siu::check::return_code "An unexpected error happened during the installation of dependency: $dependency"
    done

    mkdir zsh
    _siu::check::return_code
    tar -xvf archives/zsh.tar.xz -C zsh --strip-components 1
    _siu::check::return_code "zsh install: could not untar archive. Stopping installation."

    pushd zsh || return

    ./configure --prefix="${SIU_DIR}" CPPFLAGS=-I"${SIU_DEPS_DIR}"/include LDFLAGS=-L"${SIU_DEPS_DIR}"/lib
    _siu::check::return_code "zsh install: \"./configure\" did not work. Stopping installation."

    make -j8
    _siu::check::return_code "zsh install: \"make\" did not work. Stopping installation."

    make install
    _siu::check::return_code "zsh install: \"make install\" did not work. Stopping installation."
    popd || return
}
