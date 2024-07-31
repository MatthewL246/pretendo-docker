#!/usr/bin/env bash

# shellcheck source=./internal/framework.sh
source "$(dirname "$(realpath "$0")")/internal/framework.sh"
set_description "This creates the necessary files for Cemu online play with Pretendo as an alternative to using Dumpling.\
It can also create fake OTP and SEEPROM dumps, which will only work on servers with console verification disabled."
add_option "-f --force" "force" "Always overwrite the existing online files in the output directory without asking"
add_option "-d --fake-dumps" "fake_dumps" "Create fake OTP and SEEPROM dumps (with all null bytes) in addition to the account.dat file"
add_option_with_value "-i --persistent-id" "persistent_id" "id" "The persistent ID to use for the account.dat file" false "80000001"
add_option_with_value "-o --output" "output_dir" "directory" "The output directory for the online files" false "./online-files"
add_option_with_value "-p --password" "password" "password" "The password to use for the account.dat file (if not provided, you will be prompted to enter a password)" false
add_positional_argument "pnid" "pnid" "The PNID to create an account.dat file" true
parse_arguments "$@"

if [[ -z "$password" ]]; then
    printf "Enter the password for PNID $pnid: "
    read -rs password
    echo
fi

account_dat_path="$output_dir/mlc01/usr/save/system/act/$persistent_id/account.dat"
otp_path="$output_dir/otp.bin"
seeprom_path="$output_dir/seeprom.bin"
if [[ -n "$fake_dumps" ]]; then
    paths=("$account_dat_path" "$otp_path" "$seeprom_path")
else
    paths=("$account_dat_path")
fi

needs_confirmation=false
for path in "${paths[@]}"; do
    mkdir -p "$(dirname "$path")"
    if [[ -f "$path" ]]; then
        print_warning "Output file $path already exists. Continuing will overwrite it!"
        needs_confirmation=true
    fi
done
if [[ "$needs_confirmation" == true && -z "$force" ]]; then
    printf "Continue? [y/N] "
    read -r continue
    if [[ "$continue" != "Y" && "$continue" != "y" ]]; then
        echo "Aborting."
        exit 1
    fi
fi

print_info "Generating online files for PNID $pnid..."

compose_no_progress up -d account

create_account_dat_script=$(cat "$git_base_dir/scripts/run-in-container/create-account-dat.js")

docker compose exec -u root account sh -c "touch /tmp/account.dat && chmod 777 /tmp/account.dat"
run_verbose docker compose exec account node -e "$create_account_dat_script" "$pnid" "$password" "$persistent_id"

compose_no_progress cp account:/tmp/account.dat "$account_dat_path"
docker compose exec -u root account rm -f /tmp/account.dat

if [[ -n "$fake_dumps" ]]; then
    print_info "Creating fake OTP and SEEPROM dumps..."
    head -c 1024 /dev/zero >"$otp_path"
    head -c 512 /dev/zero >"$seeprom_path"
fi

print_success "Successfully generated online files for PNID $pnid."
