#!/bin/bash

# stop at first error/exit
# set -e

SIUUU_DIR=$HOME/.siuuu
DEPS_DIR=$SIUUU_DIR/deps

INCLUDE_NCURSES=/usr/include

check_return_code()
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

check_ncurses_installed()
{
    # Check if ncurses is installed at:
    # /usr/include/ncurses/ncurses.h
    # /usr/include/ncursesw/ncurses.h
    echo "checking for ncurses... "
    if [[ -f $INCLUDE_NCURSES/ncurses/ncurses.h && -f $INCLUDE_NCURSES/ncursesw/ncurses.h ]]; then
        echo -n "ok"
        return
    fi

    echo "no"
    echo "Installing ncurses from source."
    install_ncurses
    INCLUDE_NCURSES=$DEPS_DIR/include
}

check_make_installed()
{
    echo "checking for make... "
    make --version
    check_return_code "make is not installed. Stopping installation."
    echo -n "ok"
}

install_ncurses()
{
    mkdir -p $DEPS_DIR
    pushd $DEPS_DIR

    # get ncurses archive
    wget https://invisible-island.net/archives/ncurses/ncurses.tar.gz
    check_return_code "ncurses install: could not download archive. Stopping installation."

    mkdir ncurses
    check_return_code
    tar -xvf ncurses.tar.gz -C ncurses --strip-components 1
    check_return_code "ncurses install: could not untar archive. Stopping installation."

    cd ncurses
    ./configure --prefix=$DEPS_DIR --with-shared --enable-widec
    check_return_code "zsh install: \"./configure\" did not work. Stopping installation."

    make -j8
    check_return_code "zsh install: \"make\" did not work. Stopping installation."

    make install
    check_return_code "zsh install: \"make install\" did not work. Stopping installation."
    popd
}

install_zsh()
{
    mkdir -p $SIUUU_DIR
    cd $SIUUU_DIR

    # checking dependencies
    check_make_installed
    check_ncurses_installed

    # download archive, should create an archive named zsh.tar.xz
    if [[ 1 -eq 1 ]]; then
        wget -O zsh.tar.xz https://sourceforge.net/projects/zsh/files/latest/download
        check_return_code "zsh install: could not download archive. Stopping installation."
    fi
    mkdir zsh
    check_return_code
    tar -xvf zsh.tar.xz -C zsh --strip-components 1
    check_return_code "zsh install: could not untar archive. Stopping installation."

    cd zsh

    ./configure --prefix=$SIUUU_DIR CPPFLAGS=-I$DEPS_DIR/include LDFLAGS=-L$DEPS_DIR/lib
    check_return_code "zsh install: \"./configure\" did not work. Stopping installation."

    make -j8
    check_return_code "zsh install: \"make\" did not work. Stopping installation."

    make install
    check_return_code "zsh install: \"make install\" did not work. Stopping installation."
}


install_zsh
