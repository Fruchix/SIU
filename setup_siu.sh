#!/bin/bash

source env_siu.sh

init::siu_dirs()
{
    mkdir -p $SIU_DIR
    mkdir -p $SIU_DEPS_DIR
}

init::siu_zshrc()
{
    echo "export SIU_DIR=${SIU_DIR}" >> "${SIU_ZSHRC}"
    cat << "EOF" >> "${SIU_ZSHRC}"
export SIU_ZSHRC=$SIU_DIR/siu_zshrc

export PATH=$PATH:$SIU_DIR/bin
EOF
}

init::siu()
{
    echo "source $SIU_ZSHRC" >> ~/.zshrc
    echo "export SIU_DIR=$SIU_DIR" >> ~/.bashrc
    echo 'export PATH=$PATH:$SIU_DIR/bin' >> ~/.bashrc

    init::siu_dirs
    init::siu_zshrc
}
