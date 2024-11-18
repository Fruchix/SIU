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
function _siu::versioning::create() {
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

    if [[ ! -f ${SIU_TOOL_VERSIONS} ]]; then
        touch "${SIU_TOOL_VERSIONS}"
    fi

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
