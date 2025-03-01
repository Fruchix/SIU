#!/usr/bin/env bash

#######################################
# Check if a tool is installed.
# Globals:
#   tools_installed (associative array)
#   SIU_TOOL_VERSIONS (filename): file in which to store siu's versioning
# Arguments:
#   tool: Name of the tool to check.
# Outputs:
#   Logging information.
# Returns:
#   0 if the tool is already installed,
#   1 else
#######################################
function _siu::core::is_installed()
{
    local tool="$1"
    _siu::versioning::read_tools "${SIU_TOOL_VERSIONS}"

    if [[ -v tools_installed["${tool}"] ]]; then
        _siu::log::info "${tool} is installed using SIU."
        return 0
    fi

    # if custom installation check command is provided for this tool then use it
    if _siu::check::command_exists "_siu::check_installed::${tool}" && "_siu::check_installed::${tool}"; then
        return 0
    fi

    # else check if the tool is accessible from the user's environment
    _siu::check::command_exists "${tool}"
}

#######################################
# Check the dependencies of the selected tools, and add them to
# the installation if missing. Remove already installed tools.
# Globals:
#   tools (array)
# Arguments:
#   None
# Outputs:
#   Logging information.
# Returns:
#   0 if the function succeeded
#######################################
function _siu::core::check_dependencies()
{
    _siu::log::info "Starting checking dependencies."

    eval $(parse_yaml src/deps/utilities.yaml "siutools_")
    eval $(parse_yaml src/tools/utilities.yaml "siutools_")

    _siu::check::tools_dependencies
    _siu::log::info "Finished checking dependencies."
    if [[ ${#tools[@]} -eq 0 ]]; then
        _siu::log::info "No tools are selected."
        exit 0
    else
        _siu::log::info "The following tools are selected: ${tools[*]}."
    fi
}

#######################################
# Prepare the installation of each selected tool.
# Downloads archives/sources and clones git repositories.
# Globals:
#   tools (array): tools to install. Each tool should
#                  have an existing installation script.
# Arguments:
#   None
# Outputs:
#   Logging information.
# Returns:
#   0 if the function succeeded
#######################################
function _siu::core::prepare_install()
{
    _siu::core::check_dependencies

    _siu::log::info "Starting preparing SIU install."

    if [[ ${#tools[@]} -eq 0 ]]; then
        _siu::log::info "No tools to prepare for installation. Stopping installation."
        exit 0
    else
        _siu::log::info "The following tools will be prepared for installation: ${tools[*]}."
    fi

    if [[ -z "${SIU_SOURCES_DIR+x}" ]]; then
        _siu::log::error "Global variable 'SIU_SOURCES_DIR' must be set and not empty."
        exit 1
    fi

    if [[ "${FORCE_INSTALL}" -eq 1 ]]; then
        # clean directory
        rm -rf "${SIU_SOURCES_DIR}"
        mkdir -p "${SIU_SOURCES_DIR}"
    fi

    for tool in "${tools[@]}"; do
        _siu::log::info "Starting preparing ${tool} install"

        # specific sources directory for the current tool
        SIU_SOURCES_DIR_CURTOOL="${SIU_SOURCES_DIR}/${tool:?}"

        # only download source when it does not exist, or with force install activated, or in update mode
        if [[ ! -d "${SIU_SOURCES_DIR_CURTOOL}" || "${FORCE_INSTALL}" -eq 1 || "${MODE}" == "UPDATE" ]]; then
            rm -rf "${SIU_SOURCES_DIR_CURTOOL}"
            mkdir -p "${SIU_SOURCES_DIR_CURTOOL}"

            "_siu::prepare_install::${tool}"
            _siu::log::info "Finished preparing ${tool} install"
        fi
    done
    _siu::log::info "Finished preparing SIU install."
}

#######################################
# Install each selected tool.
# Globals:
#   tools (array): tools to install. Each tool should
#                  have an existing installation script.
#   SIU_TOOL_VERSIONS (filename): file in which to store siu's versioning
# Arguments:
#   None
# Outputs:
#   Logging information.
# Returns:
#   0 if the function succeeded
function _siu::core::install()
{
    _siu::core::prepare_install

    _siu::log::info "Starting SIU install."

    if [[ ${#tools[@]} -eq 0 ]]; then
        _siu::log::info "No tools to install."
        exit 0
    else
        _siu::log::info "The following tools will be installed: ${tools[*]}."
    fi

    local tmp_dir=$(mktemp -d)
    pushd "${tmp_dir}" || {
        _siu::log::error "Could not pushd into '${tmp_dir}' temporary directory. Stopping installation."
        exit 1
    }

    for tool in "${tools[@]}"; do
        _siu::log::info "Starting ${tool} install."

        # create utility directory
        mkdir -p "${SIU_UTILITIES_DIR}/${tool:?}"

        # specific sources directory for the current tool
        SIU_SOURCES_DIR_CURTOOL="${SIU_SOURCES_DIR}/${tool:?}"

        # creating a work directory, where all files are outputed/processed/compiled
        mkdir -p "${tool}"
        pushd "${tool}" || {
            _siu::log::error "Could not pushd into '$PWD/${tool}' directory. Stopping installation."
            exit 1
        }

        "_siu::install::${tool}"
        _siu::versioning::set_tool_version "${SIU_TOOL_VERSIONS}" "${tool}" "$("_siu::get_latest_version::${tool}")"

        popd || {
            _siu::log::error "Could not popd out of '${PWD}' directory. Stopping installation."
            exit 1
        }
        _siu::log::info "Finished ${tool} install."
    done

    popd || {
        _siu::log::error "Could not popd out of '${tmp_dir}' temporary directory. Stopping installation."
        exit 1
    }
    _siu::log::info "Finished SIU install."
}

#######################################
# Uninstall each selected tool.
# Globals:
#   tools (array): tools to uninstall. Each tool should have an
#                  existing installation script and be installed.
# Arguments:
#   None
# Outputs:
#   Logging information.
# Returns:
#   0 if the function succeeded
function _siu::core::uninstall()
{
    _siu::log::info "Starting SIU uninstall."

    if [[ ${#tools[@]} -eq 0 ]]; then
        _siu::log::info "No tools to uninstall."
        exit 0
    else
        _siu::log::info "The following tools will be uninstalled: ${tools[*]}."
    fi

    for tool in "${tools[@]}"; do
        _siu::log::info "Starting ${tool} uninstallation."
        "_siu::uninstall::${tool}"
        _siu::check::return_code "Could not uninstall '${tool}'. Keeping it in the versioning but proceeding with the uninstallation process." "Successfully uninstalled '${tool}'." --no-exit
        if [[ $? -ne 0 ]] ; then
            continue
        fi

        _siu::versioning::delete_tool "${SIU_TOOL_VERSIONS}" "${tool}"
        _siu::check::return_code "Could not remove '${tool}' from the versioning. Stopping uninstallation." "Successfully removed '${tool}' from versioning."
        _siu::log::info "Finished ${tool} uninstallation."
    done

    # remove all broken symlinks (symlinks referencing binaries, manpages, etc. that we just removed)
    local broken_symlinks=( $(find -L "${SIU_DIR}" -type l) )
    for bl in "${broken_symlinks[@]}"; do
        _siu::log::info "Unlinking ${bl}."
        unlink "${bl}"
    done
    _siu::log::info "Finished SIU uninstall."
}

#######################################
# Check the latest available version of each installed tool.
# Writes all latest versions in the file SIU_TOOL_VERSIONS_UPDATE
# Globals:
#   SIU_TOOL_VERSIONS_UPDATE
# Arguments:
#   None
# Outputs:
#   Logging information.
# Returns:
#   0 if the function succeeded
#######################################
function _siu::core::check_update()
{
    # TODO:
    # Read all installed tools from the file SIU_TOOL_VERSIONS
    # For each tool, get the latest version and write it to 
    # SIU_TOOL_VERSIONS_UPDATE if different/superior to the current version.
    pass
}

#######################################
# Update all installed tools to the versions in the
# SIU_TOOL_VERSIONS_UPDATE file. Needs to be run after update.
# Globals:
#   SIU_TOOL_VERSIONS_UPDATE
# Arguments:
#   None
# Outputs:
#   Logging information.
# Returns:
#   0 if the function succeeded
#######################################
function _siu::core::update()
{
    # TODO:
    # Read SIU_TOOLS_VERSIONS_UPDATE
    # For each tool, apply the update method
    pass
}
