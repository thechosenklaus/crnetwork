fx_version "cerulean"
game "common"
use_experimental_fxv2_oal "yes"
lua54 "yes"
node_version "22"

version "2.13.0"

dependencies {
	"/server:12913"
}

server_script "server-side/server.js"

provide "mysql-async"