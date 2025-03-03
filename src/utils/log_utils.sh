#!/usr/bin/env bash

################################################################################
# Colors
################################################################################
_siu_ESC_CHAR="\e"

_siu_COLOR_RED="${_siu_ESC_CHAR}[31m"
_siu_COLOR_GREEN="${_siu_ESC_CHAR}[32m"
_siu_COLOR_YELLOW="${_siu_ESC_CHAR}[33m"
_siu_COLOR_BLUE="${_siu_ESC_CHAR}[34m"

_siu_COLOR_ENDCOLOR="${_siu_ESC_CHAR}[0m"
_siu_BOLD="${_siu_ESC_CHAR}[1m"
################################################################################


################################################################################
# Logging levels and their associated colors and names
################################################################################
_siu_LOG_LEVEL_DEBUG=0
_siu_LOG_LEVEL_INFO=1
_siu_LOG_LEVEL_WARNING=2
_siu_LOG_LEVEL_ERROR=3

declare -A _siu_LOG_COLORS=(
    [$_siu_LOG_LEVEL_DEBUG]="${_siu_COLOR_BLUE}"
    [$_siu_LOG_LEVEL_INFO]="${_siu_COLOR_GREEN}"
    [$_siu_LOG_LEVEL_WARNING]="${_siu_COLOR_YELLOW}"
    [$_siu_LOG_LEVEL_ERROR]="${_siu_COLOR_RED}"
)

declare -A _siu_LOG_LEVELS=(
    [$_siu_LOG_LEVEL_DEBUG]="DEBUG"
    [$_siu_LOG_LEVEL_INFO]="INFO"
    [$_siu_LOG_LEVEL_WARNING]="WARNING"
    [$_siu_LOG_LEVEL_ERROR]="ERROR"
)

declare -A _siu_LOG_LEVEL_PARAM=(
    [debug]=$_siu_LOG_LEVEL_DEBUG
    [info]=$_siu_LOG_LEVEL_INFO
    [warning]=$_siu_LOG_LEVEL_WARNING
    [warn]=$_siu_LOG_LEVEL_WARNING
    [error]=$_siu_LOG_LEVEL_ERROR
    [err]=$_siu_LOG_LEVEL_ERROR
)
################################################################################


################################################################################
# Variables
################################################################################
# Redifining any of the following variables in your scripts/functions will override
# its default value

# minimum level for each log message to be logged, by default 1 (INFO).
siu_LOG_LEVEL=${siu_LOG_LEVEL:-1}

# log file where to save the logged messages (in addition to displaying them in terminal)
# Default: no log file
siu_LOG_FILE=${siu_LOG_FILE:-}
################################################################################


################################################################################
# Logging functions
################################################################################

# Log a message with format: [timestamp][log level] context: message
#   Where context is "main" if this function is called from a script, or the name of the function calling this logging function
# 
# Parameters
#   $1: log_level, can be either a number between 0 and 3 (0 debug...3 error), or the name of the level
#                   name of the logging levels: debug, info, warning (or warn), error (or err)
#   $2: message to print
#   $3: number of functions to ignore from the stack function. Used if the logging function is called from a "util" function,
#       which is not the principal function where we want our log to come from.
function _siu::log()
{
    local log_level=$1
    local message="$2"
    local nb_func_ignore=${3:-0}

    # FUNCNAME only works under bash
    # if this logging function is called from a _siu::log::(debug|info|warning|error) function,
    # then the calling function is two functions away in the calling stack
    # else the calling function is one function away in the calling stack
    if [[ ${FUNCNAME[@]} =~ "_siu::log::" ]]; then
        local context="${FUNCNAME[(( 2 + $nb_func_ignore))]}"
    else
        local context="${FUNCNAME[(( 1 + $nb_func_ignore ))]}"
    fi

    # convert log_level to the corresponding integer if a string was passed
    if [[ "${#log_level}" -ne 1 ]]; then
        log_level="${_siu_LOG_LEVEL_PARAM[$log_level]}"

        # if this logging level does not exist, then log an ERROR explaining the problem
        if [[ -z "$log_level" ]]; then
            message="Bad parameter to _siu::log: \"$1\" is not an existing log level. Log message: \"$message\"."
            log_level=3
        fi
    fi

    # only display logs that have a higher/equal level than/to siu_LOG_LEVEL
    if [[ ${log_level} -lt ${siu_LOG_LEVEL} ]]; then
        return
    fi

    local level_name=${_siu_LOG_LEVELS[$log_level]}
    # all log level (names) have the same size for a better display
    while [[ ${#level_name} -lt 7 ]]; do
            level_name="${level_name} "
    done
    local color="${_siu_LOG_COLORS[$log_level]}"

    local timestamp="$(date -Is)"
    local log_string="[${timestamp}][${color}${level_name}${_siu_COLOR_ENDCOLOR}] ${_siu_BOLD}${context}${_siu_COLOR_ENDCOLOR}: ${message}"
    if [[ -z "${siu_LOG_FILE}" ]]; then
        echo -e "${log_string}"
    else
        echo -e "${log_string}" | tee -a siu-install.logs
    fi
}

# Log a message using _siu::log, with log level debug
function _siu::log::debug()
{
    _siu::log debug "$@"
}

# Log a message using _siu::log, with log level info
function _siu::log::info()
{
    _siu::log info "$@"
}

# Log a message using _siu::log, with log level warning
function _siu::log::warning()
{
    _siu::log warning "$@"
}

# Log a message using _siu::log, with log level error
function _siu::log::error()
{
    _siu::log error "$@"
}
################################################################################
