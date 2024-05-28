---
sidebar_position: 2
---

# Server setup

This guide will help you download, set up, and run the Pretendo Network server software on your system.

:::info

This guide assumes that you are already **familiar with using the Linux command line** and have a **basic understanding
of Docker**.

:::

## Downloading

Clone this repo with Git. Make sure to recursively checkout submodules.

```shell
git clone --recurse-submodules https://github.com/MatthewL246/pretendo-docker.git
```

:::warning

Downloading this repo as a ZIP file from GitHub will **not** work because it uses
[Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) for the Pretendo Network repos.

:::

:::tip

If you are using Windows, you should clone the repo **inside your WSL distro** for multiple reasons.

- This avoids Git messing with line endings and breaking shell scripts, which it can do when you clone a repo in Windows
  (due to `autocrlf`).
- This maximizes performance because Docker runs inside WSL and copying files between WSL and Windows is slow.

Remember that **all shell commands should be run inside WSL**, not Git Bash in Windows.

:::

## Setting up

:::note[Optional: dumping BOSS keys]

You may dump the BOSS keys from one or both consoles for use by the BOSS (SpotPass) server. These keys are **only
required if you want to create new SpotPass content**.

_These steps are based on the
[guide from the boss-crypto repository](https://github.com/PretendoNetwork/boss-crypto/#dumping-crypto-keys)._

1. **For Wii U:** Download [Full Key Dumper](https://github.com/EpicUsername12/Full_Key_Dumper/releases) and run the ELF
   from the Tiramisu environment (this program does not support Aroma). Then, copy the `SD:/boss_keys.bin` file from
   your SD card to the `console-files` directory in this repo.
2. **For 3DS:** Download the
   [Citra key dumper GodMode9 script](https://raw.githubusercontent.com/PabloMK7/citra/master/dist/dumpkeys/DumpKeys.gm9)
   and run it in GodMode9. Then, copy the `SD:/gm9/aes_keys.txt` file from your SD card to the `console-files` directory
   in this repo.
3. Finally, run `./scripts/get-boss-keys.sh` to validate the dumped keys. It will show you if the keys are missing or
   incorrect.

:::

Open a terminal window inside the repository's directory. Run the initial setup script and follow its instructions.

```shell
./setup.sh
```

:::info

This will take some time to build the required Docker images, and it will use up to 8GB of bandwidth to download images.

:::

After initial setup, use Docker Compose to build and start the server containers.

```shell
docker compose up -d --build
```

:::tip

You can now open [127.0.0.1:8081](http://127.0.0.1:8081) in your browser to view the mitmproxy web interface. This is
where you can view a live list of HTTP requests from client devices, which is incredibly useful for understanding what
requests are hitting your server.

:::
