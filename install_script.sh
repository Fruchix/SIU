#!/bin/bash

SIU_DIR=$HOME/.siu
DEPS_DIR=$SIU_DIR/deps
SIU_ZSHRC=$SIU_DIR/siu_zshrc

missing_dependencies=()

func_name () {
    if [[ -n $BASH_VERSION ]]; then
        printf "%s\n" "${FUNCNAME[1]}"
    else  # zsh
        # Use offset:length as array indexing may start at 1 or 0
        printf "%s\n" "${funcstack[@]:1:1}"
    fi
}

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

# check::dependency::ncurses
#   Check if ncurses is installed, required by zsh.
#   Check whether one of these two header files exists:
#       /usr/include/ncurses/ncurses.h
#       /usr/include/ncursesw/ncurses.h
#   If not installed, will add it to the list of missing dependencies that have to be built from source.
check::dependency::ncurses()
{
    echo -n "checking for ncurses... "
    if [[ -f /usr/include/ncurses/ncurses.h || -f /usr/include/ncursesw/ncurses.h ]]; then
        echo "ok"
        return
    fi

    echo "no"
    missing_dependencies=($missing_dependencies "ncurses")
}

# check::dependency::critical <software_name>
#   Check if a software is installed. 
#   This software is critical for an installation, and won't be installed using by those scripts.
#   The absence of it will cause the program to stop.
#   The verification is made using the `--version` option, so the checked software should implement this option.
# Arguments:
#   $1: name of the software (required)
check::dependency::critical()
{
    if [[ $# -ne 1 ]]; then
        echo "$(func_name): Missing argument: name of the dependency to check."
        exit 1
        return
    fi
    dep="$1"
    echo -n "checking for ${dep}..."
    $dep --version &>/dev/null
    check::return_code "no\n${dep} is not installed. Stopping installation." "ok"
}

init::siu_dirs()
{
    mkdir -p $SIU_DIR
    mkdir -p $DEPS_DIR
}

init::siu_zshrc()
{
    echo "export SIU_DIR=${SIU_DIR}" >> "${SIU_ZSHRC}"
    cat << "EOF" >> "${SIU_ZSHRC}"
export SIU_ZSHRC=$SIU_DIR/siu_zshrc

export PATH=$PATH:$SIU_DIR/bin
EOF
}

init::siu()
{
    echo "source $SIU_ZSHRC" >> ~/.zshrc
    echo "export SIU_DIR=$SIU_DIR" >> ~/.bashrc
    echo 'export PATH=$PATH:$SIU_DIR/bin' >> ~/.bashrc

    init::siu_dirs
    init::siu_zshrc
}


install::ncurses()
{
    echo "Installing ncurses from source."

    # get ncurses archive
    wget https://invisible-island.net/archives/ncurses/ncurses.tar.gz
    check::return_code "ncurses install: could not download archive. Stopping installation."

    mkdir ncurses
    check::return_code
    tar -xvf ncurses.tar.gz -C ncurses --strip-components 1
    check::return_code "ncurses install: could not untar archive. Stopping installation."

    pushd ncurses
    ./configure --prefix=$DEPS_DIR --with-shared --enable-widec
    check::return_code "ncurses install: \"./configure\" did not work. Stopping installation."

    make -j8
    check::return_code "ncurses install: \"make\" did not work. Stopping installation."

    make install
    check::return_code "ncurses install: \"make install\" did not work. Stopping installation."
    popd
}

install::zsh()
{
    # checking dependencies
    check::dependency::critical make
    check::dependency::ncurses

    # install all missing dependencies
    for dependency in "${missing_dependencies[@]}"; do
        "install::$dependency"
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

    ./configure --prefix=$SIU_DIR CPPFLAGS=-I$DEPS_DIR/include LDFLAGS=-L$DEPS_DIR/lib
    check::return_code "zsh install: \"./configure\" did not work. Stopping installation."

    make -j8
    check::return_code "zsh install: \"make\" did not work. Stopping installation."

    make install
    check::return_code "zsh install: \"make install\" did not work. Stopping installation."
    popd
}

install::pure()
{
    check::dependency::critical git

    git clone https://github.com/sindresorhus/pure.git "$SIU_DIR/pure"
    check::return_code "pure install: \"git clone\" dit not work. Stopping installation."

    cat << "EOF" >> $SIU_ZSHRC

### Automaticaly added by SIU::pure ###
fpath+=($SIU_DIR/pure)              ### SIU::pure
### Automaticaly added by SIU::pure ###
EOF
}

uninstall::pure()
{
    rm -rf $SIU_DIR/pure
    sed -i '/SIU::pure/d' $SIU_ZSHRC
}

init::siu
install::zsh
install::pure
