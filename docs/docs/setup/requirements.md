---
sidebar_position: 1
---

# System requirements

## Hardware

- A decent CPU (at least 4 cores recommended, must be capable of
  [running MongoDB](https://www.mongodb.com/docs/ops-manager/current/tutorial/provisioning-prep/))
- At least 10 GB of free storage for Docker image, build cache, and server data (using an SSD is strongly recommended,
  as it will also be used for database storage)
- At least 4GB of free RAM while building the Docker containers; the servers themselves uses about 1GB of RAM while
  running
- Network connectivity to the client console

## Operating system

| OS                                | Testing status |
| --------------------------------- | -------------- |
| Windows (Docker Desktop on WSL 2) | ✅ Working     |
| Linux (Docker Engine)             | ✅ Working     |
| macOS (Docker Desktop)            | ❓ Untested\*  |

_\*macOS is untested because I don't own a Mac. In theory, it should work._

## Software

- [Git](https://git-scm.com/downloads/)
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

Everything else runs inside Docker containers.
