---
sidebar_position: 4
---

# Uninstalling

Please be aware that uninstalling Pretendo Docker requires a some manual steps to be taken on the console.

1. ⚠️ **_EXTREMELY IMPORTANT:_ If you use a Wii U, delete your selfhosted PNID from your console _or_ back up your
   MongoDB database now!** See the [safety section above](#safety) for more information. **If you don't do this, you
   will be stuck with a useless account on your console that you can't delete!**
2. Revert the steps you did when connecting.
   - Disable the custom proxy settings on your console.
   - On Wii U, replace your custom Inkay patcher with the original Inkay by re-downloading it from GitHub.
   - On 3DS, replace your custom Juxt certificate with the original one by re-downloading Nimbus from GitHub.
   - On 3DS, switch to your official Pretendo Friends account by running the `FriendsAccountSwitcher` script in GodMode9
     and loading the `pretendo_official` slot you made.
     - You may now delete the `sd:/gm9/out/friends_accounts` directory from your SD card, as well as
       `sd:/3ds/ResetFriendsTestAccount.3dsx` and `sd:/gm9/scripts/FriendsAccountSwitcher.gm9` if you will no longer be
       using multiple Friends accounts.
   - Make sure your console still works when connecting to the official Pretendo Network servers.
3. Run `docker compose down` to stop the containers.
4. Delete this repository.
5. Run `docker system prune -a` to delete the Docker images and build cache.
6. _Optional:_ delete the `pretendo-network-*` Docker volumes and run `docker volume prune`. Again, **double check that
   you deleted your selfhosted PNID from your console now** or made a backup of your MongoDB database if you intend to
   start selfhosting a Pretendo server again later.
