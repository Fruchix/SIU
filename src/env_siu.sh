#!/usr/bin/env bash

if [[ -z "${SIU_PREFIX+x}" && -z "${SIU_DIR+x}" ]]; then
    echo "SIU_PREFIX and SIU_DIR are both unset."
    return 0
fi

export SIU_DIR=${SIU_DIR-$SIU_PREFIX/.siu}

# directories
export SIU_BIN_DIR=$SIU_DIR/bin
export SIU_DEPS_DIR=$SIU_DIR/deps
export SIU_MAN_DIR=$SIU_DIR/man
export SIU_PROFILE_DIR=$SIU_DIR/profile.d    # stores all files that should be sourced
export SIU_SOURCES_DIR=$SIU_DIR/sources
export SIU_UTILITIES_DIR=$SIU_DIR/utilities

# files
export SIU_TOOL_VERSIONS=$SIU_DIR/tool_versions.txt
export SIU_TOOL_VERSIONS_UPDATE=$SIU_DIR/tool_versions_update.txt
export SIU_EXPORTS=$SIU_DIR/siu_exports
export SIU_ZSHRC=$SIU_DIR/siu_zshrc
export SIU_BASHRC=$SIU_DIR/siu_bashrc
