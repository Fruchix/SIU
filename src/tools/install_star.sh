#!/usr/bin/env bash

function _siu::get_latest_version::star()
{
    local latest_version
    if latest_version=$(wget -qO- https://api.github.com/repos/Fruchix/star/releases/latest); then
        echo "${latest_version}" | grep "tag_name" | cut -d\" -f4 | tr -d v
    else
        return 1
    fi
}

function _siu::prepare_install::star()
{
    local star_version archive
    star_version=$(_siu::get_latest_version::star)
    _siu::check::return_code "Could not get latest version. Stopping installation preparation." "Latest version of star is: ${star_version}."

    archive="star-${star_version}.tar.gz"

    curl -L -o "${SIU_SOURCES_DIR_CURTOOL}/star.tar.gz" "https://github.com/Fruchix/star/releases/download/v${star_version}/${archive}"
    _siu::check::return_code "Could not download archive ${archive}. Stopping installation preparation." "Downloaded archive ${archive} from https://github.com/Fruchix/star/releases/download/v${star_version}/${archive}"
}

function _siu::install::star()
{
    # (by default, untarring the archive gives a zsh directory containing the whole version number)
    tar xvf "${SIU_SOURCES_DIR_CURTOOL}/star.tar.gz" -C . --strip-components 1
    ls -la
    _siu::check::return_code "Could not untar archive. Stopping installation." "Untarred star archive."

    chmod +x ./configure
    ./configure --prefix="${SIU_UTILITIES_DIR}/star/"
    _siu::check::return_code "\"./configure\" did not work. Stopping installation." "Successfully ran \"./configure\"."

    chmod +x ./install.sh
    ./install.sh
    _siu::check::return_code "\"./install.sh\" did not work. Stopping installation." "Successfully ran \"./install.sh\"."

    for f in "${SIU_UTILITIES_DIR}"/star/bin/*; do
        ln -s "$(realpath "${f}")" "${SIU_BIN_DIR}/${f##*/}"
    done

    cat << "EOF" >> "${SIU_BASHRC}"

### Automaticaly added by _siu::install::star ###
eval "$(command star init bash)"              ### _siu::install::star
### Automaticaly added by _siu::install::star ###
EOF
    _siu::check::return_code "Could not update siu_bashrc to add star information." "Updated siu_bashrc to add star information."

    cat << "EOF" >> "${SIU_ZSHRC}"

### Automaticaly added by _siu::install::star ###
eval "$(command star init zsh)"               ### _siu::install::star
### Automaticaly added by _siu::install::star ###
EOF
    _siu::check::return_code "Could not update siu_zshrc to add star information." "Updated siu_zshrc to add star information."
}

function _siu::uninstall::star()
{
    local retcode=0
    # remove all data
    # then remove the star directory in SIU_DIR and all star information contained in rc files
    star reset --force
    _siu::check::return_code "\"star reset --force\" did not work." "Successfully ran \"star reset --force\"." --no-exit retcode
    return $retcode
}
