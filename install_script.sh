#!/bin/bash

SIU_DIR=$HOME/.siu
DEPS_DIR=$SIU_DIR/deps

missing_dependencies=()

check::return_code()
{
    if [[ $? -ne 0 ]]; then
        if [[ $# -gt 0 ]]; then
            echo -e "$1"
        fi
        exit 1
    else
        if [[ $# -gt 1 ]]; then
            echo -e "$2"
        fi
    fi
}

check::zsh_depency::ncurses()
{
    # Check if ncurses is installed at:
    # /usr/include/ncurses/ncurses.h
    # /usr/include/ncursesw/ncurses.h
    echo -n "checking for ncurses... "
    if [[ -f /usr/include/ncurses/ncurses.h || -f /usr/include/ncursesw/ncurses.h ]]; then
        echo "ok"
        true
        return
    fi

    echo "no"
    missing_dependencies=($missing_dependencies "ncurses")
    false
}

check::zsh_depency::make()
{
    echo -n "checking for make... "
    make --version 2&>1 /dev/null
    check::return_code "make is not installed. Stopping installation."
    echo "ok"
    true
}

install::ncurses()
{
    echo "Installing ncurses from source."

    mkdir -p $DEPS_DIR
    pushd $DEPS_DIR

    # get ncurses archive
    wget https://invisible-island.net/archives/ncurses/ncurses.tar.gz
    check::return_code "ncurses install: could not download archive. Stopping installation."

    mkdir ncurses
    check::return_code
    tar -xvf ncurses.tar.gz -C ncurses --strip-components 1
    check::return_code "ncurses install: could not untar archive. Stopping installation."

    cd ncurses
    ./configure --prefix=$DEPS_DIR --with-shared --enable-widec
    check::return_code "ncurses install: \"./configure\" did not work. Stopping installation."

    make -j8
    check::return_code "ncurses install: \"make\" did not work. Stopping installation."

    make install
    check::return_code "ncurses install: \"make install\" did not work. Stopping installation."
    popd

    true
}

install::zsh()
{
    mkdir -p $SIU_DIR
    cd $SIU_DIR

    # checking dependencies
    check::zsh_depency::make
    check::zsh_depency::ncurses

    # install all missing dependencies
    for depency in "${missing_dependencies[@]}"; do
        "install::$depency"
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

    cd zsh

    ./configure --prefix=$SIU_DIR CPPFLAGS=-I$DEPS_DIR/include LDFLAGS=-L$DEPS_DIR/lib
    check::return_code "zsh install: \"./configure\" did not work. Stopping installation."

    make -j8
    check::return_code "zsh install: \"make\" did not work. Stopping installation."

    make install
    check::return_code "zsh install: \"make install\" did not work. Stopping installation."

    true
}

install::zsh
