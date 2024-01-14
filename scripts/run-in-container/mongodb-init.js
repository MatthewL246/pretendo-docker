try {
    const status = rs.status();
    if (status.hasOwnProperty("myState") && status.myState == 1) {
        print("Replica set is already initiated. Exiting...");
        quit();
    }
} catch (error) {
    print("Replica set not initiated. Proceeding...");
}

// Initiate the replica set. We need to set up the members like this because, by
// default, the first member uses the host 127.0.0.1, which causes the other
// servers to attempt to connect to their own loopback addresses.
rs.initiate({
    _id: "rs",
    members: [
        {
            _id: 0,
            host: "mongodb:27017",
        },
    ],
});
