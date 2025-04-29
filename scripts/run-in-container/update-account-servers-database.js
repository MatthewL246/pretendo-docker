// This should be evaled in the account container
const { connect } = require("./dist/database");
const { Server } = require("./dist/models/server");

async function runAsync() {
    await connect();
    await resetServers();

    // Wii U: https://wiiubrew.org/wiki/Title_database and https://yls8.mtheall.com/ninupdates/titlelist.php?sys=wup
    // 3DS: https://www.3dbrew.org/wiki/Title_list and https://yls8.mtheall.com/ninupdates/titlelist.php?sys=ktr
    await createServiceServer(
        "PNID Settings",
        "3f3928cc6f780638d360f0485cef973f",
        [
            // Wii U Account Settings
            "000500101004B000",
            "000500101004B100",
            "000500101004B200",
        ],
        1,
        "0".repeat(64)
    );
    await createNexServer(
        "Friend List",
        "00003200",
        [
            // Not in the title database but seems to be what the Wii U sends
            "0005001010001C00",

            // Wii U Friend List
            "000500301001500A",
            "000500301001510A",
            "000500301001520A",

            // 3DS friends system-module
            "0004013000003202",

            // 3DS Friend List applet
            "0004003000008D02",
            "0004003000009602",
            "0004003000009F02",
            "000400300000AF02",
        ],
        process.env.SERVER_IP,
        process.env.FRIENDS_PORT,
        1,
        process.env.FRIENDS_AES_KEY
    );
    await createServiceServer(
        "Miiverse",
        "87cd32617f1985439ea608c2746e4610",
        [
            // Wii U Miiverse
            "000500301001600A",
            "000500301001610A",
            "000500301001620A",

            // 3DS Miiverse applet
            "000400300000BC02",
            "000400300000BD02",
            "000400300000BE02",
        ],
        1,
        process.env.MIIVERSE_AES_KEY
    );
    await createNexServer(
        "Wii U Chat",
        "1005A000",
        ["000500101005A000", "000500101005A100", "000500101005A200"],
        process.env.SERVER_IP,
        process.env.WIIU_CHAT_PORT,
        1,
        // Wii U Chat server doesn't seem to care about the AES key
        "0".repeat(64)
    );
    await createNexServer(
        "Super Mario Maker",
        "1018DB00",
        ["000500001018DB00", "000500001018DC00", "000500001018DD00"],
        process.env.SERVER_IP,
        process.env.SMM_PORT,
        1,
        "0".repeat(64)
    );
    await createNexServer(
        "Splatoon",
        "10162B00",
        ["0005000010176A00", "0005000010176900", "0005000010162B00"],
        process.env.SERVER_IP,
        process.env.SPLATOON_PORT,
        1,
        "0".repeat(64)
    );
    await createNexServer(
        "Minecraft",
        "101D9D00",
        ["0005000E101D9D00", "0005000E101DBE00", "00050000101D7500"],
        process.env.SERVER_IP,
        process.env.MINECRAFT_PORT,
        1,
        "0".repeat(64)
    );
    await createNexServer(
        "Pikmin 3",
        "1012BC00",
        ["000500001012BC00", "000500001012BD00", "000500001012BE00"],
        process.env.SERVER_IP,
        process.env.PIKMIN3_PORT,
        1,
        "0".repeat(64)
    );
    await createNexServer(
        "Mario Kart 8",
        "1010EB00",
        ["000500001010EB00", "000500001010EC00", "000500001010ED00"],
        process.env.SERVER_IP,
        process.env.MK8_PORT,
        1,
        "0".repeat(64)
    );
}

runAsync().then(() => {
    process.exit(0);
});

async function resetServers() {
    console.log("Deleting all servers...");
    await Server.deleteMany({});
}

async function createNexServer(service_name, game_server_id, title_ids, ip, port, device, aes_key) {
    for (const arg of arguments) {
        if (!arg && arg !== 0 && arg !== false) {
            throw new Error(`Missing argument in new NEX server:\n${JSON.stringify(arguments, null, 2)}`);
        }
    }

    for (const access_level of ["prod", "test", "dev"]) {
        const newServer = new Server({
            service_name: service_name,
            service_type: "nex",
            game_server_id: game_server_id,
            title_ids: title_ids,
            ip: ip,
            port: port,
            access_mode: access_level,
            maintenance_mode: false,
            device: device,
            aes_key: aes_key,
        });

        console.log(`Saving new nex server: ${newServer.service_name}:${newServer.access_mode}`);

        await newServer.save();
    }
}

async function createServiceServer(service_name, client_id, title_ids, device, aes_key) {
    for (const arg of arguments) {
        if (!arg && arg !== 0 && arg !== false) {
            throw new Error(`Missing argument in new service server:\n${JSON.stringify(arguments, null, 2)}`);
        }
    }

    for (const access_level of ["prod", "test", "dev"]) {
        const newServer = new Server({
            service_name: service_name,
            service_type: "service",
            client_id: client_id,
            title_ids: title_ids,
            access_mode: access_level,
            maintenance_mode: false,
            device: device,
            aes_key: aes_key,
        });

        console.log(`Saving new service server: ${newServer.service_name}:${newServer.access_mode}`);

        await newServer.save();
    }
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
