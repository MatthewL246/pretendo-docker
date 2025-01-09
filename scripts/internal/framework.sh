#!/usr/bin/env bash

# Usage:
# # shellcheck source=./internal/framework.sh
# source "$(dirname "$(realpath "$0")")/internal/framework.sh"
# set_description "Script description goes here"
# # Add options and arguments here
# parse_arguments "$@"

# Update the script path to be the correct relative path to framework.sh

# Basic setup
set -Eeuo pipefail

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    echo "The framework script needs to be sourced, not executed."
    exit 1
fi

if [[ -n "${SCRIPT_USES_FRAMEWORK:-}" ]]; then
    # This script is being run from another script
    nested_script=true
fi

# Provide the Git base directory
original_dir="$(pwd)"
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

# Handle errors in the scripts, inspired by Python tracebacks
error_handler() {
    local exit_code=$?
    local stacktrace=()
    cd "$original_dir"

    # The first element of the stack is the error_handler function itself
    local stack_depth=$((${#BASH_SOURCE[@]} - 1))
    for ((i = stack_depth - 1; i >= 0; i--)); do
        local source_file="${BASH_SOURCE[i + 1]}"
        local line_number="${BASH_LINENO[i]}"
        local containing_function="${FUNCNAME[i + 1]}"

        local stacktrace_source=$'\n  '
        stacktrace_source+="$source_file: line $line_number, in $containing_function"
        stacktrace+=("$stacktrace_source")

        local stacktrace_line=$'\n    '
        stacktrace_line+=$(head -n "$line_number" "$source_file" | tail -n 1 | sed 's/^[ \t]*//')
        stacktrace+=("$stacktrace_line")
    done
    stacktrace+=($'\n'"$BASH_COMMAND: exited with code $exit_code")

    echo
    print_error "The script $0 exited unexpectedly because an error occurred.${stacktrace[*]}"

    if [[ -z "${nested_script:-}" ]]; then
        print_header "pretendo-docker commit $(git rev-parse --short HEAD)"

        echo
        echo "General steps to troubleshoot the issue:"
        if [[ -z "${show_verbose:-}" ]]; then
            echo "- Re-run this script with the --verbose option to see more detailed output."
        fi
        echo "- Check the script output and stack trace above for more details about the error."
        echo "- Research the error message shown above the stack trace and try to find a solution."
        echo "- Search previously-reported issues at https://github.com/MatthewL246/pretendo-docker/issues?q=is%3Aissue."
        echo "- If you believe this is a bug or need help, please create an issue at https://github.com/MatthewL246/pretendo-docker/issues/new."
        echo "${term_bold}Make sure to include ${term_magenta}${term_underline}ALL of the script's output${term_reset}${term_bold} shown above this help text when creating an issue.${term_reset}"
    fi

    exit $exit_code
}

trap error_handler ERR

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

# Run a Docker Compose command without showing progress unless the verbose option is set
compose_no_progress() {
    # shellcheck disable=SC2046
    docker compose $(if_not_verbose --progress quiet) "$@"
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

# Output the provided text if the verbose option is set.
#
# Usage: if_verbose text...
# Example: command $(if_verbose --verbose)
if_verbose() {
    if [[ -n "$show_verbose" ]]; then
        echo "$*"
    fi
}

# Output the provided text unless the verbose option is set.
#
# Usage: if_not_verbose text...
# Example: command $(if_not_verbose --quiet)
if_not_verbose() {
    if [[ -z "$show_verbose" ]]; then
        echo "$*"
    fi
}

# Detect when the script is being run in a Bash on Windows environment like Git Bash, Cygwin, MSYS2, or a shell compiled
# with MinGW. All scripts are designed to be run inside a WSL2 distro when running on Windows, and running them in other
# environments tends to cause various hard-to-debug issues, mainly when interacting with Docker.

windows_detected=false

# $OS seems to be the most reliable, as it was set in all the environments I checked
if [[ "${OS:-}" = "Windows_NT" ]]; then
    windows_detected=true
fi
# $OSTYPE was also set in all the environments I checked
if [[ "${OSTYPE:-}" =~ msys|cygwin ]]; then
    windows_detected=true
fi
# uname should always work as a backup, even if the environment variables are not set as expected
if [[ "$(uname -so | tr "[:upper:]" "[:lower:]")" =~ mingw|msys|cygwin ]]; then
    windows_detected=true
fi

if [[ "$windows_detected" = true ]]; then
    print_error "It looks like you are using Windows, but you are not running this script inside a WSL2 distro."
    echo
    print_info "All pretendo-docker scripts are designed to be run inside your WSL2 distro when running on Windows."
    print_info "However, it looks like you are running this script in a different Bash on Windows environment (like Git Bash, Cygwin, MSYS2, or MinGW). Running in these environments tends to cause various hard-to-debug issues."
    echo
    echo "Note that this issue can be caused by running the script from a Windows shell (like PowerShell or Command Prompt) or by double-clicking it, as Windows will automatically run it with your default app for opening .sh files."
    echo
    print_info "${term_bold}Please run this script directly from Bash in your primary WSL2 distro instead."
    exit 1
fi

# Argument parsing framework
# Uses a lot of Bash parameter expansion tricks: https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion
argument_variables=()
argument_variable_defaults=()
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

# Adds a boolean option to the script. The description is shown in the help text.
#
# If the option is provided to the script:
#   - The variable is set to true.
# If the option is not provided to the script:
#   - The variable is set to an empty string.
#
# Usage: add_option options variable_name description
# Example: add_option "-o --option" "option_enabled" "Enables the option"
add_option() {
    local options="${1:?${FUNCNAME[0]}: Option arguments are required}"
    local variable="${2:?${FUNCNAME[0]}: Option variable is required}"
    local description="${3:?${FUNCNAME[0]}: Option description is required}"

    argument_variables+=("$variable")
    argument_variable_defaults+=("")
    option_cases+="
        ${options// /|})
            $variable=true
            shift
            ;;"

    help_text_usage_arguments+=("[${options// / | }]")
    help_text_arguments+=("${options// /, }")
    help_text_argument_descriptions+=("$description")
}

# Adds an option that allows specifying a value to the script. The value name and description are shown in the help
# text. An option cannot be required and have a default value at the same time.
#
# If the option is provided to the script with a value:
#   - The variable is set to the value specified.
# If the option is provided to the script without a value:
#   - If the "default value if specified" is set, the variable is set to this value.
#   - Otherwise, the script exits with an error.
# If the option is not provided to the script:
#   - If the default value is set, the variable is set to this value.
#   - Otherwise, if the option is required, the script exits with an error.
#   - Otherwise, the variable is set to an empty string.
#
# Usage: add_option_with_value options variable_name value_name description required [default_value] [default_value_if_provided]
# Example: add_option_with_value "-o --option" "option_value" "value" "Sets the option value" false "default value" "option provided"
add_option_with_value() {
    local options="${1:?${FUNCNAME[0]}: Option arguments are required}"
    local variable="${2:?${FUNCNAME[0]}: Option variable is required}"
    local value_name="${3:?${FUNCNAME[0]}: Option value name is required}"
    local description="${4:?${FUNCNAME[0]}: Option description is required}"
    local required="${5:?${FUNCNAME[0]}: Option requirement boolean is required}"
    local default_value="${6:-}"
    local default_value_if_provided="${7:-}"

    if [[ "$required" = true && -n "$default_value" ]]; then
        print_error "Option with value cannot be required and have a default value at the same time: $options"
        exit 1
    fi

    argument_variables+=("$variable")
    argument_variable_defaults+=("$default_value")

    # If the argument after this is another option, it should not be set as this option's value and the arguments should
    # only be shifted once. If this is the last argument, shift errors can be safely ignored.
    option_cases+="
        ${options// /|})
            shift
            local next=\"\${1:-}\"
            if [[ \"\$next\" != -* ]]; then
                $variable=\"\$next\"
                shift || true
            fi
            if [[ -z \"\$$variable\" ]]; then
                if [[ -z \"$default_value_if_provided\" ]]; then
                    print_error \"Option ${options// /, } requires a value for <$value_name>\"
                    options_error=true
                else
                    $variable=\"$default_value_if_provided\"
                fi
            fi
            ;;"

    help_text_arguments+=("${options// /, } <$value_name>")

    if [[ "$required" = true ]]; then
        required_argument_variable_indices+=($((${#argument_variables[@]} - 1)))
        help_text_usage_arguments+=("${options// / | } <$value_name>")
        description+=" (required)"
    else
        help_text_usage_arguments+=("[${options// / | } <$value_name>]")
        description+=" (optional${default_value:+, default: $default_value}${default_value_if_provided:+, default if provided without <$value_name>: $default_value_if_provided})"
    fi

    help_text_argument_descriptions+=("$description")
}

# Adds a positional argument to the script. The name and description are shown in the help text. An argument cannot be
# required and have a default value at the same time.
#
# If the argument is provided to the script:
#   - The variable is set to the value provided.
# If the argument is not provided to the script:
#   - If a default value is set, the variable is set to that value.
#   - Otherwise, if the argument is required, the script exits with an error.
#   - Otherwise, the variable is set to an empty string.
#
# Usage: add_positional_argument name variable_name description required [default_value]
# Example: add_positional_argument "file-name" "file_name" "The file to process" false "file.txt"
add_positional_argument() {
    local name="${1:?${FUNCNAME[0]}: Argument name is required}"
    local variable="${2:?${FUNCNAME[0]}: Argument variable is required}"
    local description="${3:?${FUNCNAME[0]}: Argument description is required}"
    local required="${4:?${FUNCNAME[0]}: Argument requirement boolean is required}"
    local default_value="${5:-}"

    if [[ "$required" = true && -n "$default_value" ]]; then
        print_error "Positional argument cannot be required and have a default value at the same time: $name"
        exit 1
    fi

    argument_variables+=("$variable")
    argument_variable_defaults+=("$default_value")
    positional_argument_variables+=("$variable")

    help_text_arguments+=("<$name>")

    if [[ "$required" = true ]]; then
        required_argument_variable_indices+=($((${#argument_variables[@]} - 1)))
        help_text_usage_arguments+=("<$name>")
        description+=" (required)"
    else
        help_text_usage_arguments+=("[<$name>]")
        description+=" (optional${default_value:+, default: $default_value})"
    fi

    help_text_argument_descriptions+=("$description")
}

# Parses the provided arguments and sets the argument variables based on the configured options and positional
# arguments. Check if options are enabled or arguments are provided by using `if [[ -n "$option_variable" ]]`.
#
# Usage: parse_arguments "$@"
parse_arguments() {
    local positional_arguments=()
    local i

    for i in "${!argument_variables[@]}"; do
        # Variables should start out global and assigned to their default values
        # Bash 3.2 does not support the `declare -g` syntax
        eval "${argument_variables[i]}=${argument_variable_defaults[i]}"
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
    # Bash 3.2 will throw an error when accessing an empty array
    if [[ "${#split_args[@]}" -ne "0" ]]; then
        set -- "${split_args[@]}"
    fi

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
    for i in "${!positional_arguments[@]}"; do
        eval "${positional_argument_variables[i]}=${positional_arguments[$i]}"
    done

    if [[ "${#required_argument_variable_indices[@]}" -ne 0 ]]; then
        for i in "${required_argument_variable_indices[@]}"; do
            if [[ -z "${!argument_variables[i]}" ]]; then
                print_error "Required argument not provided: ${help_text_arguments[i]}"
                exit 1
            fi
        done
    fi

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

export SCRIPT_USES_FRAMEWORK=true
