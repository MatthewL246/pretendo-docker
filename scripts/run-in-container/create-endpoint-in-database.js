// This  should run in the miiverse-api container
const mongoose = require("mongoose");
const { connect } = require("./dist/database");
const { Endpoint } = require("./dist/models/endpoint");

async function runAsync() {
    await connect();
    await resetEndpoints();

    await createEndpoint(
        0,
        "dev",
        "api.olv.pretendo.cc",
        "api.olv.pretendo.cc",
        "portal.olv.pretendo.cc",
        "ctr.olv.pretendo.cc"
    );

    await mongoose.connection.close();
}

runAsync().then(() => {
    console.log("Done creating endpoints.");
    process.exit(0);
});

async function resetEndpoints() {
    console.log("Deleting all endpoints...");
    await Endpoint.deleteMany({});
    console.log("Endpoint collection reset.");
}

async function createEndpoint(
    status,
    server_access_level,
    host,
    api_host,
    portal_host,
    n3ds_host
) {
    const newEndpoint = new Endpoint({
        status: status,
        server_access_level: server_access_level,
        // Unused
        topics: true,
        // Unused
        guest_access: true,
        host: host,
        api_host: api_host,
        portal_host: portal_host,
        n3ds_host: n3ds_host,
    });

    console.log("Saving new endpoint:");
    console.log(newEndpoint);

    await newEndpoint.save();
}
