#!/usr/bin/env bash

# _siu::check::return_code [error_message] [succeed_message] [--no-exit [variable_name]]
#   Check if a command succeeded.
# 
#   Arguments:
#       $1: message to log if the command failed. Will be logged with log-level "ERROR". (optional)
#       $2: message to log if the command succeeded. Will be logged with log-level "INFO". (optional)
#       $3: Only one value is accepted:
#           --no-exit: if the function should just fail instead of exitting the program (optional, will exit by default)
#       $4: Name of the variable to increment by the value of the return code if option "--no-exit" is used and the return code is non zero
function _siu::check::return_code()
{
    _siu_check_return_code_retcode=$?
    _siu::log::debug "$_siu_check_return_code_retcode"
    # if last command did not succeed, 
    # then print an error message if provided and exit (or return)
    # else print a succeed message if provided
    if [[ $_siu_check_return_code_retcode -ne 0 ]]; then
        if [[ $# -gt 0 ]]; then
            if [[ "$3" == "--no-exit" ]]; then
                _siu::log::warning "$1" 1
            else
                _siu::log::error "$1" 1
            fi
        fi

        if [[ "$3" == "--no-exit" ]]; then
            if [[ $# -gt 3 ]]; then
                (("$4"+=_siu_check_return_code_retcode))
            fi
                
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
# 
#   Arguments:
#       $1: the command to check, without any option (required)
function _siu::check::command_exists()
{
    command -v "$1" >/dev/null 2>&1
}

# _siu::check::tools_dependencies_worker <dep>
#   Recursive worker for "_siu::check::tools_dependencies".
#   Check if the provided dependency/tool is installed, and check its own dependencies recursively if not.
#   If a missing dependency can't be installed (an external dependency), exit the program.
# 
#   Global
#       FORCE_INSTALL
#       TOOLSET
#   Arguments:
#       $1: name of the dependency to check
#   Returns:
#       None. The "tools" array now contains every dependency that needs to be installed before any the provided dependency.
function _siu::check::tools_dependencies_worker()
{
    if [[ "$#" -lt 1 ]]; then
        _siu::log::warning "Missing argument: <dep> (dependency to check)."
        return
    fi

    local var_name list_deps

    # checking each dependency that should already be installed on the system:
    # if a dependency is missing then stop the installation
    var_name="siutools_${1}_dependencies_external_"
    if [[ -n "${!var_name}" ]]; then
        read -a list_deps <<< "${!var_name}"
        for dep in "${list_deps[@]}"; do
            _siu::check::command_exists "${!dep}"
            _siu::check::return_code "[${1}] Checking for external dependency \"${!dep}\": not installed. Stopping installation." "[${1}] Checking for external dependency \"${!dep}\": ok."
        done
    fi

    # checking each dependency that can be installed by our scripts:
    # if a dependency is missing then add the dependency in the list of tools to install (before the dependant tool)
    var_name="siutools_${1}_dependencies_managed_"
    if [[ -n "${!var_name}" ]]; then
        read -a list_deps <<< "${!var_name}"
        for dep in "${list_deps[@]}"; do
            # if this dependency is already in the list of tools to install, skip checks
            if [[ "${tools[*]}" =~ ${!dep} ]];then
                continue
            fi
            _siu::core::is_installed "${!dep}"
            _siu::check::return_code "[${1}] Checking for managed dependency \"${!dep}\": not installed. Adding \"${!dep}\" to the list of tools to install." "[${1}] Checking for managed dependency \"${!dep}\": ok." --no-exit
            # if the dependency is missing 
            # then check its own dependencies recursively
            if [[ "$?" -ne 0 ]]; then
                _siu::check::tools_dependencies_worker "${!dep}"
            fi
        done
    fi

    # add the current tool to the list of tools to install only if it is not already in it and if it is not installed
    # if it is installed but we are forcing the installation of all selected tools using SIU, then add it to the list
    if [[ ! "${tools[*]}" =~ ${1} ]];then
        if [[ "${FORCE_INSTALL}" -eq 1 || "${TOOLSET}" == "ALL" ]] || ! _siu::core::is_installed "${1}"; then
            tools=("${tools[@]}" "${1}")
        fi
    fi
}

# _siu::check::tools_dependencies
#   Check the dependencies for all tools contained in the "tools" array, recursively.
#   Add the missing dependencies to the "tools" array, before there dependant tool.
#   If a missing dependency can't be installed (an external dependency), exit the program.
#   parse_yaml should have been sourced.
# 
#   Example: this function will transform "tools=(fzf omz)" into "tools=(fzf ncurses zsh omz)" if zsh and ncurses are not installed
# 
#   Returns:
#       None. The "tools" array now contains every dependency that needs to be installed before each tool.
function _siu::check::tools_dependencies()
{
    local tmp_tools

    tmp_tools=("${tools[@]}")
    tools=()
    for t in "${tmp_tools[@]}"; do
        # recursive worker
        _siu::check::tools_dependencies_worker "${t}"
    done
}
