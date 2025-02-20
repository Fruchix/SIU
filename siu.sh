#!/usr/bin/env bash

# this script should be run from this project's root directory
if ! [[ -d src/utils && -d src/tools && -d src/deps && -f src/env_siu.sh && -f src/setup_siu.sh ]]; then
    echo "This script should only be run from its directory."
    exit 1
fi

# source all required files
. src/source_all.sh

function _siu::main()
{
    export OFFLINE_INSTALL=no

    siu_LOG_LEVEL=0

    # SYNOPSIS:
    #   ./siu <tool1> [tool2] ... [OPTIONS]
    #   ./siu TOOLSET_OPTION [OPTIONS]

    # DESCRIPTION:
    #   TOOLSET_OPTION (mutually exclusives):
    #       --default, -D
    #           install a set of default tools
    #       --all, -A 
    #           install all tools even if they are already installed on the system. Same as "--missing --force".
    #       --missing, -M
    #           install all tools that are not installed on the current system.
    #           Using it with "--force" is equivalent to "--all".
    #       --tools, --selection, -T, -S <tool1> [tool2] ...
    #           set of tools to install, at least one needed. Same as "./siu <tool1> [tool2] ...".
    #
    #   OPTIONS:
    #       --prefix <prefix>
    #           where to install SIU
    #       --arch <arch>
    #           specify the arch of the machine, if not provided will automaticaly detect it. Required by the PREPARE mode.
    #       --offline
    #       --force, -f
    #           install all selected tools even if they already installed on the system.
    #           Using it with "--missing" is equivalent to "--all".
    #       --config-file, -c <config_file>
    #       --prepare-install
    #           only download the archives of the tools/clone their repositories
    #       --check-dependencies, --cd
    #           check if the selected tools can be installed, without performing installation.
    #       --check-update, --cu
    #           check if the installed tools are at the latest version
    #       --update
    #           update the selected tools that are not at the latest version (by default, update all tools)
    #       --uninstall
    #           uninstall the selected tools (by default, uninstall SIU itself)
    #       --help, -h
    #           print helper

    DEFAULT_PREFIX='$HOME'
    DEFAULT_TOOLSET=(zsh fzf bat tree)
    ARCHITECTURES=(x86_64 aarch64) # supported architectures

    prefix="$DEFAULT_PREFIX"
    # $(eval echo $prefix)
    arch=
    # by default, not an offline install (0)
    offline=0
    config_file=
    force_install=0

    # tools in [DEFAULT, ALL, MISSING, SELECTION]
    toolset=
    tools=()

    # mode in [INSTALL, PREPARE, CHECK_UPDATE, UPDATE, CHECK_DEPENDENCIES, UNINSTALL]
    mode=

    while [[ $# -gt 0 ]]; do
        opt="$1"
        shift

        case "$opt" in
            --) break 2;;
            -) break 2;;
            --prefix|-p)        prefix="$1";        shift;;
            --arch|-a)          arch="$1";          shift;;
            --offline|-o)       offline=1;;
            --force|-f)         force_install=1;;
            --config-file|-c)   config_file="$1";   shift;;
            --default|-D)       toolset=${toolset:-DEFAULT};;
            --all|-A)           toolset=${toolset:-ALL}; force_install=1;;
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
            --help|-h) echo "help"; exit 0;;
            -*) echo >&2 "Invalid option: $opt"; exit 1;;
            *)
                toolset=${toolset:-SELECTION}
                tools+=("$opt")
                ;;
        esac
    done

    # select which tools to install
    case "$toolset" in
        DEFAULT) tools=("${DEFAULT_TOOLSET[@]}");;
        ALL|MISSING)
            tools=()
            for f in src/tools/*.sh; do
                tmp_tool_name=${f//"src/tools/install_"/}
                tools+=("${tmp_tool_name//".sh"/}")
            done
            ;;
        SELECTION)
            # check if all provided tools are supported by checking if they have an installation script
            for t in "${tools[@]}"; do
                if [[ ! -f "src/tools/install_${t}.sh" ]]; then
                    _siu::log::error "Tool \"${t}\" is not recognized by SIU."
                    exit 1
                fi
            done
            ;;
    esac

    # only keep tools that are not installed
    # keep all tools if option "--force" is used
    tmp_tools=("${tools[@]}")
    tools=()
    for t in "${tmp_tools[@]}"; do
        if [[ "${force_install}" -eq 1 ]] || ! _siu::core::is_installed "${t}"; then
            tools+=("${t}")
        fi
    done

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
            _siu::core::install
            ;;
        PREPARE)
            _siu::core::prepare_install
            ;;
        CHECK_UPDATE)
            _siu::core::check_update
            ;;
        UPDATE)
            _siu::core::update
            ;;
        CHECK_DEPENDENCIES)
            _siu::core::check_dependencies
            ;;
        UNINSTALL)
            _siu::core::uninstall
            ;;
    esac
}

_siu::main "$@"
