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
    git clone --depth 1 https://github.com/sindresorhus/pure.git archives/pure
    _siu::check::return_code "\"git clone\" dit not work. Stopping installation preparation." "Cloned https://github.com/sindresorhus/pure.git."
}

function _siu::install::pure()
{
    cp -r archives/pure "$SIU_DIR/pure"
    _siu::check::return_code "Could not copy pure repository to ${SIU_DIR}/pure. Stopping installation." "Copied pure repository to ${SIU_DIR}/pure"

    cat << "EOF" >> "${SIU_ZSHRC}"

### Automaticaly added by _siu::install::pure ###
fpath+=($SIU_DIR/pure)                        ### _siu::install::pure
### Automaticaly added by _siu::install::pure ###
EOF
    _siu::check::return_code "Could not update siu_zshrc to add pure information." "Updated siu_zshrc to add pure information."
}

function _siu::uninstall::pure()
{
    local retcode=0
    # remove PURE directory from SIU_DIR and all its information from siu_zshrc
    rm -rf "${SIU_DIR}/pure"
    _siu::check::return_code "Could not remove pure directory from ${SIU_DIR}/." "Removed pure directory from ${SIU_DIR}/" --no-exit retcode

    sed -i '/_siu::install::pure/d' "${SIU_ZSHRC}"
    _siu::check::return_code "Could not remove pure information from siu_zshrc." "Removed pure information from siu_zshrc." --no-exit retcode

    return $retcode
}

