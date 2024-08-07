---
sidebar_position: 1
---

# System requirements

Before you start setting up the Pretendo Network server, make sure your system meets the following requirements.

## Hardware

- A decent CPU
  - Must be using the x64 or ARM64 architecture
    - If you're using an ARM SBC like a Raspberry Pi, make sure you install a 64-bit operating system
  - At least 4 cores are recommended
- At least 4GB of free RAM while building the Docker containers
  - The servers themselves uses about 1GB of RAM while running
- At least 10 GB of free storage for Docker images, build cache, and server data
  - Using an SSD is strongly recommended, as it will be used for databases
- Network connectivity to the client console

## Operating system

| OS                                | Testing status |
| --------------------------------- | -------------- |
| Windows (Docker Desktop on WSL 2) | ✅ Working     |
| Linux (Docker Engine)             | ✅ Working     |
| macOS (Docker Desktop)            | ✅ Working\*   |

_\*Please note that this project is not regularly tested on macOS, but users have reported that it works. If you
encounter any issues, please report them!_

## Software

### Required

- [Git](https://git-scm.com/downloads/)
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Recommended

- [The tnftp FTP client](https://en.wikipedia.org/wiki/Tnftp), which is used for automatically uploading files to the
  client consoles. This is most likely a package in your distro's package manager repo.

Everything else runs inside Docker containers, so it does not need to be installed.
