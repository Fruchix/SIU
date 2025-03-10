#!/usr/bin/env bash

if [[ -z "${SIU_DIR+x}" ]]; then
    echo "SIU_DIR is not set."
    exit 1
fi

cd "${SIU_DIR}" || {
    echo "Could not cd into SIU_SIR='${SIU_DIR}'."
    exit 1
}

# this script should be run from this project's root directory
if ! [[ -d src/utils && -d src/tools && -d src/deps && -f src/env_siu.sh && -f src/setup_siu.sh ]]; then
    echo "This script should only be run from its directory."
    exit 1
fi

# source all required files
. src/source_all.sh

# in case user environment does not contain all SIU installed tools
if [[ -f ${SIU_DIR}/siu_exports ]]; then
    . ${SIU_DIR}/siu_exports
fi

_siu::help() {
    cat << EOF
USAGE
    siu MODE [tool]... [OPTION]...
    siu MODE TOOLSET_OPTION [OPTION]...

DESCRIPTION
    MODE
        install
            install the selected tools
        check_update
            check if the installed tools are at the latest version
        update
            update the selected tools that are not at the latest version (by default, update all tools)
        uninstall
            uninstall the selected tools
        prepare
            only download the archives of the tools/clone their repositories. Used for an offline installation.
            Requires the --arch=<arch> option.
        check_dependencies
            check if the selected tools can be installed, without performing installation.
        help
            display this message

    TOOLSET_OPTION (mutually exclusives)
        --default, -D
            install a set of default tools
        --all, -A 
            install all tools even if they are already installed on the system.
            With "--force", will force the download of soures even if they already are.
        --missing, -M
            install all tools that are not installed on the current system.
        --tools, --selection, -T, -S <tool1> [tool2] ...
            set of tools to install, at least one needed. Same as "siu <MODE> <tool1> [tool2] ...".

    OPTION
        --arch=<arch>
            specify the arch of the machine, if not provided will automaticaly detect it. Required by the PREPARE mode.
        --offline
            will only use already downloaded sources from $SIU_SOURCES_DIR directory. Won't download any other sources.
        --force, -f
            install all selected tools even if they are already installed on the system, and also force the download of sources.
            To only force the download of sources, run prepare with force first, then install without force.
        --config-file, -c <config_file>
        --verbose, -v
            log more information

EOF
}

function _siu::main()
{
    if [[ $# -lt 1 ]]; then
        echo "No argument provided. See usage: "
        echo
        _siu::help
        exit 1
    fi
    export OFFLINE_INSTALL=no

    siu_LOG_LEVEL=1

    DEFAULT_TOOLSET=(zsh fzf bat tree)
    ARCHITECTURES=(x86_64 aarch64 arm64) # supported architectures

    arch=
    # by default, not an offline install (0)
    offline=0
    config_file=
    FORCE_INSTALL=0

    # TOOLSET in [DEFAULT, ALL, MISSING, SELECTION]
    TOOLSET=
    tools=()

    # MODE in [INSTALL, PREPARE, CHECK_UPDATE, UPDATE, CHECK_DEPENDENCIES, UNINSTALL]
    MODE=

    # read MODE
    case "$1" in
        install|i)              MODE=${MODE:-INSTALL};;
        check_dependencies|cd)  MODE=${MODE:-CHECK_DEPENDENCIES};;
        uninstall|remove|rm)    MODE=${MODE:-UNINSTALL};;
        prepare|p)              MODE=${MODE:-PREPARE};;
        check_update|cu)        MODE=${MODE:-CHECK_UPDATE};;
        update|u)               MODE=${MODE:-UPDATE};;
        h|help|-h|--help)
            _siu::help
            exit 0
            ;;
        *)
            echo "Mode '$1' is not valid. See usage: "
            echo
            _siu::help
            exit 1
            ;;
    esac
    shift

    while [[ $# -gt 0 ]]; do
        opt="$1"
        shift

        case "$opt" in
            --) break 2;;
            -) break 2;;
            --arch|-a)          arch="$1";          shift;;
            --offline|-o)       offline=1;;
            --force|-f)         FORCE_INSTALL=1;;
            --config-file|-c)   config_file="$1";   shift;;
            --verbose|-v)          ((siu_LOG_LEVEL--));;
            -v*)
                # decrement the log level by the number of v's
                ((siu_LOG_LEVEL=siu_LOG_LEVEL-$(echo "$opt" | tr -cd 'v' | wc -c)))
                ;;
            # toolset options
            --default|-D)       TOOLSET=${TOOLSET:-DEFAULT};;
            --all|-A)           TOOLSET=${TOOLSET:-ALL};;
            --missing|-M)       TOOLSET=${TOOLSET:-MISSING};;
            --tools|-T|--selection|-S)
                TOOLSET=${TOOLSET:-SELECTION}
                # read all tools until the next argument
                while (( "$#" >= 1 )) && ! [[ $1 = -* ]]; do
                    tools+=( "$1" )
                    shift
                done
                ;;
            --help|-h) _siu::help; exit 0;;
            -*) echo >&2 "Invalid option: $opt"; exit 1;;
            *)
                TOOLSET=${TOOLSET:-SELECTION}
                tools+=("$opt")
                ;;
        esac
    done

    # select which tools to install depending on toolset
    case "$TOOLSET" in
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

    # some modes require to check and edit the list of tools
    if [[ "INSTALL CHECK_UPDATE UPDATE UNINSTALL" =~ $MODE ]]; then
        tmp_tools=("${tools[@]}")
        tools=()
        for t in "${tmp_tools[@]}"; do
            case "$MODE" in
                INSTALL)
                    # only keep tools that are not installed
                    # keep all tools if option "--force" is used
                    if [[ "${FORCE_INSTALL}" -eq 1 || "${TOOLSET}" == "ALL" ]] || ! _siu::core::is_installed "${t}"; then
                        tools+=("${t}")
                    else
                        local which_install
                        which_install=$(which "${t}")
                        if [[ $? -eq 0 ]]; then
                            _siu::log::warning "${t} is already installed at '${which_install}'. Won't install."
                        else
                            _siu::log::warning "${t} is already installed. Won't install."
                        fi
                    fi
                    ;;
                CHECK_UPDATE|UPDATE|UNINSTALL)
                    # only keep tools that are already installed
                    if _siu::core::is_installed "${t}"; then
                        tools+=("${t}")
                    else
                        _siu::log::warning "${t} is not installed."
                    fi
                    ;;
            esac
        done
    fi

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
    if [[ "$arch" == arm64 ]]; then
        arch="aarch64"
    fi
    if [[ ${arch_isvalid} -eq 0 ]]; then
        _siu::log::error "Architecture \"${arch}\" is not valid. Chose between the following architectures: ${ARCHITECTURES[*]}"
        exit 1
    fi

    _siu::log::debug "MODE=$MODE"
    _siu::log::debug "arch=$arch"
    _siu::log::debug "offline=$offline"
    _siu::log::debug "TOOLSET=$TOOLSET"
    _siu::log::debug "tools=[${tools[*]}]"

    case "$MODE" in
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
