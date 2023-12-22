// This  should run in the account container
const mongoose = require("mongoose");
const { connect } = require("./dist/database");
const { PNID } = require("./dist/models/pnid");

async function runAsync() {
    await connect();

    if (process.argv[1]) {
        const pnid = await PNID.findOne({
            usernameLower: process.argv[1].toLowerCase(),
        });
        if (pnid) {
            await updatePnidAccessLevel(pnid, 3, "dev");
        } else {
            console.log(`No PNID found for username ${process.argv[1]}.`);
        }
    } else {
        console.log("No username given, skipping update.");
    }

    await mongoose.connection.close();
}

runAsync().then(() => {
    console.log("Done updating PNID access levels.");
    process.exit(0);
});

async function updatePnidAccessLevel(pnid, access_level, server_access_level) {
    pnid.access_level = access_level;
    pnid.server_access_level = server_access_level;

    console.log(`Saving dev PNID: ${pnid.username} (${pnid.pid})`);

    await pnid.save();
}
