#!/bin/bash
set -e

# Day of Defeat: Source Dedicated Server (SRCDS)
# Native 32-bit Source-engine build, anonymous SteamCMD download (appid 232290).
# https://developer.valvesoftware.com/wiki/Day_of_Defeat:_Source_Dedicated_Server

cd /game

# The 32-bit Source dedicated server resolves the Steam client library from
# ~/.steam/sdk32/steamclient.so. Point it at the 32-bit copy SteamCMD already
# ships so Steamworks init succeeds headless. Also wire up sdk64 harmlessly.
mkdir -p "$HOME/.steam/sdk32" "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk32/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux32/steamclient.so "$HOME/.steam/sdk32/steamclient.so"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# Launch options. srcds_run is the shipped wrapper: it auto-selects the 32-bit
# srcds_linux binary and sets LD_LIBRARY_PATH for the Source runtime libs.
#   -game dod     : mod directory for Day of Defeat: Source
#   -console      : run headless on the dedicated console
#   -port         : game + A2S query UDP port (default 27015)
#   +maxplayers   : player slot count (DoD:S supports up to 32)
#   +map          : starting map (stock dod_* maps)
#   +exec server.cfg : apply hostname/rcon/convars from the rendered config
START_OPTIONS=(
  -game dod
  -console
  -port "${DODS_PORT:-27015}"
  +maxplayers "${DODS_MAXPLAYERS:-24}"
  +map "${DODS_MAP:-dod_argentan}"
  +exec server.cfg
)

# Steam A2S query port. Source binds the query socket to the game port by
# default; override with -steamport only when DODS_QUERY_PORT is provided.
if [[ -n "${DODS_QUERY_PORT:-}" ]]; then
  START_OPTIONS+=(-steamport "${DODS_QUERY_PORT}")
fi

# Game Server Login Token - only required to list the server on the public
# Steam master list. Anonymous (unset) servers still run for direct/LAN connects.
if [[ -n "${DODS_GSLT:-}" ]]; then
  START_OPTIONS+=(+sv_setsteamaccount "${DODS_GSLT}")
fi

echo "Starting Day of Defeat: Source Dedicated Server..."
set -x
./srcds_run "${START_OPTIONS[@]}"
