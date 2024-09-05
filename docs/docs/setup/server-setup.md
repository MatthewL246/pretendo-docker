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

Clone this repo with Git, and make sure to recursively checkout submodules.

```shell
git clone --recurse-submodules https://github.com/MatthewL246/pretendo-docker.git
```

:::note

Downloading this repo as a ZIP file from GitHub will **not** work because it uses
[Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) for the Pretendo Network repos.

:::

:::tip[Tips for Windows users]

If you are using Windows, you should clone the repo **inside your primary WSL distro using Bash in WSL**, not Git Bash
from Git for Windows, for multiple reasons.

- This avoids Git messing with line endings and breaking shell scripts, which it can do when you clone a repo in Windows
  (due to `autocrlf`).
- This maximizes performance because Docker runs inside WSL and copying files between the WSL and Windows filesystems is
  slow.

Remember that **all shell commands should be run inside WSL**, not Git Bash in Windows.

:::

## Setting up

Open a terminal window inside the repository's directory. Run the initial setup script and follow its instructions. This
will take some time to build the required Docker images, and it will use up to 8GB of bandwidth to download images.

```shell
./setup.sh
```

After initial setup, use Docker Compose to build and start the server containers.

```shell
docker compose up -d --build
```

:::tip

You can now open [127.0.0.1:8081](http://127.0.0.1:8081) in your browser to view the mitmproxy web interface. This is
where you can view a live list of HTTP requests from client devices, which is incredibly useful for understanding what
requests are hitting your server.

:::
