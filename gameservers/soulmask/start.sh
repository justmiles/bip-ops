#!/bin/bash
set -e

# Soulmask Dedicated Server (appid 3017300) - native 64-bit Linux, anonymous SteamCMD.
# Launches via the shipped WSServer.sh wrapper. The server REFUSES to run as root;
# bip-ops already runs start.sh as the non-root `bipops` user, so that is satisfied.
# https://soulmask.fandom.com/wiki/Private_Server

cd /game

# Soulmask is a Steamworks server and resolves steamclient.so from ~/.steam/sdk64.
# Point it at the copy SteamCMD already ships so Steamworks init succeeds headless.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# World/save data lives under /game/WS/Saved (backupdir in .bip-ops.yaml). The level
# name is the first positional arg to WSServer.sh and also names the save folder:
#   /game/WS/Saved/Worlds/Dedicated/<level>/world.db
LEVEL="${SOULMASK_LEVEL:-Level01_Main}"

# Ports:
#   8777/udp  - game        (-Port)
#   27015/udp - Steam query (-QueryPort, server-browser visibility)
#   18888/tcp - echo/telnet maintenance console (-EchoPort, bound locally)
#   19000/tcp - RCON        (-rconport, only enabled when -rconpsw is set)
SOULMASK_OPTIONS=(
  "$LEVEL"
  -server
  -log
  -UTF8Output
  -forcepassthrough
  -MULTIHOME="${SOULMASK_MULTIHOME:-0.0.0.0}"
  -Port="${SOULMASK_PORT:-8777}"
  -QueryPort="${SOULMASK_QUERY_PORT:-27015}"
  -EchoPort="${SOULMASK_ECHO_PORT:-18888}"
  -SteamServerName="${SOULMASK_SERVER_NAME:-BipOps Soulmask Server}"
  -MaxPlayers="${SOULMASK_MAX_PLAYERS:-20}"
  -saving="${SOULMASK_SAVE_INTERVAL:-600}"
  -backup="${SOULMASK_BACKUP_INTERVAL:-1800}"
)

# Game mode: PvE by default. Set SOULMASK_PVP=true for a PvP server.
if [[ "${SOULMASK_PVP:-false}" == "true" ]]; then
  SOULMASK_OPTIONS+=(-pvp)
else
  SOULMASK_OPTIONS+=(-pve)
fi

# Join password - only applied when set (empty = public, no password).
if [[ -n "${SOULMASK_PASSWORD:-}" ]]; then
  SOULMASK_OPTIONS+=(-PSW="${SOULMASK_PASSWORD}")
fi

# Admin/GM password used to grant in-game admin rights.
if [[ -n "${SOULMASK_ADMIN_PASSWORD:-}" ]]; then
  SOULMASK_OPTIONS+=(-adminpsw="${SOULMASK_ADMIN_PASSWORD}")
fi

# RCON remote console - enabled only when a password is provided.
if [[ -n "${SOULMASK_RCON_PASSWORD:-}" ]]; then
  SOULMASK_OPTIONS+=(
    -rconenabled=True
    -rconport="${SOULMASK_RCON_PORT:-19000}"
    -rconpsw="${SOULMASK_RCON_PASSWORD}"
  )
else
  echo "SOULMASK_RCON_PASSWORD not set - RCON disabled."
fi

echo "Starting Soulmask Dedicated Server (level=$LEVEL)..."
set -x
./WSServer.sh "${SOULMASK_OPTIONS[@]}"
