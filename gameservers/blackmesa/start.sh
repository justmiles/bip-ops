#!/bin/bash
set -e

# Black Mesa Deathmatch Dedicated Server (SRCDS)
# Native 32-bit Linux Source-engine build, anonymous SteamCMD download (appid 346680).
# https://developer.valvesoftware.com/wiki/SRCDS
# Mod directory is "bms"; game modes are Deathmatch maps (dm_*).

cd /game

# Source (32-bit) dedicated servers resolve the Steam client library from
# ~/.steam/sdk32/steamclient.so. Point it at the 32-bit copy SteamCMD ships so
# Steamworks init succeeds headless. Harmless to also wire up sdk64.
mkdir -p "$HOME/.steam/sdk32" "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk32/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux32/steamclient.so "$HOME/.steam/sdk32/steamclient.so"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# srcds_run auto-detects the 32-bit srcds_linux binary and sets LD_LIBRARY_PATH.
# Ports:
#   27015/udp - game + Steam A2S query (-port)
#   27015/tcp - Source RCON (same port, enabled when rcon_password is set in server.cfg)
START_OPTIONS=(
  -game bms
  -console
  -port "${BLACKMESA_PORT:-27015}"
  +map "${BLACKMESA_MAP:-dm_crossfire}"
  +maxplayers "${BLACKMESA_MAXPLAYERS:-16}"
  +exec server.cfg
)

# Game Server Login Token - only required to list the server on the public
# Steam master list. Anonymous (unset) servers still run for direct/LAN connects.
if [[ -n ${BLACKMESA_GSLT:-} ]]; then
  START_OPTIONS+=(+sv_setsteamaccount "$BLACKMESA_GSLT")
fi

echo "Starting Black Mesa Deathmatch Dedicated Server..."
set -x
./srcds_run "${START_OPTIONS[@]}"
