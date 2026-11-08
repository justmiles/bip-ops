#!/bin/bash
set -e

# Project Zomboid Dedicated Server (server appid 380870) - native 64-bit Linux,
# anonymous SteamCMD. Ships a bundled JRE and a start-server.sh launcher.
# https://pzwiki.net/wiki/Dedicated_server

cd /game

# The server loads Steamworks (server list + VAC) via steamclient.so. Resolve it
# from ~/.steam/sdk64 and also drop a copy next to the bundled jre64 libs so the
# JNI loader finds it on a headless host.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"
[ -f /game/steamclient.so ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so /game/steamclient.so

# -cachedir pins the whole ~/Zomboid data dir (config, saves, logs) to a known
# path under /game so BipOps can back it up. Must match backupdir/configs in
# .bip-ops.yaml. The server name is fixed to "servertest" so the rendered
# servertest.ini is the one the server loads.
export PZ_CACHE_DIR="/game/Zomboid"
mkdir -p "${PZ_CACHE_DIR}/Server"

# JVM heap sizing. Project Zomboid reads -Xmx/-Xms from ProjectZomboid64.json;
# rewrite it from env so memory scales with the chosen size tier. Keep -Xms below
# -Xmx to avoid an oversized committed heap on small instances.
PZ_MEMORY="${PZ_MEMORY:-4096m}"
if [ -f /game/ProjectZomboid64.json ]; then
  echo "Setting JVM heap to ${PZ_MEMORY}"
  sed -i -E "s/-Xmx[0-9]+[mg]/-Xmx${PZ_MEMORY}/" /game/ProjectZomboid64.json || true
fi

# Ports:
#   16261/udp - DefaultPort  (game + server list, PZ_GAME_PORT)
#   16262/udp - UDPPort      (direct/client connections, PZ_UDP_PORT)
#   27015/tcp - RCON         (only active when PZ_RCON_PASSWORD is set)
PZ_OPTIONS=(
  -cachedir="${PZ_CACHE_DIR}"
  -servername "servertest"
  -port "${PZ_GAME_PORT:-16261}"
  -udpport "${PZ_UDP_PORT:-16262}"
)

# -adminpassword MUST be passed non-interactively: on first boot the server creates
# the admin account and, with no password on the command line, prompts for one on
# stdin -- which has no TTY here, so it crashes (NoSuchElementException: No line
# found). Always pass a value; default to "bipops" when the operator hasn't set one.
# It only applies on first boot (afterwards the password lives in the DB).
PZ_OPTIONS+=(-adminpassword "${PZ_ADMIN_PASSWORD:-bipops}")
if [[ -z "${PZ_ADMIN_PASSWORD:-}" ]]; then
  echo "PZ_ADMIN_PASSWORD not set - defaulting admin password to 'bipops' (override it)."
fi

echo "Starting Project Zomboid Dedicated Server..."
set -x
./start-server.sh "${PZ_OPTIONS[@]}"
