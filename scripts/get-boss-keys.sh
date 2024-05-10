#!/usr/bin/env bash

# shellcheck source=./internal/framework.sh
source "$(dirname "$(realpath "$0")")/internal/framework.sh"
set_description "This validates the BOSS keys from the dumped key files in console-files by comparing them to expected \
MD5 hashes."
add_option "-w --write" "write_keys" "Write the encryption keys to the BOSS environment file after validating"
parse_arguments "$@"

expected_ds_aes_key_hash="86fbc2bb4cb703b2a4c6cc9961319926"
expected_wiiu_aes_key_hash="5202ce5099232c3d365e28379790a919"
expected_wiiu_hmac_key_hash="b4482fef177b0100090ce0dbeb8ce977"

cd "$git_base_dir/console-files"

if [[ -f "./boss_keys.bin" ]]; then
    wiiu_aes_key=$(head -c 16 <./boss_keys.bin)
    wiiu_hmac_key=$(tail -c +33 ./boss_keys.bin | head -c 64)
    wiiu_aes_key_hash=$(echo -n "$wiiu_aes_key" | md5sum | cut -d ' ' -f 1)
    wiiu_hmac_key_hash=$(echo -n "$wiiu_hmac_key" | md5sum | cut -d ' ' -f 1)

    if [[ "$wiiu_aes_key_hash" = "$expected_wiiu_aes_key_hash" ]]; then
        print_success "Found valid Wii U BOSS AES key."
        if [[ -n "$write_keys" ]]; then
            echo "PN_BOSS_CONFIG_BOSS_WIIU_AES_KEY=$wiiu_aes_key" >>"$git_base_dir/environment/boss.local.env"
        fi
    else
        print_error "Wii U BOSS AES key has the wrong hash! Try re-running full_keys_dumper."
        exit 1
    fi

    if [[ "$wiiu_hmac_key_hash" = "$expected_wiiu_hmac_key_hash" ]]; then
        print_success "Found valid Wii U HMAC key."
        if [[ -n "$write_keys" ]]; then
            echo "PN_BOSS_CONFIG_BOSS_WIIU_HMAC_KEY=$wiiu_hmac_key" >>"$git_base_dir/environment/boss.local.env"
        fi
    else
        print_error "Wii U BOSS HMAC key has the wrong hash! Try re-running full_keys_dumper."
        exit 1
    fi
else
    print_warning "console-files/boss_keys.bin (Wii U) not found! Please read the README for instructions on dumping your BOSS keys."
fi

if [[ -f "./aes_keys.txt" ]]; then
    ds_aes_key=$(grep -oP 'slot0x38KeyN=\K.*' ./aes_keys.txt)
    ds_aes_key_bin=$(echo -n "$ds_aes_key" | xxd -r -p)
    ds_aes_key_hash=$(echo -n "$ds_aes_key_bin" | md5sum | cut -d ' ' -f 1)

    if [[ "$ds_aes_key_hash" = "$expected_ds_aes_key_hash" ]]; then
        print_success "Found valid 3DS BOSS AES key."
        if [[ -n "$write_keys" ]]; then
            echo "PN_BOSS_CONFIG_BOSS_3DS_AES_KEY=$ds_aes_key" >>"$git_base_dir/environment/boss.local.env"
        fi
    else
        print_error "3DS BOSS AES key has the wrong hash! Try re-running DumpKeys.gm9."
        exit 1
    fi
else
    print_warning "console-files/aes_keys.txt (3DS) not found! Please read the README for instructions on dumping your BOSS keys."
fi
