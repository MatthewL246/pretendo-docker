#! /bin/sh

set -eu

check_git_repository() {
    # Temporary function because function-lib isn't sourced yet
    error() {
        echo "$(tput bold)$(tput setaf 1)Error: ${*}$(tput sgr0)" >&2
    }

    if ! git --version >/dev/null; then
        error "Git is not installed. Please install it: https://git-scm.com/downloads/"
        exit 1
    fi
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        error "This script must be run from inside the pretendo-docker Git repository."
        echo "Make sure that you cloned the repository with Git, not downloaded it as a ZIP file from GitHub."
        exit 1
    fi
    if [ "$(basename -s .git "$(git config --get remote.origin.url)")" != "pretendo-docker" ]; then
        error "This script must be run from inside the pretendo-docker Git repository."
        echo "It looks like you are running it from a different Git repository at $(pwd) from $(git config --get remote.origin.url)."
        exit 1
    fi
}

check_prerequisites() {
    prerequisites_failed=false
    prerequisites_warning=false
    if ! docker version >/dev/null; then
        error "Docker is not installed. Please install it: https://docs.docker.com/get-docker/"
        info "If you see a \"Permission denied while trying to connect to the Docker daemon\" error, you need to run this script with sudo."
        prerequisites_failed=true
    fi
    if ! docker compose version >/dev/null; then
        error "Docker Compose is not installed. Please install it: https://docs.docker.com/compose/install/"
        prerequisites_failed=true
    fi
    # The tnftp "enhanced ftp client" has the -u option for direct uploads,
    # unlike the netkit-ftp "classical ftp client"
    if ! command -v tnftp >/dev/null; then
        warning "tnftp is not installed. You will not be able to upload files to your consoles automatically."
        prerequisites_warning=true
    fi

    if [ "$prerequisites_failed" = true ]; then
        error "Prerequisites check failed. Please install the missing prerequisites and try again."
        exit 1
    elif [ "$prerequisites_warning" = true ]; then
        warning "Prerequisites check completed with warnings."

        if [ -z "${CI+x}" ]; then
            # Optional prerequisites can be ignored in CI
            printf "Do you want to continue anyway (y/N)? "
            read -r continue_anyway
            if [ "$continue_anyway" != "Y" ] && [ "$continue_anyway" != "y" ]; then
                exit 1
            fi
        fi
    else
        success "All prerequisites are installed."
    fi

}

setup_environment_variables() {
    if [ -n "${CI+x}" ]; then
        warning "It looks like the script is running in CI. Using test IP addresses."
        server_ip="0.0.0.0"
        wiiu_ip=""
        ds_ip=""
    else
        echo "Enter the IP address of your Pretendo Network server. It must be accessible to your console."
        read -r server_ip
        echo "Enter the IP address of your Wii U (optional). It is only used for automatic FTP uploads of modified Inkay patches."
        read -r wiiu_ip
        echo "Enter the IP address of your 3DS (optional). It is only used for automatic FTP uploads."
        read -r ds_ip
    fi

    ./scripts/setup-environment.sh "$server_ip" "$wiiu_ip" "$ds_ip"
}

setup_containers() {
    info "Setting up MongoDB container..."
    ./scripts/firstrun-mongodb-container.sh
    info "Setting up MinIO container..."
    ./scripts/firstrun-minio-container.sh
    info "Setting up Pretendo account servers database..."
    ./scripts/update-account-servers-database.sh
    info "Setting up Pretendo Miiverse endpoints database..."
    ./scripts/update-miiverse-endpoints.sh
    info "Updating Postgres password..."
    ./scripts/update-postgres-password.sh
    info "Stopping containers after initial setup..."
    docker compose down
}

export PRETENDO_SETUP_IN_PROGRESS=true

check_git_repository

git_base=$(git rev-parse --show-toplevel)
cd "$git_base"
. "$git_base/scripts/.function-lib.sh"

title "Unofficial Pretendo Network setup script"
header "Pretendo setup script started at $(date)."

stage "Checking prerequisites."
check_prerequisites

stage "Setting up submodules and applying patches."
./scripts/setup-submodule-patches.sh

stage "Setting up environment variables."
setup_environment_variables

stage "Pulling Docker images."
docker compose pull

stage "Building Docker images."
docker compose build

stage "Setting up containers with first-run scripts."
setup_containers

success "Setup completed! You can now start your Pretendo Network server with \"docker compose up -d\"."
header "Pretendo setup script finished at $(date)."
