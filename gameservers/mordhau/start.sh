#!/bin/bash
set -e

# Mordhau Dedicated Server (appid 629800) - native Linux, anonymous SteamCMD.
# https://mordhau.fandom.com/wiki/Dedicated_Server_Setup
#
# The Linux dedicated-server binary is a native UE4 build. It is launched via the
# shipped MordhauServer.sh wrapper at the install root (/game/MordhauServer.sh),
# which sets LD_LIBRARY_PATH to the engine's libs before exec'ing
# Mordhau/Binaries/Linux/MordhauServer-Linux-Shipping.

cd /game

# Steamworks (server list / query) resolves steamclient.so from ~/.steam/sdk32 for
# the 32-bit server binary. Wire up both sdk dirs to the copies SteamCMD ships so
# init succeeds on a headless host.
mkdir -p "$HOME/.steam/sdk32" "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk32/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux32/steamclient.so "$HOME/.steam/sdk32/steamclient.so"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# Ports (all UDP):
#   7777  - game traffic   (-Port)
#   27015 - Steam query    (-QueryPort)
#   15000 - beacon/discovery for the in-game server browser (-BeaconPort)
#
# The first positional argument is the starting map/game mode. After boot the map
# rotation configured in Game.ini ([/Script/Mordhau.MordhauGameMode] MapRotation)
# takes over.
MORDHAU_OPTIONS=(
  "${MORDHAU_START_MAP:-FFA_ThePit}"
  -Port="${MORDHAU_PORT:-7777}"
  -QueryPort="${MORDHAU_QUERY_PORT:-27015}"
  -BeaconPort="${MORDHAU_BEACON_PORT:-15000}"
  -MultiHome="${MORDHAU_MULTIHOME:-0.0.0.0}"
  -log
)

echo "Starting Mordhau Dedicated Server..."
set -x
./MordhauServer.sh "${MORDHAU_OPTIONS[@]}"
