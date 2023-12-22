// This  should run in the juxtaposition-ui container
const mongoose = require("mongoose");
const { COMMUNITY } = require("./src/models/communities");
const fs = require("fs").promises;
const sharp = require("sharp");
const { S3, Endpoint } = require("aws-sdk");

const s3 = new S3({
    endpoint: new Endpoint(process.env.JUXT_CONFIG_AWS_SPACES_ENDPOINT),
    accessKeyId: process.env.JUXT_CONFIG_AWS_SPACES_KEY,
    secretAccessKey: process.env.JUXT_CONFIG_AWS_SPACES_SECRET,
});

async function runAsync() {
    await connect();

    if (process.argv.length !== 4) {
        console.log("<name> <description> <comma-separated title IDs>");
    }

    await createMainCommunity(
        1,
        process.argv[1],
        process.argv[2],
        process.argv[3].split(","),
        "/tmp/icon",
        "/tmp/banner"
    );

    await mongoose.connection.close();
}

runAsync().then(() => {
    console.log("Done creating community.");
    process.exit(0);
});

async function connect() {
    await mongoose.connect(process.env.JUXT_CONFIG_MONGODB_URI, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
    });
    const connection = mongoose.connection;
    connection.on("connected", function () {
        logger.info(`MongoDB connected ${this.name}`);
    });
    connection.on("error", console.error.bind(console, "connection error:"));
    connection.on("close", () => {
        connection.removeAllListeners();
    });
}

async function createMainCommunity(
    platform_id,
    name,
    description,
    title_ids,
    iconPath,
    bannerPath
) {
    const communityId = Math.floor(Math.random() * 1000000) + 1;

    const newCommunity = new COMMUNITY({
        // 0 is Wii U
        platform_id: platform_id,
        name: name,
        description: description,
        // Type 0 is a main community
        type: 0,
        // Used for user-created communities, not main communities
        owner: 0,
        // Title IDs for relating the community to a game
        title_id: title_ids,
        // Should probably be unique
        community_id: communityId,
        // Seems to always be the same as community_id
        olive_community_id: communityId,
    });

    console.log("Saving new community:");
    console.log(newCommunity);

    await newCommunity.save();
    await uploadAssets(communityId, iconPath, bannerPath);
}

async function uploadAssets(community_id, iconPath, bannerPath) {
    console.log("Uploading assets for community " + community_id);
    const sizes = [32, 64, 128];
    const iconBuffer = await fs.readFile(iconPath);
    for (const size of sizes) {
        const resizedIconBuffer = await sharp(iconBuffer)
            .resize(size, size, {
                fit: "cover",
                position: "center",
            })
            .png({ quality: 80 })
            .toBuffer();

        const uploadParams = {
            Bucket: "pn-cdn",
            Key: `icons/${community_id}/${size}.png`,
            Body: resizedIconBuffer,
            ACL: "public-read",
            ContentType: "image/png",
        };
        await s3.putObject(uploadParams).promise();
    }

    const consoles = ["WiiU", "3DS"];
    const bannerBuffer = await fs.readFile(bannerPath);
    for (const console of consoles) {
        const resizedBannerBuffer = await sharp(bannerBuffer)
            .resize(1280, 180, {
                fit: "cover",
                position: "center",
            })
            .png({ quality: 80 })
            .toBuffer();

        const uploadParams = {
            Bucket: "pn-cdn",
            Key: `headers/${community_id}/${console}.png`,
            Body: resizedBannerBuffer,
            ACL: "public-read",
            ContentType: "image/png",
        };
        await s3.putObject(uploadParams).promise();
    }
}
