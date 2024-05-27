---
sidebar_position: 3
---

# Safety

**Back up your data!** If you lose your MongoDB database, you will lose all of your PNIDs and Juxt posts. If you have a
PNID signed in on a Wii U, you will also be **stuck with a useless account on your console that you can't delete**
because deleting an account requires a server to authenticate the password. Creating a new account on your server with
the same PNID won't work because each PNID has a numerical ID that is appended to the end of the password before
hashing, so your console will not authenticate with the new PNID. Use the included `./scripts/backup.sh` script to back
up all of your Pretendo server data.

**Don't delete the `pretendo-network-*` Docker volumes**. You will permanently lose your database (see above) and all of
your Pretendo server data. If you need to do something risky, run a backup first.

**Don't use the same P/NNID username on multiple servers.** This applies to NNIDs and PNIDs on the official Pretendo
Network server.

**Always verify that you are actually connecting to your own server.** The easiest way is to check the mitmproxy logs to
see if you are getting the expected HTTP requests.
