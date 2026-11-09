#!/bin/bash
set -e

# Insurgency: Sandstorm Dedicated Server (server appid 581330) - native 64-bit
# UE4 Linux build, anonymous SteamCMD download.
# https://linuxgsm.com/servers/inssserver/
# https://mantascope.com/guides/insurgency-sandstorm-server-admin-guide

cd /game

# The server resolves the Steam client library from ~/.steam/sdk64/steamclient.so.
# Point it at the copy SteamCMD already ships so Steamworks init succeeds headless.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# Ports:
#   27102/udp - game traffic   (-Port)
#   27131/udp - Steam A2S query (-QueryPort)
#   27015/tcp - RCON            ([Rcon] in Game.ini, enabled via env)
#
# The map + scenario + MaxPlayers are passed as the UE "travel URL" first argument:
#   <Map>?Scenario=<Scenario>?MaxPlayers=<N>
# Gameplay/RCON options live in Game.ini (rendered by configure-game.sh).
MAP="${INSURGENCYSANDSTORM_MAP:-Oilfield}"
SCENARIO="${INSURGENCYSANDSTORM_SCENARIO:-Scenario_Refinery_Checkpoint_Security}"
MAXPLAYERS="${INSURGENCYSANDSTORM_MAX_PLAYERS:-8}"

TRAVEL_URL="${MAP}?Scenario=${SCENARIO}?MaxPlayers=${MAXPLAYERS}"

START_OPTIONS=(
  "$TRAVEL_URL"
  -Port="${INSURGENCYSANDSTORM_PORT:-27102}"
  -QueryPort="${INSURGENCYSANDSTORM_QUERY_PORT:-27131}"
  -hostname="${INSURGENCYSANDSTORM_SERVER_NAME:-BipOps Insurgency Server}"
  -log
)

# Game Server Login Token - only required to list the server on the public
# Steam server browser. The token is generated for the STORE appid (581320).
if [[ -n "${INSURGENCYSANDSTORM_GSLT:-}" ]]; then
  START_OPTIONS+=(-GSLTToken="${INSURGENCYSANDSTORM_GSLT}")
fi

# GameStats token enables persistent player progression (XP/unlocks).
if [[ -n "${INSURGENCYSANDSTORM_GAMESTATS_TOKEN:-}" ]]; then
  START_OPTIONS+=(-GameStatsToken="${INSURGENCYSANDSTORM_GAMESTATS_TOKEN}")
fi

# Comma-separated mutator list (e.g. "Frenzy,Vampirism").
if [[ -n "${INSURGENCYSANDSTORM_MUTATORS:-}" ]]; then
  START_OPTIONS+=(-Mutators="${INSURGENCYSANDSTORM_MUTATORS}")
fi

echo "Starting Insurgency: Sandstorm Dedicated Server..."
set -x
./Insurgency/Binaries/Linux/InsurgencyServer-Linux-Shipping "${START_OPTIONS[@]}"
