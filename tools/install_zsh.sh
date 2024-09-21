#!/bin/bash

source env_siu.sh
source utils/check_utils.sh

install::zsh()
{
    # checking dependencies
    check::dependency::critical make
    check::dependency::ncurses

    # install all missing dependencies
    for dependency in "${missing_dependencies[@]}"; do
        source "deps/install_${dependency}.sh"
        "install::${dependency}"
        check::return_code "An unexpected error happened during the installation of dependency: $dependency"
    done

    # download archive, should create an archive named zsh.tar.xz
    if [[ 1 -eq 1 ]]; then
        wget -O zsh.tar.xz https://sourceforge.net/projects/zsh/files/latest/download
        check::return_code "zsh install: could not download archive. Stopping installation."
    fi
    mkdir zsh
    check::return_code
    tar -xvf zsh.tar.xz -C zsh --strip-components 1
    check::return_code "zsh install: could not untar archive. Stopping installation."

    pushd zsh

    ./configure --prefix=$SIU_DIR CPPFLAGS=-I$SIU_DEPS_DIR/include LDFLAGS=-L$SIU_DEPS_DIR/lib
    check::return_code "zsh install: \"./configure\" did not work. Stopping installation."

    make -j8
    check::return_code "zsh install: \"make\" did not work. Stopping installation."

    make install
    check::return_code "zsh install: \"make install\" did not work. Stopping installation."
    popd
}
