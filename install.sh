#!/bin/bash

source env_siu.sh
source setup_siu.sh

tools=(zsh omz bat pure star)

init::siu

for tool in "${tools[@]}"; do
    source "tools/install_${tool}.sh"
    "install::${tool}"
done
