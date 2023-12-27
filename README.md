# Unofficial Pretendo Network server in Docker

This is an unofficial Docker Compose setup for self-hosting a Pretendo Network
server (because there is no official self-hosting setup).

## System requirements

### Hardware

- A decent CPU (at least 4 cores recommended, must be capable of
  [running MongoDB](https://www.mongodb.com/docs/ops-manager/current/tutorial/provisioning-prep/))
- At least 10 GB of free storage for Docker images and build cache (using an SSD
  is strongly recommended, as it will also be used for database storage)
- At least 4GB of free RAM while building the Docker containers; the servers
  themselves uses about 1GB of RAM while running
- Network connectivity to the client console

### Operating system

| OS                                | Testing status |
| --------------------------------- | -------------- |
| Windows (Docker Desktop on WSL 2) | ✅ Working     |
| Linux (Docker Engine)             | ✅ Working     |
| macOS (Docker Desktop)            | ❓ Untested    |

### Software

- [Git](https://git-scm.com/downloads/)
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

Everything else runs inside Docker containers.

### Supported consoles

| Console       | Testing status               |
| ------------- | ---------------------------- |
| Wii U         | ✅ Working                   |
| Cemu emulator | ❓ Untested                  |
| 3DS           | ❓ Untested                  |
| Switch        | ❌ Not supported by Pretendo |

## Usage

Note that this guide assumes that you are familiar with using the Linux command
line and have a basic understanding of Docker.

### Server setup

1. Check the [system requirements](#software) and install any necessary
   software.
2. Clone this repo with Git. Make sure to recursively checkout submodules:
   `git clone --recurse-submodules https://github.com/MatthewL246/pretendo-docker.git`
   - **Note:** Downloading this repo as a ZIP file from GitHub will **not** work
     because it uses
     [Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) for
     the Pretendo Network repos.
   - If you are using Windows, you should clone the repo **inside your WSL
     distro** for maximum performance.
3. Run the initial setup script (`./setup.sh`) and follow its instructions.
   - **Note:** This will take some time to build the required Docker images, and
     it will use up to 8GB of bandwidth to download images.
   - You might need to run it with `sudo` if you are using the Docker Engine on
     Linux.
   - After initial setup, use `docker compose up -d` to start the containers.
   - You might need to re-run the setup script if this repo is updated with more
     servers.
4. Open <http://127.0.0.1:8081> in your browser to view a live list of HTTP
   requests from client devices.
5. Connect your console to your Pretendo Network server and create a PNID (see
   [Connecting](#connecting)).

### After creating a PNID

1. Run `./scripts/make-pnid-dev.sh` to give your new PNID administrator
   permissions and full access to your server.
2. If you want to use Juxtaposition (Miiverse), run
   `./scripts/create-juxt-community.sh` to create a community (required for
   posting).
3. Read through the [containers section](#containers) to learn more about
   adminstering the servers. Also check out the [scripts directory](./scripts/).

## Safety

- **Back up your MongoDB database!** If you lose it, you will lose all of your
  PNIDs and Juxt posts. You will also be **stuck with a useless account on your
  console that you can't delete** because deleting an account requires a server
  to authenticate the password. Creating a new account on your server with the
  same PNID won't work because each PNID has a numerical ID that is appended to
  the end of the password before hashing, so your console will not authenticate
  with the new PNID. Use `mongodump`
  ([docs](https://www.mongodb.com/docs/manual/tutorial/backup-and-restore-tools/)).
- **Don't delete the `pretendo-network-*` Docker volumes**. You will permanently
  lose your database (see above) and all of your Pretendo server data.
- **Don't use the same P/NNID username on multiple servers.** This applies to
  NNIDs and PNIDs on the official Pretendo Network server.
- **Always verify that you are actually connecting to your own server.** The
  easiest way is to check the mitmproxy logs to see if you are getting the
  expected HTTP requests.

## Connecting

### Web

1. Start a web browser using `127.0.0.1:8080` as a proxy server. For example,
   use `chrome.exe --proxy-server="127.0.0.1:8080"` or the Firefox network
   settings page.
   - I don't recommend using the same browser as the one you use for normal web
     browsing because you will get a lot of irrelevant noise in the mitmproxy
     logs. Consider downloading
     [Chrome Beta](https://www.google.com/chrome/beta/) or
     [Firefox Beta](https://www.mozilla.org/en-US/firefox/channel/desktop/) to
     have an isolated browser for this.
   - If you don't want to deal with the security warnings on every page from
     being MITMed, go to <http://mitm.it> in your proxied browser and follow the
     instructions there to trust the mitmproxy certificate. This is secure
     because mitmproxy generates a random certificate on first run, so nobody
     else could MITM your traffic except you.
2. Open <https://pretendo.network/account> in your proxied browser. **Make sure
   that there is a big red banner stating "This is an unofficial Pretendo
   Network server!"** If there is not, your proxy settings did not apply
   correctly. Also, check <http://127.0.0.1:8081> to make sure your HTTP
   requests are being sent to mitmproxy. Then, once you have verified this, sign
   up for an account there, just as you would on the official Pretendo Network
   servers (by the way, you don't need to do the captcha, it's disabled).
3. You can visit <https://juxt.pretendo.network> in your proxied browser to view
   Juxt posts.
4. Go back to [after creating a PNID](#after-creating-a-pnid).

### Wii U

1. Follow the
   [official Pretendo Network installation guide](https://pretendo.network/docs/install/wiiu)
   to install the patches. At this point, you should be connected to the
   official Pretendo Network servers. **Don't create a new PNID yet.**
2. Open System Settings => Internet => Connect to the Internet => Connections =>
   (Your current internet connection) => Change Settings.
3. Go to DNS => Don't Auto-obtain => (Set both the primary and secondary DNS to
   your server's IP address) => Confirm.
4. Go to Proxy Settings => Set => OK => (Set the proxy server to your server's
   IP address and the port to 8080) => Confirm => Don't Use Authentication.
5. Save the settings and go back to the Home Menu. Check your mitmproxy logs at
   <http://127.0.0.1:8081> to verify that the console is sending HTTP requests
   through your proxy.
6. Start a FTPiiU server on your console and run
   `./scripts/compile-custom-inkay.sh` to compile a custom version of the Inkay
   patches that uses your own mitmproxy certificate.
   - If you didn't set a Wii U IP address when running the setup script, you
     will need to use a FTP client to manually upload
     `repos/Inkay/Inkay-pretendo.wps` to your console at
     `/fs/vol/external01/wiiu/environments/aroma/plugins/`, replacing the
     original Inkay patcher there. You could also re-run
     `./scripts/setup-environment.sh` with a Wii U IP address.
7. Finally, create a new PNID on your console from the users page.
   - Make sure that the license agreement has the custom text "Welcome to your
     selfhosted Pretendo Network server!". If it talks about the "Pretendo
     public beta", you are still connected to the official Pretendo Network
     server and your proxy settings did not apply correctly.
8. Go back to [after creating a PNID](#after-creating-a-pnid).

### 3DS

- Currently untested

## Uninstalling

1. ⚠️ **_EXTREMELY IMPORTANT:_ Delete your selfhosted PNID from your console
   _or_ back up your MongoDB database now!** See the
   [safety section above](#safety) for more information. **If you don't do this,
   you will be stuck with a useless account on your console that you can't
   delete!**
2. Revert [the steps you did when connecting](#connecting).
   - Disable the custom DNS and proxy settings on your console.
   - Replace `Inkay-pretendo.wps` with the original Inkay patcher.
   - Make sure your console still works when connecting to the official Pretendo
     Network servers.
3. Run `docker compose down` to stop the containers.
4. Delete this repository.
5. Run `docker system prune -a` to delete the Docker images and build cache.
6. _Optional:_ delete the `pretendo-network-*` Docker volumes and run
   `docker volume prune`. Again, **double check that you deleted your selfhosted
   PNID from your console now** or made a backup of your MongoDB database that
   you will restore when you start selfhosting a Pretendo server again.

## Containers

### Infrastructure

| Server                                                          | Purpose                                                                                                                                                                        | Usage and administration                                                                                                                                                                                                                                                                                                                                                                                          |
| --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [CoreDNS](https://coredns.io/)                                  | DNS server for both internal container networking and external DNS resolution. It spoofs the Pretendo domains to the address of your local server.                             | No administration necessary.                                                                                                                                                                                                                                                                                                                                                                                      |
| [nginx](https://nginx.org/en/)                                  | Reverse proxy and Web server. It sends HTTP requests to the right Pretendo server based on their hostname.                                                                     | No administration necessary.                                                                                                                                                                                                                                                                                                                                                                                      |
| [MongoDB](https://www.mongodb.com/)                             | Primary database that the Pretendo account and Juxtaposition servers use to store PNIDs and Juxtaposition content.                                                             | Use Mongo Express (see below) to view the databases and perform simple edits. You can also use the `mongosh` command inside the container for more advanced administration tasks or download the [MongoDB Compass GUI](https://www.mongodb.com/products/tools/compass) for easier database editing. (Connect to `mongodb://127.0.0.1:27017/?directConnection=true`. Make sure to enable "Use direct connection".) |
| [Mongo Express](https://github.com/mongo-express/mongo-express) | Simple web GUI for MongoDB administration.                                                                                                                                     | Open <http://127.0.0.1:8082> in your browser with the container running.                                                                                                                                                                                                                                                                                                                                          |
| [MinIO](https://min.io/)                                        | Object store compatable with the AWS S3 API. It is used as file storage and a CDN for the Pretendo servers. Mii images, Juxtaposition screenshots, and more are uploaded here. | Open <http://127.0.0.1:8083> in your browser with the container running.                                                                                                                                                                                                                                                                                                                                          |
| [Redis](https://redis.io/)                                      | Cache database used by the account server.                                                                                                                                     | No administration necessary.                                                                                                                                                                                                                                                                                                                                                                                      |
| [MailDev](https://maildev.github.io/maildev/)                   | SMTP server used to test sending emails from the account server. Use this to view your PNID email verification code.                                                           | Open <http://127.0.0.1:8084> in your browser with the container running.                                                                                                                                                                                                                                                                                                                                          |
| [PostgreSQL](https://www.postgresql.org/)                       | Database used by the Friend List server to store friendships.                                                                                                                  | Use Adminer (see below) to view the databases and run SQL scripts. You can also download the [pgAdmin GUI](https://www.pgadmin.org/) and connect to `127.0.0.1:5432` to perform advanced administration tasks.                                                                                                                                                                                                    |
| [Adminer](https://www.adminer.org/)                             | Web GUI for database administration, used for Postgres.                                                                                                                        | Open <http://127.0.0.1:8085> in your browser with the container running.                                                                                                                                                                                                                                                                                                                                          |

Check the `secrets.txt` file in the root of the repository to find the usernames
and randomly-generated passwords needed to authenticate with the servers.

### Pretendo Network

| Server                                                                                                                                                       | Purpose                                                                                                                                                                            |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [mitmproxy-pretendo](https://github.com/MatthewL246/mitmproxy-pretendo)                                                                                      | Intercepts HTTP requests from client devices and redirects them to the official Pretendo server to your local server. Uses [mitmproxy](https://mitmproxy.org) running on port 8080 |
| [account](https://github.com/PretendoNetwork/account)                                                                                                        | The most important Pretendo server. It handles PNIDs, authentication, and tokens.                                                                                                  |
| [website](https://github.com/PretendoNetwork/website)                                                                                                        | Runs a local copy of the [Pretendo Network website](https://pretendo.network). Used for creating PNIDs without a console.                                                          |
| [friends](https://github.com/PretendoNetwork/friends)                                                                                                        | Handles the Friend List applet and friendships. Juxt and other game servers use it to get friends.                                                                                 |
| [miiverse-api](https://github.com/PretendoNetwork/miiverse-api)                                                                                              | Handles Miiverse API requests from games and Miiverse portal discovery.                                                                                                            |
| [juxtaposition-ui](https://github.com/PretendoNetwork/juxtaposition-ui)                                                                                      | The Miiverse applet GUI, as well as the Juxt web interface.                                                                                                                        |
| Wii U Chat ([authentication](https://github.com/PretendoNetwork/wiiu-chat-authentication) and [secure](https://github.com/PretendoNetwork/wiiu-chat-secure)) | Server for the Wii U Chat app.                                                                                                                                                     |

#### Planned servers

These are some other servers (mostly for individual games) that I want to set up
here.

- [BOSS (SpotPass)](https://github.com/PretendoNetwork/BOSS)
- [Mario Kart 7](https://github.com/PretendoNetwork/mario-kart-7)
- Mario Kart 8
  ([authentication](https://github.com/PretendoNetwork/mario-kart-8-authentication)
  and [secure](https://github.com/PretendoNetwork/mario-kart-8-secure))
- [Super Mario Maker](https://github.com/PretendoNetwork/super-mario-maker)
- [Pokkén Tournament](https://github.com/PretendoNetwork/pokken-tournament)
- A bunch more of the individual game servers.
- [Grove](https://github.com/PretendoNetwork/Grove) (Interesting but not
  particularly useful in its current state.)
- [SOAP (NUS)](https://github.com/PretendoNetwork/SOAP) (It would be cool to run
  a full local eShop server.)

## Learn more

- Each of the main subdirectories in this repository contain a README file that
  explains their contents ([config](./config/), [environment](./environment/),
  [patches](./patches/), [repos](./repos/), and [scripts](./scripts/)).
- Check the [compose.yml](./compose.yml) file for more information on how the
  server containers are run.
- Read the source code in the
  [Pretendo Network GitHub repositories](https://github.com/orgs/PretendoNetwork/repositories).
- Join the [Pretendo Network Discord server](https://invite.gg/pretendo) and ask
  questions.
