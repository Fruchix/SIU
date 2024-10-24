#!/bin/bash

source env_siu.sh
source utils/check_utils.sh

install::fzf()
{
    check::dependency::critical git

    git clone --depth 1 https://github.com/junegunn/fzf.git "$SIU_DIR/fzf" >/dev/null 2>&1
    check::return_code "fzf install: \"git clone\" dit not work. Stopping installation."

    # install fzf with key bindings, completion and man files
    # but without modifying shell configuration files nor generating ~/.fzf.{bash,zsh}
    "$SIU_DIR/fzf/install" --key-bindings --completion --xdg --no-update-rc --bin
    check::return_code "fzf install: \"$SIU_DIR/fzf/install\" dit not work. Stopping installation."

    cat << "EOF" >> "${SIU_EXPORTS}"

### Automaticaly added by SIU::install::fzf ###
export PATH="$PATH:$SIU_DIR/fzf/bin"        ### SIU::install::fzf
### Automaticaly added by SIU::install::fzf ###
EOF
}

uninstall::fzf()
{
    "${SIU_DIR}/fzf/uninstall"
    sed -i '/SIU::install::fzf/d' "${SIU_EXPORTS}"
}
