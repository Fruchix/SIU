#!/usr/bin/env bash

function _siu::get_latest_version::zsh()
{
    local latest_version
    if latest_version="0.0.0"; then
        echo "${latest_version}"
    else
        return 1
    fi
}

function _siu::prepare_install::zsh()
{
    # download archive, should create an archive named zsh.tar.xz
    wget -O "${SIU_SOURCES_DIR_CURTOOL}/zsh.tar.xz" https://sourceforge.net/projects/zsh/files/latest/download
    _siu::check::return_code "Could not download archive. Stopping installation preparation." "Downloaded latest zsh archive from https://sourceforge.net/projects/zsh/files/latest/download."

    # in case we need it, download ncurses dependency
    _siu::log::info "Starting preparing ncurses install"
    _siu::prepare_install::ncurses
    _siu::log::info "Finished preparing ncurses install"
}

function _siu::install::zsh()
{
    mkdir zsh_build
    # (by default, untarring the archive gives a zsh directory containing the whole version number)
    tar -xvf "${SIU_SOURCES_DIR_CURTOOL}/zsh.tar.xz" -C zsh_build --strip-components 1
    _siu::check::return_code "Could not untar archive. Stopping installation." "Untarred archive."

    pushd zsh_build || {
        _siu::log::error "Could not pushd into '$PWD/zsh_build' directory. Stopping installation."
        exit 1
    }

    ./configure --prefix="${SIU_UTILITIES_DIR}/zsh" CPPFLAGS=-I"${SIU_DEPS_DIR}"/include LDFLAGS=-L"${SIU_DEPS_DIR}"/lib
    _siu::check::return_code "\"./configure\" did not work. Stopping installation."

    make -j8
    _siu::check::return_code "\"make\" did not work. Stopping installation."

    make install
    _siu::check::return_code "\"make install\" did not work. Stopping installation."

    # create symlinks
    for f in "${SIU_UTILITIES_DIR}"/zsh/bin/*; do
        ln -s "$(realpath "${f}")" "${SIU_BIN_DIR}/${f##*/}"
    done
    for f in "${SIU_UTILITIES_DIR}"/zsh/share/man/man1/*; do
        ln -s "$(realpath "${f}")" "${SIU_MAN_DIR}/man1/${f##*/}"
    done
    popd || {
        _siu::log::error "Could not popd out of '$PWD/zsh_build' directory. Stopping installation."
        exit 1
    }
}

function _siu::uninstall::zsh() {
    local retcode=0
    rm -rf "${SIU_UTILITIES_DIR:?}/zsh"
    _siu::check::return_code "Could not remove zsh directory from ${SIU_UTILITIES_DIR}/." "Removed zsh directory from ${SIU_UTILITIES_DIR}/" --no-exit retcode
    return $retcode
}