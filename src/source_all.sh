#!/usr/bin/env bash

. src/core.sh
. src/env_siu.sh
. src/setup_siu.sh
for u in src/utils/*.sh src/deps/*.sh src/tools/*.sh; do
    . "${u}"
done
