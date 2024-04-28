// Hack: replace the /app/config.json with this config.js so we can use
// environment variables. Unfortunately, this doesn't just work automatically
// and requires a patch to package.json with module-alias.
module.exports = JSON.parse(
    JSON.stringify({
        http: {
            port: process.env.JUXT_CONFIG_HTTP_PORT,
        },
        mongoose: {
            uri: process.env.JUXT_CONFIG_MONGODB_URI,
            options: {
                useNewUrlParser: true,
                useUnifiedTopology: true,
            },
        },
        // CDN_domain is used for static files like images and JS. We don't actually
        // need a CDN domain here because we just let the Juxt server send the
        // static files
        CDN_domain: process.env.JUXT_CONFIG_CDN_DOMAIN,
        // mii_image_cdn should be cdn.pretendo.cc, but it seems to be hardcoded to
        // mii.olv.pretendo.cc in the source code, so we use that for consistency
        mii_image_cdn: process.env.JUXT_CONFIG_MII_IMAGE_CDN,
        // account_server_domain is currently unused in all views
        account_server_domain: process.env.JUXT_CONFIG_ACCOUNT_SERVER_DOMAIN,
        grpc: {
            friends: {
                ip: process.env.JUXT_CONFIG_GRPC_FRIENDS_IP,
                port: process.env.JUXT_CONFIG_GRPC_FRIENDS_PORT,
                api_key: process.env.JUXT_CONFIG_GRPC_FRIENDS_API_KEY,
            },
            account: {
                ip: process.env.JUXT_CONFIG_GRPC_ACCOUNT_IP,
                port: process.env.JUXT_CONFIG_GRPC_ACCOUNT_PORT,
                api_key: process.env.JUXT_CONFIG_GRPC_ACCOUNT_API_KEY,
            },
        },
        aes_key: process.env.JUXT_CONFIG_AES_KEY,
        // The whitelist was copied from the official servers, I have no clue
        // how it works
        whitelist: process.env.JUXT_CONFIG_WHITELIST,
        post_limit: process.env.JUXT_CONFIG_POST_LIMIT,
        aws: {
            spaces: {
                endpoint: process.env.JUXT_CONFIG_AWS_SPACES_ENDPOINT,
                key: process.env.JUXT_CONFIG_AWS_SPACES_KEY,
                secret: process.env.JUXT_CONFIG_AWS_SPACES_SECRET,
            },
        },
        redis: {
            host: process.env.JUXT_CONFIG_REDIS_HOST,
            port: process.env.JUXT_CONFIG_REDIS_PORT,
        },
    })
);
