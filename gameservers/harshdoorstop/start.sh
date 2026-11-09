#!/bin/bash
set -e

# Operation: Harsh Doorstop Dedicated Server (SteamCMD appid 950900)
# Free, native 64-bit Linux Unreal Engine server, anonymous SteamCMD download.
# https://operation-harsh-doorstop.fandom.com/wiki/Server_Install_Instructions

cd /game

# The UE server resolves the Steam client library from ~/.steam/sdk64/steamclient.so.
# Point it at the copy SteamCMD already ships so Steamworks (master-list registration
# and A2S server queries) init succeeds on a headless host.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# Ports:
#   7777/udp  - game traffic        (-Port)
#   27005/udp - Steam A2S query     (-QueryPort)
#   7779/tcp  - RCON                 (-RCONPort, only when RCON enabled)
#   7778/udp  - Steam client (outbound, not forwarded)

# The server is launched with a map/mode URL (the first positional arg) followed by
# option flags. Scenario and mutators are passed as URL query params appended to the
# map, e.g. AAS-TestMap?MaxPlayers=32?Mutators=...  (see HARSHDOORSTOP_EXTRA_URL_ARGS).
MAP_URL="${HARSHDOORSTOP_MAP:-AAS-TestMap}?MaxPlayers=${HARSHDOORSTOP_MAX_PLAYERS:-32}"

if [[ -n "${HARSHDOORSTOP_MUTATORS:-}" ]]; then
  MAP_URL="${MAP_URL}?Mutators=${HARSHDOORSTOP_MUTATORS}"
fi

if [[ -n "${HARSHDOORSTOP_EXTRA_URL_ARGS:-}" ]]; then
  MAP_URL="${MAP_URL}?${HARSHDOORSTOP_EXTRA_URL_ARGS}"
fi

HD_OPTIONS=(
  "HarshDoorstop"
  "${MAP_URL}"
  -SteamServerName="${HARSHDOORSTOP_SERVER_NAME:-BipOps Harsh Doorstop Server}"
  -Port="${HARSHDOORSTOP_PORT:-7777}"
  -QueryPort="${HARSHDOORSTOP_QUERY_PORT:-27005}"
  -MULTIHOME="${HARSHDOORSTOP_MULTIHOME:-0.0.0.0}"
  -log
)

# Enable RCON only when a password is set. An empty RCON password is insecure and the
# game would otherwise listen with no auth.
if [[ -n "${HARSHDOORSTOP_RCON_PASSWORD:-}" ]]; then
  HD_OPTIONS+=(
    -EnableRCON
    -RCONPort="${HARSHDOORSTOP_RCON_PORT:-7779}"
    -RCONPassword="${HARSHDOORSTOP_RCON_PASSWORD}"
    -RCONMaxAuthAttempts="${HARSHDOORSTOP_RCON_MAX_AUTH_ATTEMPTS:-3}"
    -RCONMaxActiveConnections="${HARSHDOORSTOP_RCON_MAX_CONNECTIONS:-5}"
  )
else
  echo "HARSHDOORSTOP_RCON_PASSWORD not set - RCON disabled."
fi

echo "Starting Operation: Harsh Doorstop Dedicated Server..."
set -x
./HarshDoorstop/Binaries/Linux/HarshDoorstopServer-Linux-Shipping "${HD_OPTIONS[@]}"
