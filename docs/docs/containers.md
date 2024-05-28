---
sidebar_position: 6
---

# Containers information

## Infrastructure

| Server                                                          | Purpose                                                                                                                                                                        | Usage and administration                                                                                                                                                                                                                                                                                                                                                                                          |
| --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [CoreDNS](https://coredns.io/)                                  | DNS server for both internal container networking and external DNS resolution. It spoofs the Pretendo domains to the address of your local server.                             | No administration necessary.                                                                                                                                                                                                                                                                                                                                                                                      |
| [nginx](https://nginx.org/en/)                                  | Reverse proxy and Web server. It sends HTTP requests to the right Pretendo server based on their hostname.                                                                     | No administration necessary.                                                                                                                                                                                                                                                                                                                                                                                      |
| [MongoDB](https://www.mongodb.com/)                             | Primary database that the Pretendo account and Juxtaposition servers use to store PNIDs and Juxtaposition content.                                                             | Use Mongo Express (see below) to view the databases and perform simple edits. You can also use the `mongosh` command inside the container for more advanced administration tasks or download the [MongoDB Compass GUI](https://www.mongodb.com/products/tools/compass) for easier database editing. (Connect to `mongodb://127.0.0.1:27017/?directConnection=true`. Make sure to enable "Use direct connection".) |
| [Mongo Express](https://github.com/mongo-express/mongo-express) | Simple web GUI for MongoDB administration.                                                                                                                                     | Open [127.0.0.1:8082](http://127.0.0.1:8082) in your browser with the container running.                                                                                                                                                                                                                                                                                                                          |
| [MinIO](https://min.io/)                                        | Object store compatable with the AWS S3 API. It is used as file storage and a CDN for the Pretendo servers. Mii images, Juxtaposition screenshots, and more are uploaded here. | Open [127.0.0.1:8083](http://127.0.0.1:8083) in your browser with the container running.                                                                                                                                                                                                                                                                                                                          |
| [Redis](https://redis.io/)                                      | Cache database used by the account server.                                                                                                                                     | No administration necessary.                                                                                                                                                                                                                                                                                                                                                                                      |
| [MailDev](https://maildev.github.io/maildev/)                   | SMTP server used to test sending emails from the account server. Use this to view your PNID email verification code.                                                           | Open [127.0.0.1:8084](http://127.0.0.1:8084) in your browser with the container running.                                                                                                                                                                                                                                                                                                                          |
| [PostgreSQL](https://www.postgresql.org/)                       | Database used by the Friend List server to store friendships.                                                                                                                  | Use Adminer (see below) to view the databases and run SQL scripts. You can also download the [pgAdmin GUI](https://www.pgadmin.org/) and connect to `127.0.0.1:5432` to perform advanced administration tasks.                                                                                                                                                                                                    |
| [Adminer](https://www.adminer.org/)                             | Web GUI for database administration, used for Postgres.                                                                                                                        | Open [127.0.0.1:8085](http://127.0.0.1:8085) in your browser with the container running.                                                                                                                                                                                                                                                                                                                          |
| [Redis Commander](https://joeferner.github.io/redis-commander/) | Web GUI for Redis database administration.                                                                                                                                     | Open [127.0.0.1:8086](http://127.0.0.1:8086) in your browser with the container running.                                                                                                                                                                                                                                                                                                                          |

Check the `secrets.txt` file in the root of the repository to find the usernames and randomly-generated passwords needed
to authenticate with the servers.

## Pretendo Network

| Server                                                                                                                                                       | Purpose                                                                                                                                                                            |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [mitmproxy-pretendo](https://github.com/MatthewL246/mitmproxy-pretendo)                                                                                      | Intercepts HTTP requests from client devices and redirects them to the official Pretendo server to your local server. Uses [mitmproxy](https://mitmproxy.org) running on port 8080 |
| [account](https://github.com/PretendoNetwork/account)                                                                                                        | The most important Pretendo server. It handles PNIDs, authentication, and tokens.                                                                                                  |
| [website](https://github.com/PretendoNetwork/website)                                                                                                        | Runs a local copy of the [Pretendo Network website](https://pretendo.network). Used for creating PNIDs without a console.                                                          |
| [friends](https://github.com/PretendoNetwork/friends)                                                                                                        | Handles the Friend List applet and friendships. Juxt and other game servers use it to get friends.                                                                                 |
| [miiverse-api](https://github.com/PretendoNetwork/miiverse-api)                                                                                              | Handles Miiverse API requests from games and Miiverse portal discovery.                                                                                                            |
| [juxtaposition-ui](https://github.com/PretendoNetwork/juxtaposition-ui)                                                                                      | The Miiverse applet GUI, as well as the Juxt web interface.                                                                                                                        |
| Wii U Chat ([authentication](https://github.com/PretendoNetwork/wiiu-chat-authentication) and [secure](https://github.com/PretendoNetwork/wiiu-chat-secure)) | Server for the Wii U Chat app. This is currently untested because I only have 1 Wii U (and it does not seem to work on Cemu).                                                      |
| [BOSS](https://github.com/PretendoNetwork/BOSS)                                                                                                              | Server for BOSS (SpotPass) content. I do not yet understand how to create new BOSS content, so it currently just serves some premade content.                                      |
| [Super Mario Maker](https://github.com/PretendoNetwork/super-mario-maker)                                                                                    | Server for Super Mario Maker online features.                                                                                                                                      |