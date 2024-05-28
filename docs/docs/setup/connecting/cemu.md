---
sidebar_position: 3
pagination_prev: setup/connecting/index
pagination_next: setup/next-steps
---

# Cemu

1. Follow the [official Pretendo Network guide](https://pretendo.network/docs/install/cemu).
   - If you have a real Wii U console: Use Dumpling to dump the online files for your selfhosted PNID from your Wii U.
     If you are using multiple accounts, make sure to disable the "Merge Account To Default Cemu User" setting.
   - If you don't have a Wii U:
     1. Visit [the account settings page](https://pretendo.network/account) in your proxied browser and click the
        "Download account files" button. **Note:** This button will only show up on your server. This feature was
        purposefully disabled on the Pretendo official servers due to abuse. In your selfhosted server, the checks that
        block invalid OTP and seeprom dumps have been patched out.
     2. Copy `otp.bin`, `seeprom.bin`, and `mlc01` to your Cemu directory.
     3. Continue with the official guide to enable online mode with Pretendo.
     4. You will notice that Cemu is missing certificates needed to use the online mode. You will need to find these
        certificates (and the files for the Friend List) somewhere else.
2. Use Dumpling to dump your system applications. Make sure to at least dump the Friend List applet, but you might as
   well dump them all.
   - Note: You can run the Miiverse applet by manually dumping it from your Wii U with FTPiiU (as it is not currently
     listed in Dumpling). However, this just crashes Cemu because it currently does not support Miiverse features.
3. Open the `settings.xml` file in your Cemu data directory and set the `<proxy_server>` value to
   `http://127.0.0.1:8080`.

## Changing which server you are connected to

- To connect to your selfhosted Pretendo server, switch to your selfhosted PNID in account settings, set the network
  service to Pretendo, and set the proxy server setting.
- To connect to the official Pretendo servers, switch to your official PNID in account settings, set the network service
  to Pretendo, and clear the proxy server setting.
- To connect to Nintendo's servers, switch to your NNID in account settings, set the network service to Nintendo, and
  clear the proxy server setting.
