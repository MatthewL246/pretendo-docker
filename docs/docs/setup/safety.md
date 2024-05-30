---
sidebar_position: 3
---

# Safety

Remember to follow these safety guidelines when using your server.

:::danger[Danger: Back up your server data!]

If you lose your server database, you will lose all of your PNIDs and Juxt posts. You will also need to take manual
steps to remove your self-hosted PNID from your consoles, as they will not be able to authenticate with an account that
does not exist on the server. **Use the included script `./scripts/backup.sh` script to back up all of your Pretendo
server data.**

:::

:::danger[Don't delete the `pretendo-network-*` Docker volumes!]

You will permanently lose your database (see above) and all of your Pretendo server data. If you need to do something
risky, run a backup first. If you want to stop self-hosting Pretendo, use the [uninstalling guide](../uninstalling.md).

:::

:::warning[Don't use the same PNID/NNID username on multiple servers.]

This applies to NNIDs, PNIDs on the official Pretendo Network server, and PNIDs on your self-hosted server. The consoles
will not work right if you attempt to use multiple accounts with the same username.

:::

:::warning[Always verify that you are actually connecting to your own server.]

The easiest way is to check the mitmproxy logs to see if you are getting the expected HTTP requests.

:::
