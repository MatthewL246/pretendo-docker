#!/usr/bin/env bash

# Usage:
# # shellcheck source=./internal/framework.sh
# source "$(dirname "$(realpath "$0")")/internal/framework.sh"
# set_description "Script description goes here"
# # Add options and arguments here
# parse_arguments "$@"

# Update the script path to be the correct relative path to framework.sh

# Basic setup
set -euo pipefail

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    echo "The framework script needs to be sourced, not executed."
    exit 1
fi

# Provide the Git base directory
framework_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
git_base_dir="$(cd "$framework_dir" && git rev-parse --show-toplevel)"
cd "$git_base_dir"

# Terminal styling codes
term_reset=$(tput sgr0)
term_bold=$(tput bold)
term_underline=$(tput smul)
term_nounderline=$(tput rmul)
term_reverse=$(tput rev)
term_standout=$(tput smso)
term_nostandout=$(tput rmso)
term_dim=$(tput dim)

term_red=$(tput setaf 1)
term_green=$(tput setaf 2)
term_yellow=$(tput setaf 3)
term_blue=$(tput setaf 4)
term_magenta=$(tput setaf 5)
term_cyan=$(tput setaf 6)
term_white=$(tput setaf 7)

term_bgred=$(tput setab 1)
term_bggreen=$(tput setab 2)
term_bgyellow=$(tput setab 3)
term_bgblue=$(tput setab 4)
term_bgmagenta=$(tput setab 5)
term_bgcyan=$(tput setab 6)
term_bgwhite=$(tput setab 7)

# Set up the stage counter
stage_count=1

# Useful output functions
print_title() {
    echo "${term_bold}${term_white}${term_bgmagenta}==================== ${*} ====================${term_reset}"
    # Set the terminal emulator title
    printf "\033]0;%s\a" "${*}"
}

print_header() {
    echo "${term_bold}${term_cyan}---------- ${*} ----------${term_reset}"
}

print_stage() {
    print_header "Stage ${stage_count}: ${*}"
    stage_count=$((stage_count + 1))
}

print_error() {
    echo "${term_bold}${term_red}Error: ${*}${term_reset}" >&2
}

print_warning() {
    echo "${term_bold}${term_yellow}Warning: ${*}${term_reset}" >&2
}

print_info() {
    echo "${term_cyan}${*}${term_reset}"
}

print_success() {
    echo "${term_bold}${term_green}${*}${term_reset}"
}

# Run a command and only show output if the verbose option is set, show errors
run_verbose() {
    if [[ -n "$show_verbose" ]]; then
        "$@"
    else
        "$@" >/dev/null
    fi
}

# Run a command and only show output if the verbose option is set, hide errors
run_verbose_no_errors() {
    if [[ -n "$show_verbose" ]]; then
        "$@"
    else
        "$@" >/dev/null 2>&1
    fi
}

# Run a command every 2 seconds silently until it succeeds, or show output if the max number of retries is reached.
#
# Usage: run_command_until_success wait_text max_attempts command...
# Example: run_command_until_success "Waiting for command..." 5 command arg1 arg2
run_command_until_success() {
    local wait_text="${1:?${FUNCNAME[0]}: Wait text is required}"
    local max_attempts="${2:?${FUNCNAME[0]}: Max attempts is required}"
    shift
    shift
    local count=0

    while ! run_verbose_no_errors "$@"; do
        count=$((count + 1))
        if [[ $count -ge "$max_attempts" ]]; then
            print_error "Max attempts reached. Showing error info..."
            "$@"
            exit 1
        fi
        print_info "$wait_text"
        sleep 2
    done
}

# Load a .env file file from the environment directory. The global .env file is a special case, as it is loaded from the
# repository root. Variables are sourced as non-exported global variables.
#
# Usage: load_dotenv dotenv_files...
# Example: load_dotenv .env example.env example.local.env
load_dotenv() {
    for env_file in "$@"; do
        local env_file_path
        if [[ "$env_file" = ".env" ]]; then
            env_file_path="$git_base_dir/$env_file"
        else
            env_file_path="$git_base_dir/environment/$env_file"
        fi

        if [[ -f "$env_file_path" ]]; then
            source "$env_file_path"
        else
            print_error "Environment file not found: $env_file. Did you run the setup script?"
            exit 1
        fi
    done
}

# Argument parsing framework
# Uses a lot of Bash parameter expansion tricks: https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion
argument_variables=()
required_argument_variable_indices=()
positional_argument_variables=()
option_cases=""

help_text_description=""
help_text_usage_arguments=()
help_text_arguments=()
help_text_argument_descriptions=()

# Sets the description of the overall script in the help text.
#
# Usage: set_description description
# Example: set_description "This script sets up the configuration."
set_description() {
    help_text_description="$*"
}

# Adds a boolean option to the script. The variable is set to true if the option is provided or an empty string if it
# is not. The description is shown in the help text.
#
# Usage: add_option options variable_name description
# Example: add_option "-o --option" "option_enabled" "Enables the option"
add_option() {
    local options="${1:?${FUNCNAME[0]}: Option arguments are required}"
    local variable="${2:?${FUNCNAME[0]}: Option variable is required}"
    local description="${3:?${FUNCNAME[0]}: Option description is required}"

    argument_variables+=("$variable")
    option_cases+="
    ${options// /|})
        $variable=true
        shift
        ;;"

    help_text_usage_arguments+=("[${options// / | }]")
    help_text_arguments+=("${options// /, }")
    help_text_argument_descriptions+=("$description")
}

# Adds an option that allows specifying a value to the script. The variable is set to the value provided or an empty
# string if the option is not provided. The value name and description are shown in the help text. If the option is
# required, the script will exit with an error if the option is not provided. If a default value is set, the variable
# will be set to the default value if the option is provided without a value.
#
# Usage: add_option_with_value options variable_name value_name description required [default_value]
# Example: add_option_with_value "-o --option" "option_value" "option-value" "Sets the option value" false "default value"
add_option_with_value() {
    local options="${1:?${FUNCNAME[0]}: Option arguments are required}"
    local variable="${2:?${FUNCNAME[0]}: Option variable is required}"
    local value_name="${3:?${FUNCNAME[0]}: Option value name is required}"
    local description="${4:?${FUNCNAME[0]}: Option description is required}"
    local required="${5:?${FUNCNAME[0]}: Option requirement boolean is required}"
    local default_value="${6:-}"

    argument_variables+=("$variable")

    if [[ -n "$default_value" ]]; then
        # If the argument after this is another option, it should not be set as this option's value and the
        # arguments should only be shifted once. If this is the last argument, shift errors can be safely ignored.
        option_cases+="
        ${options// /|})
            shift
            $variable=\"\${1:-}\"
            if [[ \"\$$variable\" == -* ]]; then
                $variable=
            else
                shift || true
            fi
            if [[ -z \"\$$variable\" ]]; then
                $variable=\"$default_value\"
            fi
            ;;"
    else
        option_cases+="
        ${options// /|})
            shift
            $variable=\"\${1:-}\"
            if [[ \"\$$variable\" == -* ]]; then
                $variable=
            else
                shift || true
            fi
            if [[ -z \"\$$variable\" ]]; then
                print_error \"Option ${options// /, } requires a value for <$value_name>\"
                options_error=true
            fi
            ;;"
    fi

    if [[ "$required" = true ]]; then
        required_argument_variable_indices+=($((${#argument_variables[@]} - 1)))
        help_text_usage_arguments+=("${options// / | } <$value_name>")
        help_text_arguments+=("${options// /, } <$value_name>")
        help_text_argument_descriptions+=("$description (required)")
    else
        help_text_usage_arguments+=("[${options// / | } <$value_name>]")
        help_text_arguments+=("${options// /, } <$value_name>")
        help_text_argument_descriptions+=("$description (optional${default_value:+, default: $default_value})")
    fi
}

# Adds a positional argument to the script. The variable is set to the value provided. If the argument is required, the
# script will exit with an error if the argument is not provided.
#
# Usage: add_positional_argument name variable_name description required
# Example: add_positional_argument "file-name" "file_name" "The file to process" true
add_positional_argument() {
    local name="${1:?${FUNCNAME[0]}: Argument name is required}"
    local variable="${2:?${FUNCNAME[0]}: Argument variable is required}"
    local description="${3:?${FUNCNAME[0]}: Argument description is required}"
    local required="${4:?${FUNCNAME[0]}: Argument requirement boolean is required}"

    argument_variables+=("$variable")
    positional_argument_variables+=("$variable")

    if [[ "$required" = true ]]; then
        required_argument_variable_indices+=($((${#argument_variables[@]} - 1)))
        help_text_usage_arguments+=("<$name>")
        help_text_arguments+=("<$name>")
        help_text_argument_descriptions+=("$description (required)")
    else
        help_text_usage_arguments+=("[<$name>]")
        help_text_arguments+=("<$name>")
        help_text_argument_descriptions+=("$description (optional)")
    fi
}

# Parses the provided arguments and sets the variables based on the configured options and positional arguments. Check
# if options are enabled or arguments are provided by using `if [[ -n "$option_variable" ]]`.
#
# Usage: parse_arguments "$@"
parse_arguments() {
    local positional_arguments=()
    local variable
    for variable in "${argument_variables[@]}"; do
        # Variables should start out global and empty strings
        declare -g "$variable="
    done

    # Keep verbosity if it was set in a previous script
    show_verbose="${SHOW_VERBOSE:-}"

    # Split combined short options into individual options
    local split_args=()
    local arg
    for arg in "$@"; do
        # Regex matches a single dash followed by any characters are not other dashes
        if [[ "$arg" =~ ^-[^-]+$ ]]; then
            for ((i = 1; i < ${#arg}; i++)); do
                split_args+=("-${arg:$i:1}")
            done
        else
            split_args+=("$arg")
        fi
    done

    # Replace the original arguments with the split ones
    set -- "${split_args[@]}"

    while [[ $# -gt 0 ]]; do
        # It is very important to use \$1 instead of $1 here to prevent command injection
        eval "case \"\$1\" in
        $option_cases
        -*)
            print_error \"Unknown option: \$1\"
            options_error=true
            shift
            ;;
        *)
            positional_arguments+=(\"\$1\")
            shift
            ;;
        esac"
    done

    # Show help before validating arguments
    if [[ -n "$show_help" ]]; then
        show_help
        exit 0
    fi

    # Validate the provided arguments
    if [[ -n "${options_error:-}" ]]; then
        # Errors were already displayed in the case statement
        exit 1
    fi

    # Validate the number of positional arguments before setting variables to avoid going out of range
    if [[ "${#positional_arguments[@]}" -gt "${#positional_argument_variables[@]}" ]]; then
        print_error "Too many positional arguments provided"
        exit 1
    fi
    local i
    for i in "${!positional_arguments[@]}"; do
        declare -g "${positional_argument_variables[i]}=${positional_arguments[$i]}"
    done

    for i in "${required_argument_variable_indices[@]}"; do
        if [[ -z "${!argument_variables[i]}" ]]; then
            print_error "Required argument not provided: ${help_text_arguments[i]}"
            exit 1
        fi
    done

    # Export verbosity for the next script
    export SHOW_VERBOSE="${show_verbose:-}"
}

# Shows the auto-generated help text based on the configured options and positional arguments.
show_help() {
    echo "Usage: $0 ${help_text_usage_arguments[*]}"
    if [[ -n "$help_text_description" ]]; then
        echo "Description: $help_text_description"
    fi

    if [[ "${#help_text_arguments[@]}" -ne 0 ]]; then
        local max_argument_length=0
        local argument
        for argument in "${help_text_arguments[@]}"; do
            if [[ "${#argument}" -gt "$max_argument_length" ]]; then
                max_argument_length="${#argument}"
            fi
        done

        echo
        echo "Arguments:"
        local i
        for i in "${!help_text_arguments[@]}"; do
            printf "  %-${max_argument_length}s  %s\n" "${help_text_arguments[$i]}" "${help_text_argument_descriptions[$i]}"
        done
    fi
}

add_option "-h --help" "show_help" "Displays this help message"
add_option "-v --verbose" "show_verbose" "Enables verbose output"
