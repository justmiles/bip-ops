#!/bin/bash
set -e

# Craftopia Dedicated Server (appid 1670340) - native 64-bit Linux Unity build,
# anonymous SteamCMD download. The game's store appid is 1307550.
# Launch binary: Craftopia.x86_64 (Unity headless).
# https://craftopiagame.fandom.com/wiki/Dedicated_server
# https://linuxgsm.com/servers/craftopia/

cd /game

# Craftopia is a Unity/Steamworks title. On a headless host the Steam client
# library is resolved from ~/.steam/sdk64/steamclient.so - point it at the copy
# SteamCMD already ships so Steamworks (and the Steam lobby) init succeeds.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"
export LD_LIBRARY_PATH="/game:${LD_LIBRARY_PATH}"

# Craftopia uses ServerSetting.ini's savePath verbatim when it is absolute, but
# prepends the cwd with NO separator when it is relative (cwd "/game" +
# "DedicatedServerSave/" -> "/gameDedicatedServerSave/", an unwritable root path
# that crashes the DB open). savePath is therefore the absolute, writable
# "/game/DedicatedServerSave/". Ensure the dir exists.
mkdir -p /game/DedicatedServerSave

# All gameplay/host settings come from ServerSetting.ini (rendered by BipOps from
# CRAFTOPIA_* env vars into /game/ServerSetting.ini). The server reads it from
# the install root at startup. Ports:
#   6587/udp - game / direct-connect port (ServerSetting.ini [Host] port)
# When isUseSteamLobby=1 players join via the Steam lobby; the UDP port is still
# used for direct-connect / query.
echo "Starting Craftopia Dedicated Server..."
set -x
./Craftopia.x86_64 -batchmode -nographics -showlogs
