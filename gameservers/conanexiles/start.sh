#!/bin/bash
set -e

# Conan Exiles (Enhanced) dedicated server.
# Native 64-bit Linux headless server, anonymous SteamCMD (appid 443030).
# The bundled ConanSandboxServer.sh just execs the shipping binary with the
# "ConanSandbox" project name as the first arg; we invoke the binary directly.
# https://github.com/GameServerManagers/LinuxGSM (ceserver)

cd /game

# The shipping binary resolves steamclient.so from ~/.steam/sdk64; symlink the
# SteamCMD copy so Steamworks init / A2S query succeeds on a headless host.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

export SteamAppId=440900

SERVER_BIN="./ConanSandbox/Binaries/Linux/ConanSandboxServer-Linux-Shipping"

# Ports:
#   7777/udp  - game traffic      (-Port)
#   7778/udp  - raw UDP socket    (Port + 1, implicit)
#   27015/udp - Steam A2S query   (-QueryPort)
CONAN_OPTIONS=(
  ConanSandbox
  -log
  -Port="${CONANEXILES_GAME_PORT:-7777}"
  -QueryPort="${CONANEXILES_QUERY_PORT:-27015}"
  -MaxPlayers="${CONANEXILES_MAX_PLAYERS:-40}"
)

echo "Starting Conan Exiles Dedicated Server..."
echo "First boot downloads a large install and initializes the world DB; this is slow."
set -x
exec "$SERVER_BIN" "${CONAN_OPTIONS[@]}"
