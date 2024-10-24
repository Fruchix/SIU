#!/bin/bash

source env_siu.sh
source utils/check_utils.sh

prepare_install::pure()
{
    check::dependency::critical git

    git clone --depth 1 https://github.com/sindresorhus/pure.git archives/pure
    check::return_code "pure prepare_install: \"git clone\" dit not work. Stopping installation preparation."
}

install::pure()
{
    cp -r archives/pure "$SIU_DIR/pure"

    cat << "EOF" >> "${SIU_ZSHRC}"

### Automaticaly added by SIU::install::pure ###
fpath+=($SIU_DIR/pure)                       ### SIU::install::pure
### Automaticaly added by SIU::install::pure ###
EOF
}

uninstall::pure()
{
    rm -rf "${SIU_DIR}/pure"
    sed -i '/SIU::install::pure/d' "${SIU_ZSHRC}"
}

