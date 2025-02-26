#!/usr/bin/env bash

. src/env_siu.sh
. src/setup_siu.sh
. src/core.sh
for u in src/utils/*.sh src/deps/*.sh src/tools/*.sh; do
    . "${u}"
done
