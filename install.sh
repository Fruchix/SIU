#!/bin/bash

# source all required files
. env_siu.sh
. setup_siu.sh
for u in utils/*.sh deps/*.sh tools/*.sh; do
    . "${u}"
done

function _siu::prepare_install()
{
    _siu::log::info "Starting preparing SIU install"
    mkdir archives

    for tool in "${tools[@]}"; do
        _siu::log::info "Starting preparing ${tool} install"
        "_siu::prepare_install::${tool}"
        _siu::log::info "Finished preparing ${tool} install"
    done
    _siu::log::info "Finished preparing SIU install"
}

# Install all tools contained in the "tools" array, each tool should be supported.
function _siu::install()
{
    _siu::log::info "Starting SIU install"
    _siu::init::siu

    for tool in "${tools[@]}"; do
        _siu::log::info "Starting ${tool} install"
        "_siu::install::${tool}"
        _siu::log::info "Finished ${tool} install"
    done
    _siu::log::info "Finished SIU install"
}

export OFFLINE_INSTALL=no

siu_LOG_LEVEL=0

## Specifying installation behaviour:
# [tool]: install only a specific tool (?)
# --prefix <prefix>: where to install SIU
# --arch <arch>: specify the arch of the machine, if not provided will automaticaly detect it. Required by the PREPARE mode.
# --offline
# --config-file <config_file>

# Exclusives, at least one must be chosen:
# --default: install a set of default tools
# --all: install all tools
# --missing: install all tools that are not on the current system
# --tools <tool1> [tool2] ...: set of tools to install, at least one needed

## Modifying script behaviour:
# --prepare-install: only download the archives of the tools/clone their repositories
# --check-dependencies [tool]: check if the selected tools can be installed
# --check-update [tool1] [tool2] ...: check if the installed tools are at the latest version
# --update [tool1] [tool2] ...: update the selected tools that are not at the latest version (by default, update all tools)
# --uninstall [tool1] [tool2] ...: uninstall the selected tools (by default, uninstall SIU)
# --help

DEFAULT_PREFIX='$HOME'
DEFAULT_TOOLSET=(zsh fzf bat tree)
ARCHITECTURES=(x86_64 aarch64) # supported architectures

prefix="$DEFAULT_PREFIX"
# $(eval echo $prefix)
arch=
# by default, not an offline install (0)
offline=0
config_file=

# tools in [DEFAULT, ALL, MISSING, SELECTION]
toolset=
tools=()

# mode in [INSTALL, PREPARE, CHECK_UPDATE, UPDATE, CHECK_DEPENDENCIES, UNINSTALL]
mode=

# positional_args=()

while [[ $# -gt 0 ]]; do
    opt="$1"
    shift

    case "$opt" in
        --) break 2;;
        -) break 2;;
        --prefix|-p)        prefix="$1";        shift;;
        --arch|-a)          arch="$1";          shift;;
        --offline|-o)       offline=1;;
        --config-file|-c)   config_file="$1";   shift;;
        --default|-D)       toolset=${toolset:-DEFAULT};;
        --all|-A)           toolset=${toolset:-ALL};;
        --missing|-M)       toolset=${toolset:-MISSING};;
        --tools|-T|--selection|-S)
            toolset=${toolset:-SELECTION}
            # read all tools until the next argument
            while (( "$#" >= 1 )) && ! [[ $1 = -* ]]; do
                tools+=( "$1" )
                shift
            done
            ;;
        --prepare-install|--prepare)      mode=${mode:-PREPARE};;
        --check-dependencies|--cd)   mode=${mode:-CHECK_DEPENDENCIES};;
        --check-update|--cu)         mode=${mode:-CHECK_UPDATE};;
        --update)               mode=${mode:-UPDATE};;
        --uninstall)            mode=${mode:-UNINSTALL};;
        --help|-h|help|h) echo "help"; exit 0;;
        -*) echo >&2 "Invalid option: $opt"; exit 1;;
        *)
            # positional_args+=("$opt")
            ;;
    esac
done

# toolset=${toolset:-DEFAULT}

# select which tools to install
case "$toolset" in
    DEFAULT) tools=("${DEFAULT_TOOLSET[@]}");;
    ALL)
        tools=()
        for f in tools/*.sh; do
            tmp_tool_name=${f//"tools/install_"/}
            tools+=("${tmp_tool_name//".sh"/}")
        done
        ;;
    MISSING)
        tools=()
        for f in tools/*.sh; do
            tmp_tool_name=${f//"tools/install_"/}
            tmp_tool_name=${tmp_tool_name//".sh"/}

            if ! "_siu::check_installed::${tmp_tool_name}"; then
                tools+=("${tmp_tool_name}")
            fi
        done
        ;;
    SELECTION)
        # check if all provided tools are supported by checking if they have an installation script
        for t in "${tools[@]}"; do
            if [[ ! -f "tools/install_${t}.sh" ]]; then
                _siu::log::error "Tool \"${t}\" does not exist."
                exit 1
            fi
        done
        ;;
esac

# by default, the mode is INSTALL
mode=${mode:-INSTALL}

# by default, the architecture is found dynamicaly
arch=${arch:-$(uname -m)}
# check that the provided architecture corresponds to at least one supported architecture
arch_isvalid=0
for a in "${ARCHITECTURES[@]}"; do
    if [[ "$arch" =~ $a ]]; then
        arch_isvalid=1
        # unify the names of the architectures
        arch=$a
    fi
done
if [[ ${arch_isvalid} -eq 0 ]]; then
    _siu::log::error "Architecture \"${arch}\" is not valid. Chose between the following architectures: ${ARCHITECTURES[*]}"
    exit 1
fi

_siu::log::debug "mode=$mode"
_siu::log::debug "prefix=$(eval echo "${prefix}")"
_siu::log::debug "arch=$arch"
_siu::log::debug "offline=$offline"
_siu::log::debug "toolset=$toolset"
_siu::log::debug "tools=[${tools[*]}]"

case "$mode" in
    INSTALL)
        _siu::check::tools_dependencies
        _siu::prepare_install
        _siu::install
        ;;
    PREPARE)
        _siu::check::tools_dependencies
        _siu::prepare_install
        ;;
    CHECK_UPDATE)
        ;;
    UPDATE)
        ;;
    CHECK_DEPENDENCIES)
        _siu::check::tools_dependencies
        ;;
    UNINSTALL)
        ;;
esac
