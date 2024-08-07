// This should be evaled in the account container
const { connect } = require("./dist/database");
const { PNID } = require("./dist/models/pnid");

async function runAsync() {
    if (process.argv.length < 2) {
        console.log("Usage: <PNID username>");
        process.exit(1);
    }

    await connect();

    const pnid = await PNID.findOne({
        usernameLower: process.argv[1].toLowerCase(),
    });
    if (pnid) {
        await updatePnidAccessLevel(pnid, 3, "dev");
    } else {
        throw new Error(`No PNID found for username ${process.argv[1]}.`);
    }
}

runAsync().then(() => {
    process.exit(0);
});

async function updatePnidAccessLevel(pnid, access_level, server_access_level) {
    pnid.access_level = access_level;
    pnid.server_access_level = server_access_level;

    console.log(`Saving dev PNID: ${pnid.username} (${pnid.pid})`);

    await pnid.save();
}
