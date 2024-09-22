#!/bin/bash

source env_siu.sh
source utils/check_utils.sh

install::pure()
{
    check::dependency::critical git

    git clone https://github.com/sindresorhus/pure.git "$SIU_DIR/pure"
    check::return_code "pure install: \"git clone\" dit not work. Stopping installation."

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

