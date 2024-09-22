#!/bin/bash

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
#   If not installed, will add it to the array missing_dependencies (that have to be built from source).
check::dependency::ncurses()
{
    echo -n "checking for ncurses..."
    if [[ -f /usr/include/ncurses/ncurses.h || -f /usr/include/ncursesw/ncurses.h ]]; then
        echo "ok"
        return
    fi

    echo "no"
    missing_dependencies=("${missing_dependencies[@]}" "ncurses")
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
    fi
    dep="$1"
    echo -n "checking for ${dep}..."
    $dep --version &>/dev/null
    check::return_code "no\n${dep} is not installed. Stopping installation." "ok"
}

# check::dependency::required <software_name>
#   Check if a software is installed. 
#   This software is required for an installation, and will be installed if missing.
#   The verification is made using the `--version` option, so the checked software should implement this option.
# Arguments:
#   $1: name of the software (required)
check::dependency::required()
{
    if [[ $# -ne 1 ]]; then
        echo "$(func_name): Missing argument: name of the dependency to check."
        exit 1
    fi
    dep="$1"
    echo -n "checking for ${dep}..."
    if [[ $($dep --version &>/dev/null) -eq 0 ]]; then
        echo "ok"
    else
        echo "no"
        echo "Adding \"${dep}\" to the array missing_dependencies."
        missing_dependencies=("${missing_dependencies[@]}" "${dep}")
    fi
}
