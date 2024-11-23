#!/bin/bash

declare -A tools_installed

#######################################
# Get configuration directory.
# Globals
#   SIU_TOOL_VERSIONS
# Arguments:
#   Name of the tool
#   Version of the tool
# Outputs:
#   Writes tool and version to the file SIU_TOOL_VERSIONS
#######################################
function _siu::versioning::create_file() {
    if [[ ! -f ${SIU_TOOL_VERSIONS} ]]; then
        touch "${SIU_TOOL_VERSIONS}"
    fi
}

#######################################
# Read all tools from the versioning file.
# Globals:
#   tools_installed (associative array)
# Arguments:
#   None.
# Outputs:
#   Logging information.
# Returns:
#   0 if all tools could be read,
#   1 if not,
#######################################
function _siu::versioning::read_tools() {
    if [[ ! -f ${SIU_TOOL_VERSIONS} ]]; then
        return 0
    fi

    while IFS='=' read -r key val; do
        tools_installed["$key"]="$val"
    done < "${SIU_TOOL_VERSIONS}"

    unset IFS
}

#######################################
# Set or update the version of the tool.
# Globals:
#   SIU_TOOL_VERSIONS
# Arguments:
#   Name of the tool to set/update.
#   New version of the tool.
# Outputs:
#   Logging information.
# Returns:
#   0 if version was set/updated,
#   1 if not,
#   2 if file SIU_TOOL_VERSIONS does not exist
#######################################
function _siu::versioning::set_tool_version() {
    if [[ "$#" -lt 1 ]]; then
        _siu::log::error "Missing argument: name of the tool to set/update."
        return 1
    fi

    _siu::versioning::create_file

    if ! grep -E "^$1=.*" "${SIU_TOOL_VERSIONS}" > /dev/null; then

        echo "$1=$2" >> "${SIU_TOOL_VERSIONS}"
        _siu::log::info "Successfully set tool \"$1=$2\" in versioning."
        return 0
    fi

    sed -i -r "s/^$1=.*/$1=$2/g" "${SIU_TOOL_VERSIONS}" || {
        _siu::log::error "Could not update tool \"$1\" in versioning."
        return 1
    } && _siu::log::info "Successfully updated tool \"$1=$2\" in versioning."
}

#######################################
# Delete a tool in the versioning file.
# Globals:
#   SIU_TOOL_VERSIONS
# Arguments:
#   Name of the tool to delete.
# Outputs:
#   Logging information.
# Returns:
#   0 if tool was deleted,
#   1 if not,
#   2 if file SIU_TOOL_VERSIONS does not exist
#######################################
function _siu::versioning::delete_tool() {
    if [[ ! -f ${SIU_TOOL_VERSIONS} ]]; then
        _siu::log::error "Versioning file ${SIU_TOOL_VERSIONS} does not exist."
        return 2
    fi

    sed -i -r "/^$1=.*$/d" "${SIU_TOOL_VERSIONS}" || {
        _siu::log::error "Could not delete tool \"$1\" from versioning."
        return 1
    } && _siu::log::info "Successfully deleted tool \"$1\" from versioning."
}

#######################################
# Compare two versions using format X.X.X
# Arguments:
#   <version1> first version to compare
#   <operator> the operator to use, in [-eq,-ne,-ge,-gt,-le,-lt]
#   <version2> second version to compare
# Returns:
#   0 if <version1> <operator> <version2>,
#   1 if not,
#   2 if there is not enough parameters
#   3 if a parameter format is wrong
#######################################
function _siu::versioning::compare_versions() {
    if [[ "$#" -lt 3 ]]; then
        return 2
    fi
    local version1 operator version2 op1 op2 same_versions
    version1=$1
    operator=$2
    version2=$3
    if [[ ! "${version1}" =~ ^[0-9]+[.][0-9]+[.][0-9]+$ ]]; then
        _siu::log::error "Bad parameter format: version1=\"${version1}\""
        return 3
    fi
    if [[ ! "${version2}" =~ ^[0-9]+[.][0-9]+[.][0-9]+$ ]]; then
        _siu::log::error "Bad parameter format: version2=\"${version2}\""
        return 3
    fi

    same_versions=$([[ "${version1}" == "${version2}" ]] && echo 0 || echo 1)
    case "${operator}" in
        -eq) [[ "${same_versions}" -eq 0 ]] && return 0 || return 1;;
        -ge|-le) [[ "${same_versions}" -eq 0 ]] && return 0;;
        -ne) [[ "${same_versions}" -eq 0 ]] || return 0 && return 1;;
        -gt|-lt) [[ "${same_versions}" -eq 0 ]] && return 1;;
        *)
            _siu::log::error "Bad parameter format: operator=\"${operator}\""
            return 3
            ;;
    esac

    for i in {1..3}; do
        op1=$(echo "${version1}" | cut -d"." -f"${i}")
        op2=$(echo "${version2}" | cut -d"." -f"${i}")
        if eval "[[ ${op1} ${operator} ${op2} ]]"; then
            return 0
        fi
    done

    return 1
}
