#!/usr/bin/env bash

if [[ -z "${SIU_PREFIX+x}" && -z "${SIU_DIR+x}" ]]; then
    echo "SIU_PREFIX and SIU_DIR are both unset."
    return 0
fi

SIU_DIR=${SIU_DIR-$SIU_PREFIX/.siu}

# directories
SIU_BIN_DIR=$SIU_DIR/bin
SIU_DEPS_DIR=$SIU_DIR/deps
SIU_MAN_DIR=$SIU_DIR/man
SIU_PROFILE_DIR=$SIU_DIR/profile.d    # stores all files that should be sourced
SIU_SOURCES_DIR=$SIU_DIR/sources
SIU_UTILS_DIR=$SIU_DIR/utils

# files
SIU_TOOL_VERSIONS=$SIU_DIR/tool_versions.txt
SIU_TOOL_VERSIONS_UPDATE=$SIU_DIR/tool_versions_update.txt
SIU_EXPORTS=$SIU_DIR/siu_exports
SIU_ZSHRC=$SIU_DIR/siu_zshrc
SIU_BASHRC=$SIU_DIR/siu_bashrc
