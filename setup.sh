#! /bin/sh

set -eu

check_git_repository() {
    # Temporary function because function-lib isn't sourced yet
    error() {
        echo "$(tput bold)$(tput setaf 1)Error: ${*}$(tput sgr0)" >&2
    }

    if ! git --version >/dev/null 2>&1; then
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
    if ! docker version >/dev/null 2>&1; then
        error "Docker is not installed. Please install it: https://docs.docker.com/get-docker/"
        prerequisites_failed=true
    fi
    if ! docker compose version >/dev/null 2>&1; then
        error "Docker Compose is not installed. Please install it: https://docs.docker.com/compose/install/"
        prerequisites_failed=true
    fi

    if [ "$prerequisites_failed" = true ]; then
        error "Prerequisites check failed. Please install the missing prerequisites and try again."
        exit 1
    fi

    success "All prerequisites are installed."
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
echo "Enter the IP address of your Pretendo Network server. It must be accessible to your console."
read -r server_ip
echo "Enter the IP address of your Wii U (optional). It is only used for automatic FTP uploads of modified Inkay patches."
read -r wiiu_ip
./scripts/setup-environment.sh "$server_ip" "$wiiu_ip"

stage "Pulling Docker images."
docker compose pull

stage "Building Docker images."
docker compose build

stage "Setting up containers with first-run scripts."
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

success "Setup completed! You can now start your Pretendo Network server with \"docker compose up -d\"."
header "Pretendo setup script finished at $(date)."
