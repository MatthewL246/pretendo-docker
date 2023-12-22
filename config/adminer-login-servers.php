<?php
require_once "plugins/login-servers.php";
/** Set supported servers
* @param array array($description => array("server" => , "driver" => "server|pgsql|sqlite|..."))
*/
return new AdminerLoginServers(
    ($servers = [
        "Pretendo Postgres" => [
            "server" => "postgres",
            "driver" => "pgsql",
        ],
    ])
);
