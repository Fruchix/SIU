#!/usr/bin/env bash

function _siu::get_latest_version::star()
{
    local latest_version
    if latest_version="0.0.0"; then
        echo "${latest_version}"
    else
        return 1
    fi
}

function _siu::check_installed::star()
{
    if [[ -d ${SIU_DIR}/star ]]; then
        _siu::log::info "Installed using SIU."
        return 0
    fi

    if [[ -d $HOME/.star/ ]]; then
        return 0
    fi

    return 1
}

function _siu::prepare_install::star()
{
    git clone --depth 1 https://github.com/Fruchix/star.git archives/star
    _siu::check::return_code "\"git clone\" dit not work. Stopping installation preparation." "Cloned https://github.com/Fruchix/star.git."
}

function _siu::install::star()
{
    cp -r archives/star "$SIU_DIR/star"
    _siu::check::return_code "Could not copy star repository to ${SIU_DIR}/star. Stopping installation." "Copied star repository to ${SIU_DIR}/star"

    rc_config=$(cat << "EOF"

### Automaticaly added by _siu::install::star ###
. ${SIU_DIR}/star/star.sh                     ### _siu::install::star
### Automaticaly added by _siu::install::star ###
EOF
)
    echo "${rc_config}" >> "${SIU_ZSHRC}"
    _siu::check::return_code "Could not update siu_zshrc to add star information." "Updated siu_zshrc to add star information."
    echo "${rc_config}" >> "${SIU_BASHRC}"
    _siu::check::return_code "Could not update siu_bashrc to add star information." "Updated siu_bashrc to add star information."
}

function _siu::uninstall::star()
{
    # remove the ".star" directory using "star reset",
    # then remove the star directory in SIU_DIR and all star information contained in rc files
    star reset --force
    _siu::check::return_code "\"star reset --force\" did not work." "Successfully ran \"star reset --force\"." --no-exit
    rm -rf "${SIU_DIR}/star"
    _siu::check::return_code "Could not remove star directory from ${SIU_DIR}/." "Removed star directory from ${SIU_DIR}/" --no-exit
    sed -i '/_siu::install::star/d' "${SIU_ZSHRC}"
    _siu::check::return_code "Could not remove star information from siu_zshrc." "Removed star information from siu_zshrc." --no-exit
    sed -i '/_siu::install::star/d' "${SIU_BASHRC}"
    _siu::check::return_code "Could not remove star information from siu_bashrc." "Removed star information from siu_bashrc." --no-exit
}
