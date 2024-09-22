#!/bin/bash

source env_siu.sh
source setup_siu.sh
source tools/install_zsh.sh
source tools/install_pure.sh
source tools/install_bat.sh

tools=(zsh pure bat star)

init::siu

for tool in "${tools[@]}"; do
    source "tools/install_${tool}.sh"
    "install::${tool}"
done
