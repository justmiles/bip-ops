#!/bin/bash
set -e

# HumanitZ dedicated server launch script
# The server files are installed by SteamCMD into /game (App ID 2728330, beta branch "linuxbranch")
# Config is rendered to /game/HumanitZServer/GameServerSettings.ini by gomplate before this runs
# Ports: 7777/UDP (game), 27015/UDP (query), 8888/TCP (RCON)

cd /game

echo "Starting HumanitZ Dedicated Server..."
# Enable command tracing so the actual launch command is logged
set -x
./HumanitZServer.sh
