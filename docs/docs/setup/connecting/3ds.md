---
sidebar_position: 4
pagination_prev: setup/connecting/index
pagination_next: setup/next-steps
---

# 3DS

This guide will show you how to access your server from a 3DS console.

:::note[Optional: dumping BOSS keys]

You may now dump the BOSS keys from your console for use in the BOSS (SpotPass) server. These keys are **only required
if you want to create new 3DS SpotPass content**.

_These steps are based on the
[guide from the boss-crypto repository](https://github.com/PretendoNetwork/boss-crypto/#dumping-crypto-keys)._

1. Download the
   [Citra key dumper GodMode9 script](https://raw.githubusercontent.com/PabloMK7/citra/master/dist/dumpkeys/DumpKeys.gm9)
   and run it in GodMode9. Then, copy the `SD:/gm9/aes_keys.txt` file from your SD card to the `console-files` directory
   in this repo.
2. Run `./scripts/get-boss-keys.sh` to validate the dumped keys. It will show you if the keys are missing or incorrect.
3. If it reports that the Wii U BOSS keys are valid, run `./scripts/setup-environment.sh` to reconfigure the servers
   with the BOSS keys.

:::

## Connecting

:::warning

Due to the 3DS's account system, using a local Pretendo Network server with it requires making some potentially
dangerous modifications to the system save data.

**[Create a NAND backup](https://3ds.hacks.guide/godmode9-usage#creating-a-nand-backup) before proceeding.**

:::

1. Follow the [official Pretendo Network 3DS installation guide](https://pretendo.network/docs/install/3ds) to install
   the patches. At this point, you should be connected to the official Pretendo Network server.
2. Open
   `System Settings => Internet Settings => Connection Settings => (Your current internet connection) => Change Settings`.
3. Go to `Proxy Settings => Yes => Detailed Setup`. Set the proxy server to your server's IP address and the port
   to 8080. Then, tap `OK => Don't Use Authentication`.
4. Save the settings and go back to the Home Menu. Check your mitmproxy logs at [127.0.0.1:8081](http://127.0.0.1:8081)
   to verify that the console is sending HTTP requests through your proxy.
   - If you open the Friends List now, you will get a message that "This device's access to online services has been
     restricted by Nintendo." **Your 3DS is not banned. This is expected.** The console is trying to log into your local
     Pretendo server using a NEX account (from the official Pretendo server) that doesn't exist in your local server's
     database. This causes that misleading error message.
5. Start ftpd on your console and run `./scripts/upload-3ds-files.sh` to upload the required files to your console.
6. **This is the potentially dangerous part that modifies your system save data.** As the official Pretendo docs
   explain, Nimbus works by setting up a second Friends account using a test environment instead of prod. On the first
   run, it creates this account, and on subsequent runs, it switches to the already-existing test account.
   Unfortunately, Nimbus cannot create a third test account, but what you _can_ do is back up the save data for the
   Friends and account system modules and then reset the test account.

   :::note[Credits]

   [Trace](https://github.com/TraceEntertains) (`@traceentertains` on Discord) created a modified version of Nimbus that
   resets the Friends test environment (originally released on the Pretendo Network Discord server as
   `manual_override.3dsx`). _All credit for the Friends test account reset program goes to Trace._

   :::

   1. Reboot into GodMode9 and open the scripts menu.
   2. Run the `FriendsAccountSwitcher` script and select "Create a new save slot". Name the slot something descriptive
      like `pretendo_official`.
   3. Reboot into the Home Menu and open the Homebrew Launcher. From there, run the `ResetFriendsTestAccount.3dsx` app
      and press A after a white line appears at the top of the screen.
   4. Open the Friend List applet. You should be "online" and have a new friend code that is different from your friend
      code on the official servers. If you don't go online, you have not successfully connected to your self-hosted
      server. Check your mitmproxy logs at [127.0.0.1:8081](http://127.0.0.1:8081).
   5. Reboot into GodMode9, run the `FriendsAccountSwitcher` script again, and select "Create a new save slot". Name the
      slot something descriptive like `local_server`.
   6. You now have multiple test Friends accounts saved on your SD card at `SD:/gm9/out/friends_accounts/`. You can
      switch between them by running the `FriendsAccountSwitcher` script, selecting "Load a save slot", and following
      the instructions.

7. Open System Settings using your `local_server` Friends test account and create a new PNID or sign in to one you
   created on your Wii U or website.

:::info[How does this work?]

The
[Friends Account Switcher](https://github.com/MatthewL246/pretendo-docker/blob/main/console-files/FriendsAccountSwitcher.gm9)
script simply implements "save slots" for the Friends and account system modules, similarly to what Checkpoint does for
games.

Each of your Friends saves contains both your prod (Nintendo) and test (Pretendo) account data, as well as a config that
determines which account is currently active. So, your `pretendo_official` slot contains your Nintendo prod friends
account, your official Pretendo test account, and a config that makes the test account active. Your `local_server` slot
contains the same prod account but a different test account, and with the config making the test account active. (The
account sysmodule save data works in a similar way.)

Note that if you save a slot while Nimbus is set to Nintendo, your save slot's config will be set to making the prod
account active. You can switch it back to Pretendo by using Nimbus again. It is recommended to use the
`pretendo_official` slot when using your NNID to keep things consistent with your NNID save data, but either will work.

:::

## Changing which server you are connected to

|                                 | Nimbus setting   | Juxt certificate                                       | Proxy settings                             | Friends account switcher |
| ------------------------------- | ---------------- | ------------------------------------------------------ | ------------------------------------------ | ------------------------ |
| **Self-hosted Pretendo server** | Pretendo Network | Custom (run `./scripts/upload-3ds-files.sh`)           | Enabled, set to the server IP, port `8080` | `local_server`           |
| **Official Pretendo server**    | Pretendo Network | Official (run `./scripts/upload-3ds-files.sh --reset`) | Disabled                                   | `pretendo_official`      |
| **Nintendo server**             | Nintendo Network | N/A                                                    | Disabled                                   | `pretendo_official`      |
