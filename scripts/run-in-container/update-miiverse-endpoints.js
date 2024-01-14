// This should be evaled in the miiverse-api container
const mongoose = require("mongoose");
const { connect } = require("./dist/database");
const { Endpoint } = require("./dist/models/endpoint");

async function runAsync() {
    await connect();
    await resetEndpoints();

    // These are static and always use the same domains
    await createEndpoint(
        0,
        "api.olv.pretendo.cc",
        "api.olv.pretendo.cc",
        "portal.olv.pretendo.cc",
        "ctr.olv.pretendo.cc"
    );

    await mongoose.connection.close();
}

runAsync().then(() => {
    process.exit(0);
});

async function resetEndpoints() {
    console.log("Deleting all endpoints...");
    await Endpoint.deleteMany({});
}

async function createEndpoint(status, host, api_host, portal_host, n3ds_host) {
    for (const access_level of ["prod", "test", "dev"]) {
        const newEndpoint = new Endpoint({
            status: status,
            server_access_level: access_level,
            topics: true, // Unused
            guest_access: true, // Unused
            host: host,
            api_host: api_host,
            portal_host: portal_host,
            n3ds_host: n3ds_host,
        });

        console.log(`Saving new endpoint: ${newEndpoint.server_access_level}`);

        await newEndpoint.save();
    }
}
