---
sidebar_position: 4
---

# Uninstalling

Please be aware that uninstalling Pretendo Docker requires a some manual steps to be taken on the console.

:::danger

**Take a backup of your server data now!** Run `./scripts/backup.sh before-uninstall` to back up all server data to
`backups/before-uninstall`.

After backing up, **copy the `backups` directory in this repo to somewhere safe so it is not deleted**.

:::

1. Go back to the [connecting guide](./setup/connecting/index.mdx) and follow the steps to connect to either the
   official Pretendo Network server or Nintendo's server.

   - You may now delete anything related to your self-hosted PNID from your consoles and emulators.

     :::warning

     If you do not delete your self-hosted PNID from your Wii U now, while connected to your local server, you will need
     to take manual steps if you decide to delete it later. Deleting a Wii U account normally requires server
     authentication, but this can be bypassed by using the `Unlink the account.dat file` option of the
     [Wii U Account Swap tool](https://github.com/Nightkingale/Wii-U-Account-Swap) and then deleting the account
     normally.

     :::

2. Run `docker compose down` to stop the containers.
3. Delete your copy of the `pretendo-docker` repository.
4. Run `docker system prune -a` to free up some storage by deleting the Pretendo Docker images and build cache.

:::danger

If you have safely stored your server data backup, you may now delete the Docker volumes that start with
`pretendo-network` to free up some more storage.

:::
