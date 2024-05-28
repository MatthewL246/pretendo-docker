---
sidebar_position: 2
pagination_prev: setup/connecting/index
pagination_next: setup/next-steps
---

# Wii U

1. Follow the [official Pretendo Network installation guide](https://pretendo.network/docs/install/wiiu) to install the
   patches. At this point, you should be connected to the official Pretendo Network servers. **You may create a new PNID
   on the official servers now if you wish.** If you do so, come back to this guide when you are done.
2. Open System Settings => Internet => Connect to the Internet => Connections => (Your current internet connection) =>
   Change Settings.
3. Go to Proxy Settings => Set => OK => (Set the proxy server to your server's IP address and the port to 8080) =>
   Confirm => Don't Use Authentication.
4. Save the settings and go back to the Home Menu. Check your mitmproxy logs at [127.0.0.1:8081](http://127.0.0.1:8081)
   to verify that the console is sending HTTP requests through your proxy.
5. Start a FTPiiU server on your console and run `./scripts/compile-custom-inkay.sh` to compile a custom version of the
   Inkay patches that uses your own mitmproxy certificate.
   - If you didn't set a Wii U IP address when running the setup script, you will need to use a FTP client to manually
     upload `repos/Inkay/Inkay-pretendo.wps` to your console at `/fs/vol/external01/wiiu/environments/aroma/plugins/`,
     replacing the original Inkay patcher there. You could also re-run `./scripts/setup-environment.sh` with a Wii U IP
     address.
6. Finally, create a new PNID on your console from the users page.
   - Make sure that the license agreement has the custom text "Welcome to your selfhosted Pretendo Network server!". If
     it talks about the "Pretendo public beta", you are still connected to the official Pretendo Network server and your
     proxy settings did not apply correctly.

## Changing which server you are connected to

- To connect to your selfhosted Pretendo server, use a custom Inkay build by running `./scripts/compile-custom-inkay.sh`
  and enable the custom proxy settings on the console.
- To connect to the official Pretendo servers, use an unmodified Inkay build by running
  `./scripts/compile-custom-inkay.sh --reset` and disable the custom proxy settings on the console.
- To connect to Nintendo's servers, disable Inkay and the proxy settings.
