#!/bin/bash

source env_siu.sh
source utils/check_utils.sh

prepare_install::star()
{
    check::dependency::critical git

    git clone --depth 1 https://github.com/Fruchix/star.git archives/star
    check::return_code "star install: \"git clone\" dit not work. Stopping installation preparation."
}

install::star()
{
    check::dependency::critical column

    cp -r archives/star "$SIU_DIR/star"

    rc_config=$(cat << "EOF"

### Automaticaly added by SIU::install::star ###
. ${SIU_DIR}/star/star.sh                    ### SIU::install::star
### Automaticaly added by SIU::install::star ###
EOF
)
    echo "${rc_config}" >> "${SIU_ZSHRC}"
    echo "${rc_config}" >> "${SIU_BASHRC}"
}

uninstall::star()
{
    star reset --force
    rm -r "${SIU_DIR}/star"
    sed -i '/SIU::install::star/d' "${SIU_ZSHRC}"
    sed -i '/SIU::install::star/d' "${SIU_BASHRC}"
}
