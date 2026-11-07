#!/bin/bash
set -e

# Counter-Strike 2 Dedicated Server (SRCDS)
# Native 64-bit Linux build, anonymous SteamCMD download (appid 730).
# https://developer.valvesoftware.com/wiki/Counter-Strike_2/Dedicated_Servers

cd /game

# CS2 resolves the Steam client library from ~/.steam/sdk64/steamclient.so.
# Point it at the copy SteamCMD already ships so Steamworks init succeeds headless.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# Game-mode matrix (see README):
#   game_type 0 / game_mode 1 = Competitive (default)
#   game_type 0 / game_mode 0 = Casual
#   game_type 0 / game_mode 2 = Wingman
#   game_type 1 / game_mode 2 = Deathmatch
START_OPTIONS=(
  -dedicated
  -console
  -usercon
  -port "${CS2_PORT:-27015}"
  +game_type "${CS2_GAME_TYPE:-0}"
  +game_mode "${CS2_GAME_MODE:-1}"
  +mapgroup "${CS2_MAPGROUP:-mg_active}"
  +map "${CS2_MAP:-de_dust2}"
  +sv_visiblemaxplayers "${CS2_MAXPLAYERS:-10}"
  +exec server.cfg
)

# Game Server Login Token - only required to list the server on the public
# Steam master list. Anonymous (unset) servers still run for direct/LAN connects.
if [[ -n $CS2_GSLT ]]; then
  START_OPTIONS+=(+sv_setsteamaccount "$CS2_GSLT")
fi

# GOTV / SourceTV relay, enabled only when a port is provided.
if [[ -n $CS2_TV_PORT ]]; then
  START_OPTIONS+=(+tv_enable 1 +tv_port "$CS2_TV_PORT")
fi

# Launch through the shipped cs2.sh wrapper rather than the raw binary: it
# prepends game/bin/linuxsteamrt64 to LD_LIBRARY_PATH (so libserver.so can
# resolve libv8.so), sets ENABLE_PATHMATCH, raises ulimits, and skips the
# Steam sniper-runtime requirement for -dedicated servers.
echo "Starting Counter-Strike 2 Dedicated Server..."
set -x
./game/cs2.sh "${START_OPTIONS[@]}"
