#!/bin/bash

source env_siu.sh
source utils/check_utils.sh

function _siu::prepare_install::pure()
{
    _siu::check::dependency::critical git

    git clone --depth 1 https://github.com/sindresorhus/pure.git archives/pure
    _siu::check::return_code "pure prepare_install: \"git clone\" dit not work. Stopping installation preparation."
}

function _siu::install::pure()
{
    cp -r archives/pure "$SIU_DIR/pure"

    cat << "EOF" >> "${SIU_ZSHRC}"

### Automaticaly added by _siu::install::pure ###
fpath+=($SIU_DIR/pure)                       ### _siu::install::pure
### Automaticaly added by _siu::install::pure ###
EOF
}

function _siu::uninstall::pure()
{
    rm -rf "${SIU_DIR}/pure"
    sed -i '/_siu::install::pure/d' "${SIU_ZSHRC}"
}

