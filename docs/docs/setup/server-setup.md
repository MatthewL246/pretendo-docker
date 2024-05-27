---
sidebar_position: 2
---

# Server setup

Note that this guide assumes that you are **familiar with using the Linux command line** and have a **basic
understanding of Docker**.

1. Check the [system requirements](./requirements.md) and install any necessary software.
2. Clone this repo with Git. Make sure to recursively checkout submodules:
   `git clone --recurse-submodules https://github.com/MatthewL246/pretendo-docker.git`
   - **Note:** Downloading this repo as a ZIP file from GitHub will **not** work because it uses
     [Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) for the Pretendo Network repos.
   - If you are using Windows, you should clone the repo **inside your WSL distro** for multiple reasons. First, this
     avoids Git messing with line endings and breaking shell scripts as it can do when you clone a repo in Windows (due
     to `autocrlf`). Second, this maximizes performance because Docker runs inside WSL and copying files between WSL and
     Windows is slow.
3. Optionally, dump your console's BOSS keys for the BOSS (SpotPass) server. These keys are required if you want to
   create new SpotPass content. These steps are based on
   [the guide from the boss-crypto repository](https://github.com/PretendoNetwork/boss-crypto/#dumping-crypto-keys).
   - For the Wii U: Download [Full_Key_Dumper](https://github.com/EpicUsername12/Full_Key_Dumper/releases) and run the
     ELF from a Tiramisu (not Aroma) environment. Then, copy the `sd:/boss_keys.bin` file from your SD card to the
     `console-files` directory in this repo.
   - For the 3DS: Download the
     [Citra key dumper GodMode9 script](https://raw.githubusercontent.com/citra-emu/citra/master/dist/dumpkeys/DumpKeys.gm9)
     and run it in GodMode9. Then, copy the `sd:/gm9/aes_keys.txt` file from your SD card to the `console-files`
     directory in this repo.
   - Finally, run `./scripts/get-boss-keys.sh` to validate the dumped keys. It will show you if the keys are missing or
     incorrect.
4. Run the initial setup script (`./setup.sh`) from your WSL distro and follow its instructions.
   - **Note:** This will take some time to build the required Docker images, and it will use up to 8GB of bandwidth to
     download images.
   - After initial setup, use `docker compose up -d` to start the containers.
5. Open [127.0.0.1:8081](http://127.0.0.1:8081) in your browser to view the mitmproxy web interface. This is where you
   can view a live list of HTTP requests from client devices.

Next, choose where you want to connect from.
