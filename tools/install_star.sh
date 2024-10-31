#!/bin/bash

source env_siu.sh
source utils/check_utils.sh

function _siu::prepare_install::star()
{
    _siu::check::dependency::critical git

    git clone --depth 1 https://github.com/Fruchix/star.git archives/star
    _siu::check::return_code "star install: \"git clone\" dit not work. Stopping installation preparation."
}

function _siu::install::star()
{
    _siu::check::dependency::critical column

    cp -r archives/star "$SIU_DIR/star"

    rc_config=$(cat << "EOF"

### Automaticaly added by _siu::install::star ###
. ${SIU_DIR}/star/star.sh                    ### _siu::install::star
### Automaticaly added by _siu::install::star ###
EOF
)
    echo "${rc_config}" >> "${SIU_ZSHRC}"
    echo "${rc_config}" >> "${SIU_BASHRC}"
}

function _siu::uninstall::star()
{
    star reset --force
    rm -r "${SIU_DIR}/star"
    sed -i '/_siu::install::star/d' "${SIU_ZSHRC}"
    sed -i '/_siu::install::star/d' "${SIU_BASHRC}"
}
