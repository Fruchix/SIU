#!/usr/bin/env bash

# _siu::arch::get_yaml_info
#   Get the arch information about a tool, stored in utilities.yaml files.
#
#   Global
#       arch: selected architecture, should be either x86_64 or aarch64
#   Arguments:
#       tool: name of the tool or deps for which to get the arch information
#   Returns:
#       The associated information from a yaml file.
_siu::arch::get_yaml_info() {
    local tool=$1

    eval $(parse_yaml src/deps/utilities.yaml "siutools_")
    eval $(parse_yaml src/tools/utilities.yaml "siutools_")

    local arch_field="siutools_${tool}_arch_${arch}"

    if [[ -z "${arch_field-x}" ]]; then
        _siu::log::debug "$arch_field is not set."
        return 0
    fi
    _siu::log::debug "$arch_field is set to '${!arch_field}'."
    echo "${!arch_field}"
}