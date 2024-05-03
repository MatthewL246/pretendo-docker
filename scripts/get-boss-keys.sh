#! /bin/sh

set -eu

write_keys=false
if [ "${1-}" = "--write" ]; then
    write_keys=true
fi

expected_ds_aes_key_hash="86fbc2bb4cb703b2a4c6cc9961319926"
expected_wiiu_aes_key_hash="5202ce5099232c3d365e28379790a919"
expected_wiiu_hmac_key_hash="b4482fef177b0100090ce0dbeb8ce977"

git_base=$(git rev-parse --show-toplevel)
. "$git_base/scripts/internal/function-lib.sh"
cd "$git_base/console-files"

if ls ./boss_keys.bin 1>/dev/null 2>&1; then
    wiiu_aes_key=$(head -c 16 <./boss_keys.bin)
    wiiu_hmac_key=$(tail -c +33 ./boss_keys.bin | head -c 64)
    wiiu_aes_key_hash=$(printf "%s" "$wiiu_aes_key" | md5sum | cut -d ' ' -f 1)
    wiiu_hmac_key_hash=$(printf "%s" "$wiiu_hmac_key" | md5sum | cut -d ' ' -f 1)

    if [ "$wiiu_aes_key_hash" = "$expected_wiiu_aes_key_hash" ]; then
        success "Found valid Wii U BOSS AES key."
        if [ "$write_keys" = true ]; then
            echo "PN_BOSS_CONFIG_BOSS_WIIU_AES_KEY=$wiiu_aes_key" >>"$git_base/environment/boss.local.env"
        fi
    else
        error "Wii U BOSS AES key has the wrong hash! Try re-running full_keys_dumper."
        exit 1
    fi

    if [ "$wiiu_hmac_key_hash" = "$expected_wiiu_hmac_key_hash" ]; then
        success "Found valid Wii U HMAC key."
        if [ "$write_keys" = true ]; then
            echo "PN_BOSS_CONFIG_BOSS_WIIU_HMAC_KEY=$wiiu_hmac_key" >>"$git_base/environment/boss.local.env"
        fi
    else
        error "Wii U BOSS HMAC key has the wrong hash! Try re-running full_keys_dumper."
        exit 1
    fi
else
    warning "console-files/boss_keys.bin (Wii U) not found! Please read the README for instructions on dumping your BOSS keys."
fi

if ls ./aes_keys.txt 1>/dev/null 2>&1; then
    ds_aes_key=$(grep -oP 'slot0x38KeyN=\K.*' ./aes_keys.txt)
    ds_aes_key_bin=$(printf "%s" "$ds_aes_key" | xxd -r -p)
    ds_aes_key_hash=$(printf "%s" "$ds_aes_key_bin" | md5sum | cut -d ' ' -f 1)

    if [ "$ds_aes_key_hash" = "$expected_ds_aes_key_hash" ]; then
        success "Found valid 3DS BOSS AES key."
        if [ "$write_keys" = true ]; then
            echo "PN_BOSS_CONFIG_BOSS_3DS_AES_KEY=$ds_aes_key" >>"$git_base/environment/boss.local.env"
        fi
    else
        error "3DS BOSS AES key has the wrong hash! Try re-running DumpKeys.gm9."
        exit 1
    fi
else
    warning "console-files/aes_keys.txt (3DS) not found! Please read the README for instructions on dumping your BOSS keys."
fi
