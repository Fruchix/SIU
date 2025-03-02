#!/usr/bin/env bash

function _siu::get_latest_version::pure()
{
    local latest_version
    if latest_version="0.0.0"; then
        echo "${latest_version}"
    else
        return 1
    fi
}

function _siu::prepare_install::pure()
{
    git clone --depth 1 https://github.com/sindresorhus/pure.git "${SIU_SOURCES_DIR_CURTOOL}/pure.gitclone"
    _siu::check::return_code "\"git clone\" dit not work. Stopping installation preparation." "Cloned https://github.com/sindresorhus/pure.git."
}

function _siu::install::pure()
{
    cp -rT "${SIU_SOURCES_DIR_CURTOOL}/pure.gitclone" "$SIU_UTILITIES_DIR/pure"
    _siu::check::return_code "Could not copy pure repository to ${SIU_UTILITIES_DIR}/pure. Stopping installation." "Copied pure repository to ${SIU_UTILITIES_DIR}/pure"

    cat << "EOF" >> "${SIU_ZSHRC}"

### Automaticaly added by _siu::install::pure ###
fpath+=(${SIU_UTILITIES_DIR}/pure)                        ### _siu::install::pure
### Automaticaly added by _siu::install::pure ###
EOF
    _siu::check::return_code "Could not update siu_zshrc to add pure information." "Updated siu_zshrc to add pure information."
}

