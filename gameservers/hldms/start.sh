#!/bin/bash
set -e

# Half-Life Deathmatch: Source Dedicated Server (SRCDS)
# Native 32-bit Source-engine build, anonymous SteamCMD download (appid 255470).
# https://developer.valvesoftware.com/wiki/Source_Dedicated_Server
# Mod directory is "hl1mp"; launched via the shipped ./srcds_run wrapper, which
# auto-selects the 32-bit srcds_linux binary and sets LD_LIBRARY_PATH.

cd /game

# A 32-bit Source server resolves the Steam client library from
# ~/.steam/sdk32/steamclient.so. Point it at the 32-bit copy SteamCMD already
# ships so Steamworks init succeeds headless. Also wire up sdk64 (harmless).
mkdir -p "$HOME/.steam/sdk32" "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk32/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux32/steamclient.so "$HOME/.steam/sdk32/steamclient.so"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

START_OPTIONS=(
  -game hl1mp
  -console
  -port "${HLDMS_PORT:-27015}"
  +map "${HLDMS_MAP:-crossfire}"
  +maxplayers "${HLDMS_MAXPLAYERS:-16}"
  +exec server.cfg
)

# Restrict to LAN only when requested (default: internet-reachable).
if [[ "${HLDMS_LAN:-0}" != "0" ]]; then
  START_OPTIONS+=(+sv_lan 1)
fi

# Game Server Login Token - only required to list the server on the public
# Steam master list. Anonymous (unset) servers still run for direct/LAN connects.
if [[ -n "${HLDMS_GSLT:-}" ]]; then
  START_OPTIONS+=(+sv_setsteamaccount "$HLDMS_GSLT")
fi

# SourceTV / spectator relay, enabled only when a port is provided.
if [[ -n "${HLDMS_TV_PORT:-}" ]]; then
  START_OPTIONS+=(+tv_enable 1 +tv_port "$HLDMS_TV_PORT")
fi

echo "Starting Half-Life Deathmatch: Source Dedicated Server..."
set -x
./srcds_run "${START_OPTIONS[@]}"
