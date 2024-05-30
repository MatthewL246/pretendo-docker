---
sidebar_position: 2
pagination_prev: setup/connecting/index
pagination_next: setup/next-steps
---

# Wii U

This guide will show you how to access your server from a Wii U console.

:::note[Optional: dumping BOSS keys]

You may now dump the BOSS keys from your console for use in the BOSS (SpotPass) server. These keys are **only required
if you want to create new Wii U SpotPass content**.

_These steps are based on the
[guide from the boss-crypto repository](https://github.com/PretendoNetwork/boss-crypto/#dumping-crypto-keys)._

1. Download [Full Key Dumper](https://github.com/EpicUsername12/Full_Key_Dumper/releases) and run the ELF from the
   Tiramisu environment (this program does not support Aroma). Then, copy the file `SD:/boss_keys.bin` from your SD card
   to the `console-files` directory in this repo.
2. Run `./scripts/get-boss-keys.sh` to validate the dumped keys. It will show you if the keys are missing or incorrect.
3. If it reports that the Wii U BOSS keys are valid, run `./scripts/setup-environment.sh` to reconfigure the servers
   with the BOSS keys.

:::

## Connecting

1. Follow the [official Pretendo Network Wii U installation guide](https://pretendo.network/docs/install/wiiu#inkay) to
   install the Inkay patches. **Do not create a new PNID yet.** At this point, you should be connected to the official
   Pretendo.
2. Open
   `System Settings => Internet => Connect to the Internet => Connections => (Your current internet connection) => Change Settings`.
3. Go to `Proxy Settings => Set => OK`. Set the proxy server to your server's IP address and the port to 8080. Then, tap
   `Confirm => Don't Use Authentication`.
4. Save the settings and go back to the Home Menu. Check your mitmproxy logs at [127.0.0.1:8081](http://127.0.0.1:8081)
   to verify that the console is sending HTTP requests through your proxy.
5. Start an FTP server on your console. Then, run `./scripts/compile-custom-inkay.sh` to compile a custom version of the
   Inkay patches that uses your own mitmproxy certificate, which is required to connect.
6. Reboot your console.
7. Create a new PNID on your console from the users page.

:::warning

Make sure that the license agreement page has the custom text "Welcome to your self-hosted Pretendo Network server!". If
it does not, your proxy settings did not apply correctly and you are still connected to the official Pretendo Network
servers.

:::

## Changing which server you are connected to

|                                 | Inkay build                                                  | Inkay patching | Proxy settings                             |
| ------------------------------- | ------------------------------------------------------------ | -------------- | ------------------------------------------ |
| **Self-hosted Pretendo server** | Custom (run `./scripts/compile-custom-inkay.sh`)             | Enabled        | Enabled, set to the server IP, port `8080` |
| **Official Pretendo server**    | Unmodified (run `./scripts/compile-custom-inkay.sh --reset`) | Enabled        | Disabled                                   |
| **Nintendo server**             | N/A                                                          | Disabled       | Disabled                                   |
