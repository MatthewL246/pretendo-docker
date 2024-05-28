---
sidebar_position: 4
pagination_prev: setup/connecting/index
pagination_next: setup/next-steps
---

# 3DS

> **Warning:** Due to the 3DS's account system, using a local Pretendo Network server with it requires some potentially
> dangerous modifications to the CTRNAND.
> **[Create a NAND backup](https://3ds.hacks.guide/godmode9-usage#creating-a-nand-backup) before proceeding.**

1. Follow the [official Pretendo Network installation guide](https://pretendo.network/docs/install/3ds) to install the
   patches. At this point, you should be connected to the official Pretendo Network servers. Linking your official PNID
   in System Settings is optional.
2. Open System Settings => Internet Settings => Connection Settings => (Your current connection) => Change Settings.
3. Go to Proxy Settings => Yes => Detailed Setup => (Set the proxy server to your server's IP address and the port
   to 8080) => OK => Don't Use Authentication.
4. Save the settings and go back to the Home Menu. Check your mitmproxy logs at [127.0.0.1:8081](http://127.0.0.1:8081)
   to verify that the console is sending HTTP requests through your proxy.
   - If you open the Friends List now, you might get a message that "This device's access to online services has been
     restricted by Nintendo." **Your 3DS is not banned. This is expected.** The console is trying to log into your local
     Pretendo server using a NEX account that doesn't exist in the server's database because it already created that NEX
     account on the official servers.
5. Start ftpd on your console and run `./scripts/upload-3ds-files.sh` to upload the required files to your console.
6. **This is the potentially dangerous part that modifies your CTRNAND.** As the official Pretendo docs explain, Nimbus
   works by setting up a second Friends account using a test environment instead of prod. On the first run, it creates
   this account, and on subsequent runs, it switches to the already-existing test account. Unfortunately, you cannot
   create a third test account, but what you _can_ do is back up the save data for the Friends and account system
   modules and then reset the test account. [Trace](https://github.com/TraceEntertains) (`traceentertains` on Discord)
   created a modified version of Nimbus that resets the Friends test environment, and I created a GodMode9 script to
   automate save backups and switching save slots for the system modules.

   > **All credit for the Friends test account reset program** (originally released on the Pretendo Network Discord
   > server as `manual_override.3dsx`) **goes to Trace.**

   1. Reboot into GodMode9 and open the scripts menu.
   2. Run the `FriendsAccountSwitcher` script and select "Create a new save slot". Name the slot something descriptive
      like `pretendo_official`.
   3. Reboot into the Home Menu and open the Homebrew Launcher. From there, run the `ResetFriendsTestAccount.3dsx` app
      and press A when a white line appears at the top of the screen (the Nimbus GUI was removed).
   4. Open the Friend List applet. You should be "online" and have a new friend code that is different from your friend
      code on the official servers. If you don't go online, you have not successfully connected to your selfhosted
      server.
   5. Reboot into GodMode9, run the `FriendsAccountSwitcher` script again, and select "Create a new save slot". Name the
      slot something descriptive like `local_server`.
   6. You now have multiple test Friends accounts saved on your SD card at `sd:/gm9/out/friends_accounts/`. You can
      switch between them by running the `FriendsAccountSwitcher` script, selecting "Load a save slot", and following
      the instructions.
      - Pay careful attention to the script's instructions. When loading a save slot, it will first save the current
        Friends and account system modules save data to the last-used save slot. Create a new slot if you don't want to
        overwrite your existing save data.
      - **How does this work?** Each of your Friends saves contains both your prod (Nintendo) and test (Pretendo)
        account data, as well as a config that determines which account is currently active. So, your
        `pretendo_official` slot contains your Nintendo prod friends account, your Pretendo official test account, and a
        config that makes the test account active. Your `local_server` slot contains the same prod account but a
        different test account, and with the config making the test account active. (The account sysmodule save data
        seems to work in a similar way.)
      - If you save a slot with Nimbus set to Nintendo, your save slot's config will be set to making the prod account
        active. You can switch it back to Pretendo by using Nimbus again.

7. Open System Settings using your `local_server` Friends test account and create a new PNID or sign in to one you
   created on your Wii U or website.

## Changing which server you are connected to (3DS)

- To connect to your selfhosted Pretendo server:
  - Use Nimbus to switch to Pretendo Network.
  - Use the custom mitmproxy certificate for Juxt by running `./scripts/upload-3ds-files.sh`.
  - Enable the custom proxy settings on the console.
  - Switch to your local server Friends account by running the `FriendsAccountSwitcher` script in GodMode9.
- To connect to the official Pretendo servers:
  - Use Nimbus to switch to Pretendo Network.
  - Use the official certificate for Juxt by running `./scripts/upload-3ds-files.sh --reset`
  - Disable the custom proxy settings on the console.
  - Switch to your official Pretendo Friends account by running the `FriendsAccountSwitcher` script in GodMode9.
- To connect to Nintendo's servers:
  - Use Nimbus to switch to Nintendo Network.
  - Disable the custom proxy settings on the console.
