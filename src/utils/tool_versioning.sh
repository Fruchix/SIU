#!/usr/bin/env bash

declare -A tools_installed

#######################################
# Read all tools from the versioning file.
# Globals:
#   tools_installed (associative array)
# Arguments:
#   <filename>: file from which to read the versioning.
# Outputs:
#   Logging information.
# Returns:
#   0 if all tools could be read,
#   1 if not,
#   2 if missing argument or file does not exist
#######################################
function _siu::versioning::read_tools() {
    if [[ "$#" -lt 1 ]]; then
        _siu::log::error "Missing argument: filename."
        return 2
    fi
    local filename=$1
    if [[ ! -f ${filename} ]]; then
        return 1
    fi

    while IFS='=' read -r key val; do
        tools_installed["$key"]="$val"
    done < "${filename}"

    unset IFS
}

#######################################
# Set or update the version of the tool.
# Arguments:
#   <filename>: File in which to write the versioning.
#   <tool>: Name of the tool to set/update.
#   <version>: New version of the tool.
# Outputs:
#   Logging information.
# Returns:
#   0 if version was set/updated,
#   1 if not,
#   2 if not enough arguments
#######################################
function _siu::versioning::set_tool_version() {
    if [[ "$#" -lt 3 ]]; then
        _siu::log::error "Missing argument(s)."
        return 2
    fi
    local filename=$1 tool=$2 version=$3

    if [[ ! -f ${filename} ]]; then
        touch "${filename}"
    fi

    if ! grep -E "^${tool}=.*" "${filename}" > /dev/null; then

        echo "${tool}=${version}" >> "${filename}"
        _siu::log::info "Successfully set tool \"${tool}=${version}\" in versioning."
        return 0
    fi

    sed -i -r "s/^${tool}=.*/${tool}=${version}/g" "${filename}" || {
        _siu::log::error "Could not update tool \"${tool}\" in versioning."
        return 1
    } && _siu::log::info "Successfully updated tool \"${tool}=${version}\" in versioning."
}

#######################################
# Delete a tool in the versioning file.
# Arguments:
#   <filename>: File in which to write the versioning.
#   <tool>: Name of the tool to delete.
# Outputs:
#   Logging information.
# Returns:
#   0 if tool was deleted,
#   1 if not,
#   2 if missing argument or file does not exist
#######################################
function _siu::versioning::delete_tool() {
    if [[ "$#" -lt 2 ]]; then
        _siu::log::error "Missing argument(s)."
        return 2
    fi
    local filename=$1 tool=$2
    if [[ ! -f ${filename} ]]; then
        _siu::log::error "Versioning file ${filename} does not exist."
        return 2
    fi

    sed -i -r "/^${tool}=.*$/d" "${filename}" || {
        _siu::log::error "Could not delete tool \"${tool}\" from versioning."
        return 1
    } && _siu::log::debug "Successfully deleted tool \"${tool}\" from versioning."
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
    local version1=$1 operator=$2 version2=$3 op1 op2 same_versions

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
