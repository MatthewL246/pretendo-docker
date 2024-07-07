#!/usr/bin/env bash

set -euo pipefail

check_prerequisites() {
    prerequisites_failed=
    prerequisites_warning=
    if ! run_verbose docker version; then
        print_error "Docker is not installed. Please install it: https://docs.docker.com/get-docker/"
        print_info "If you see a \"Permission denied while trying to connect to the Docker daemon\" error, you need to \
add your user to the docker group: https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user."
        prerequisites_failed=true
    fi
    if ! run_verbose docker compose version; then
        print_error "Docker Compose is not installed. Please install it: https://docs.docker.com/compose/install/"
        prerequisites_failed=true
    fi
    # The tnftp "enhanced ftp client" has the -u option for direct uploads,
    # unlike the netkit-ftp "classical ftp client"
    if ! run_verbose command -v tnftp; then
        print_warning "tnftp is not installed. You will not be able to upload files to your consoles automatically."
        prerequisites_warning=true
    fi

    if [[ "$prerequisites_failed" = true ]]; then
        print_error "Prerequisites check failed. Please install the missing prerequisites and try again."
        exit 1
    elif [[ "$prerequisites_warning" = true ]]; then
        print_warning "Prerequisites check completed with warnings."

        if [[ -z "$force" ]]; then
            printf "Do you want to continue anyway (y/N)? "
            read -r continue_anyway
            if [[ "$continue_anyway" != "Y" && "$continue_anyway" != "y" ]]; then
                echo "Aborting."
                exit 1
            fi
        fi
    else
        print_success "All prerequisites are installed."
    fi
}

setup_environment_variables() {
    if [[ -n "$reconfigure" || (-z "$server_ip" && ! -f "$git_base_dir/.env") ]]; then
        echo "Enter the IP address of your Pretendo Network server. It must be accessible to your console."
        read -r server_ip
        echo "Enter the IP address of your Wii U (optional). It is used for automatic FTP uploads."
        read -r wiiu_ip
        echo "Enter the IP address of your 3DS (optional). It is used for automatic FTP uploads."
        read -r ds_ip
    fi

    ./scripts/setup-environment.sh ${server_ip:+--server-ip "$server_ip"} ${wiiu_ip:+--wiiu-ip "$wiiu_ip"} ${ds_ip:+--3ds-ip "$ds_ip"} ${force:+--force} ${reconfigure:+--no-environment}
}

setup_containers() {
    ./scripts/internal/firstrun-mongodb-container.sh
    ./scripts/internal/firstrun-minio-container.sh
    ./scripts/internal/update-account-servers-database.sh
    ./scripts/internal/update-miiverse-endpoints.sh
    ./scripts/internal/update-postgres-password.sh
    ./scripts/internal/migrations.sh
    print_info "Stopping containers after initial setup..."
    compose_no_progress down
}

export PRETENDO_SETUP_IN_PROGRESS=true

# Temporary function because the framework script isn't sourced yet and we don't know if tput is available
print_error() {
    echo -e "\e[1;31mError: ${*}\e[0m" >&2
}

# The framework script requires git and tput, so check for them first
if ! tput setaf 0 >/dev/null; then
    print_error "Either the tput command is not installed, or your \$TERM environment variable is not set correctly. \
Please install your distribution's ncurses package (such as ncurses-bin) and/or configure your terminal to set \$TERM."
    exit 1
fi
if ! git --version >/dev/null; then
    print_error "Git is not installed. Please install it: https://git-scm.com/downloads/"
    exit 1
fi

# shellcheck source=./scripts/internal/framework.sh
source "$(dirname "$(realpath "$0")")/scripts/internal/framework.sh"
set_description "This is the main setup script for your self-hosted Pretendo Network server. By default, it will prompt \
for configuration values the first run and re-use those values for future runs."
add_option "-r --reconfigure" "reconfigure" "Always shows configuration prompts, even if the values are already set. \
Also disables reading configuration values from the environment."
add_option "-f --force" "force" "Ignores warnings and confirmation prompts during the setup process."
add_option_with_value "-s --server-ip" "server_ip" "IP-address" "The IP address of your Pretendo Network server. It \
must be accessible to your console. Disables interactive prompts by default, unless --force-interactive is specified." false
add_option_with_value "-w --wiiu-ip" "wiiu_ip" "IP-address" "The IP address of your Wii U. It is used for automatic FTP uploads." false
add_option_with_value "-3 --3ds-ip" "ds_ip" "IP-address" "The IP address of your 3DS. It is used for automatic FTP uploads." false
parse_arguments "$@"

print_title "Unofficial Pretendo Network server setup script started"

git config --local submodule.recurse true

print_stage "Checking prerequisites."
check_prerequisites

print_stage "Setting up submodules and applying patches."
./scripts/setup-submodule-patches.sh

print_stage "Setting up environment variables."
setup_environment_variables

print_stage "Pulling Docker images."
docker compose pull

print_stage "Building Docker images."
docker compose build

print_stage "Setting up containers with first-run scripts."
setup_containers

print_title "Pretendo Network server setup script finished"
print_success "Setup completed! You can now start your Pretendo Network server with \"docker compose up -d --build\"."
