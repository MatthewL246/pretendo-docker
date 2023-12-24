// This should be evaled in the account container
const mongoose = require("mongoose");
const { connect } = require("./dist/database");
const { Server } = require("./dist/models/server");

async function runAsync() {
    await connect();
    await resetServers();

    await createNexServer(
        "Friend List",
        "0003200",
        ["0005001010001C00"],
        process.env.SERVER_IP,
        process.env.FRIENDS_PORT,
        "dev",
        1,
        process.env.FRIENDS_AES_KEY
    );
    await createServiceServer(
        "Miiverse",
        "87cd32617f1985439ea608c2746e4610",
        ["000500301001610A"],
        "dev",
        1,
        process.env.MIIVERSE_AES_KEY
    );
    await createNexServer(
        "Wii U Chat",
        "1005A000",
        ["000500101005A100"],
        process.env.SERVER_IP,
        process.env.WIIU_CHAT_PORT,
        "dev",
        1,
        // Wii U Chat server doesn't seem to care about the AES key
        "0".repeat(64)
    );

    await mongoose.connection.close();
}

runAsync().then(() => {
    console.log("Done creating servers.");
    process.exit(0);
});

async function resetServers() {
    console.log("Deleting all servers...");
    await Server.deleteMany({});
    console.log("Servers collection reset.");
}

async function createNexServer(
    service_name,
    game_server_id,
    title_ids,
    ip,
    port,
    access_mode,
    device,
    aes_key
) {
    for (const arg of arguments) {
        if (!arg && arg !== 0 && arg !== false) {
            throw new Error(
                `Missing argument in new NEX server:\n${JSON.stringify(
                    arguments,
                    null,
                    2
                )}`
            );
        }
    }

    const newServer = new Server({
        service_name: service_name,
        service_type: "nex",
        game_server_id: game_server_id,
        title_ids: title_ids,
        ip: ip,
        port: port,
        access_mode: access_mode,
        maintenance_mode: false,
        device: device,
        aes_key: aes_key,
    });

    console.log("Saving new nex server:");
    console.log(newServer);

    await newServer.save();
}

async function createServiceServer(
    service_name,
    client_id,
    title_ids,
    access_mode,
    device,
    aes_key
) {
    for (const arg of arguments) {
        if (!arg && arg !== 0 && arg !== false) {
            throw new Error(
                `Missing argument in new service server:\n${JSON.stringify(
                    arguments,
                    null,
                    2
                )}`
            );
        }
    }

    const newServer = new Server({
        service_name: service_name,
        service_type: "service",
        client_id: client_id,
        title_ids: title_ids,
        access_mode: access_mode,
        maintenance_mode: false,
        device: device,
        aes_key: aes_key,
    });

    console.log("Saving new service server:");
    console.log(newServer);

    await newServer.save();
}

/* Notes:
    Finding the right server on Wii U:
        Client ID is for services
        Game server ID is for nex servers
    IP and port are only for nex servers
    Service name and service type seem to be unused, so just for documentation?
    Title ID is used for nex and service 3DS servers, not client or game server IDs
    Access mode separates servers into prod and test, based on to PNID access level
    Maintenance mode is self-explanatory
    Device seems to be 1 for Wii U, 2 for 3DS, and 3 for internal API usage?
        Except this is only used for the Wii U nex and service tokens, the 3DS
        tokens are harcoded to 2 and internal API are hardcoded to 3
    AES key is a 32-byte hex string used for creating tokens
*/
