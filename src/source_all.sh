#!/usr/bin/env bash

. src/env_siu.sh
. src/setup_siu.sh
. src/core.sh
for u in src/utils/*.sh; do
    . "${u}"
done

for f in src/deps/*.sh src/tools/*.sh; do
    . "${f}"

    # get name of the tool
    toolname=${f##*/install_}
    toolname=${toolname%%.sh}

    # check that all required functions are defined
    _siu::check::command_exists "_siu::install::${toolname}"
    _siu::check::return_code "'${toolname}' installation script (${f}) should implement command '_siu::install::${toolname}'."

    _siu::check::command_exists "_siu::prepare_install::${toolname}"
    _siu::check::return_code "'${toolname}' installation script (${f}) should implement command '_siu::prepare_install::${toolname}'."
done

unset toolname
unset f
unset u