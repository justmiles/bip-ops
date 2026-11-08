#!/bin/bash
set -e

# Team Fortress 2 Dedicated Server (SRCDS)
# Native Linux build, anonymous SteamCMD download (appid 232250), fully headless.
# https://developer.valvesoftware.com/wiki/Team_Fortress_2_Dedicated_Server

cd /game

# SRCDS resolves the Steam client library from ~/.steam/sdk64/steamclient.so.
# Point it at the copy SteamCMD already ships so Steamworks init succeeds headless.
mkdir -p "$HOME/.steam/sdk64" "$HOME/.steam/sdk32"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"
[ -f "$HOME/.steam/sdk32/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux32/steamclient.so "$HOME/.steam/sdk32/steamclient.so" 2>/dev/null || true

START_OPTIONS=(
  -game tf
  -console
  -norestart
  -port "${TF2_PORT:-27015}"
  +map "${TF2_MAP:-ctf_2fort}"
  +maxplayers "${TF2_MAXPLAYERS:-24}"
  +servercfgfile server.cfg
)

# Game Server Login Token - only required to list the server on the public
# Steam master list. Anonymous (unset) servers still run for direct/LAN connects.
if [[ -n $TF2_GSLT ]]; then
  START_OPTIONS+=(+sv_setsteamaccount "$TF2_GSLT")
fi

# SourceTV relay, enabled only when a port is provided.
if [[ -n $TF2_TV_PORT ]]; then
  START_OPTIONS+=(+tv_enable 1 +tv_port "$TF2_TV_PORT")
else
  START_OPTIONS+=(-nohltv)
fi

# Prefer the 64-bit launch wrapper (shipped since the 2024 64-bit update); fall
# back to the classic 32-bit srcds_run if the 64-bit wrapper is not present.
if [[ -x ./srcds_run_64 ]]; then
  LAUNCHER=./srcds_run_64
else
  LAUNCHER=./srcds_run
fi

echo "Starting Team Fortress 2 Dedicated Server via ${LAUNCHER}..."
set -x
exec "${LAUNCHER}" "${START_OPTIONS[@]}"
