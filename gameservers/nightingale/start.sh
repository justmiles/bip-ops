#!/bin/bash
set -e

# Nightingale Dedicated Server (appid 3796810) - native 64-bit Linux (UE5),
# anonymous SteamCMD, fully headless. No Wine, no X display.
# https://playnightingale.com/dedicated-servers

cd /game

# The UE5 server resolves steamclient.so from ~/.steam/sdk64 for Steamworks init.
# Wire it up so init succeeds on a headless host.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# Gameplay-facing admin settings (Password, AdminPassword, StartingDifficulty) are
# rendered by configure-game.sh into NWX/Config/ServerSettings.ini. Networking and
# the player cap must be passed on the command line because they bind before the
# config file is read.

# Ports:
#   7777/udp         - game traffic (-port)
#   status (tcp/http)- optional HTTP status endpoint (-statusPort), off unless set
#
# Nightingale officially supports up to 6 players; higher values are unsupported.
NIGHTINGALE_OPTIONS=(
  "NWX"
  -port="${NIGHTINGALE_PORT:-7777}"
  -multihome="${NIGHTINGALE_BIND_ADDR:-0.0.0.0}"
  "-ini:Game:[/Script/Engine.GameSession]:MaxPlayers=${NIGHTINGALE_MAX_PLAYERS:-6}"
  -log
)

# Optional HTTP status endpoint for monitoring (1024-65535). Off unless a port is set.
if [[ -n "${NIGHTINGALE_STATUS_PORT:-}" ]]; then
  NIGHTINGALE_OPTIONS+=( -statusPort="${NIGHTINGALE_STATUS_PORT}" )
else
  echo "NIGHTINGALE_STATUS_PORT not set - HTTP status endpoint disabled."
fi

# Enable debug/cheat console commands only when explicitly requested.
if [[ "${NIGHTINGALE_ENABLE_CHEATS:-false}" == "true" ]]; then
  NIGHTINGALE_OPTIONS+=( -EnableCheats )
fi

echo "Starting Nightingale Dedicated Server..."
set -x
./NWX/Binaries/Linux/NWXServer-Linux-Shipping "${NIGHTINGALE_OPTIONS[@]}"
