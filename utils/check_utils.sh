#!/bin/bash

# _siu::check::return_code [error_message] [succeed_message] [--no-exit]
#   Check if a command succeeded.
# Arguments:
#   $1: message to log if the command failed. Will be logged with log-level "ERROR". (optional)
#   $2: message to log if the command succeeded. Will be logged with log-level "INFO". (optional)
#   $3: Only one value is accepted:
#       --no-exit: if the function should just fail instead of exitting the program (optional, will exit by default)
function _siu::check::return_code()
{
    # if last command did not succeed, 
    # then print an error message if provided and exit (or return)
    # else print a succeed message if provided
    if [[ $? -ne 0 ]]; then
        if [[ $# -gt 0 ]]; then
            if [[ "$3" == "--no-exit" ]]; then
                _siu::log::warning "$1" 1
            else
                _siu::log::error "$1" 1
            fi
        fi

        if [[ "$3" == "--no-exit" ]]; then
            return 1
        else
            exit 1
        fi
    else
        if [[ $# -gt 1 ]]; then
            _siu::log::info "$2" 1
        fi
    fi
}

# _siu::check::command_exists <command>
#   Check if a command exists.
# Arguments:
#   $1: the command to check, without any option (required)
function _siu::check::command_exists()
{
    command -v "$1" >/dev/null 2>&1
}

# _siu::check::dependency::ncurses
#   Check if ncurses is installed, required by zsh.
#   Check whether one of these two header files exists:
#       /usr/include/ncurses/ncurses.h
#       /usr/include/ncursesw/ncurses.h
#   If not installed, will add it to the array missing_dependencies (that have to be built from source).
function _siu::check::dependency::ncurses()
{
    if [[ -f /usr/include/ncurses/ncurses.h || -f /usr/include/ncursesw/ncurses.h ]]; then
        _siu::log::info "Checking for depencendy \"ncurses\": ok"
        return
    fi

    _siu::log::warning "Checking for dependency \"ncurses\": not installed. Adding \"ncurses\" to the array \"missing_dependencies\"."
    missing_dependencies+=("ncurses")
}

# _siu::check::dependency::critical <software_name>
#   Check if a software is installed. 
#   This software is critical for an installation, and won't be installed using by those scripts.
#   The absence of it will cause the program to stop.
#   The verification is made using `command -v`.
# Arguments:
#   $1: name of the software (required)
function _siu::check::dependency::critical()
{
    if [[ $# -ne 1 ]]; then
        echo "$(func_name): Missing argument: name of the dependency to check."
        exit 1
    fi
    dep="$1"

    _siu::check::command_exists "${dep}"
    _siu::check::return_code "Checking for \"${dep}\": not installed. Stopping installation." "Checking for \"${dep}\": ok"
}

# _siu::check::dependency::required <software_name>
#   Check if a software is installed. 
#   This software is required for an installation, and will be installed if missing.
#   The verification is made using `command -v`.
# Arguments:
#   $1: name of the software (required)
function _siu::check::dependency::required()
{
    if [[ $# -ne 1 ]]; then
        echo "$(func_name): Missing argument: name of the dependency to check."
        exit 1
    fi
    dep="$1"

    _siu::check::command_exists "${dep}"
    _siu::check::return_code "Checking for \"${dep}\": not installed. Adding \"${dep}\" to the array \"missing_dependencies\"." "Checking for \"${dep}\": ok"
}
