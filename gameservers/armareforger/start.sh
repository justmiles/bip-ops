#!/bin/bash
set -e

# Arma Reforger Dedicated Server (appid 1874900) - native 64-bit Linux build,
# anonymous SteamCMD download, fully headless (no Wine, no X display).
# https://community.bistudio.com/wiki/Arma_Reforger:Server_Hosting

cd /game

# Arma Reforger resolves steamclient.so from ~/.steam/sdk64; wire it up to the
# copy SteamCMD already ships so Steamworks init succeeds on a headless host.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# configure-game.sh renders config/server.json -> /game/config/server.json before
# this script runs. The -profile dir (/game/profile) holds logs, crash reports and
# session saves and is what BipOps backs up.
mkdir -p /game/profile

# Ports (all UDP):
#   2001  - game        (config bindPort / publicPort)
#   17777 - Steam A2S   (config a2s.port - lists the server in the browser)
#   19999 - RCON        (config rcon.port - only emitted when a password is set)
ARMAREFORGER_OPTIONS=(
  -config "/game/config/server.json"
  -profile "/game/profile"
  -maxFPS "${ARMAREFORGER_MAX_FPS:-60}"
  -logStats "${ARMAREFORGER_LOG_STATS:-60000}"
  -logLevel "${ARMAREFORGER_LOG_LEVEL:-normal}"
)

# Optional AI cap - lowers CPU load on smaller tiers when set.
if [[ -n "${ARMAREFORGER_AI_LIMIT:-}" ]]; then
  ARMAREFORGER_OPTIONS+=(-aiLimit "${ARMAREFORGER_AI_LIMIT}")
fi

echo "Starting Arma Reforger Dedicated Server..."
set -x
./ArmaReforgerServer "${ARMAREFORGER_OPTIONS[@]}"
