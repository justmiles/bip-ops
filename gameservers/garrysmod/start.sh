#!/bin/bash
set -e

# Garry's Mod Dedicated Server (SRCDS)
# Native 32-bit Source-engine build, self-contained app (appid 4020),
# anonymous SteamCMD download, fully headless.
# https://wiki.facepunch.com/gmod/Downloading_a_Dedicated_Server

cd /game

# A 32-bit Source server resolves the Steam client library from
# ~/.steam/sdk32/steamclient.so. Point it at the 32-bit copy SteamCMD already
# ships so Steamworks init succeeds headless. Also wire up sdk64 harmlessly.
mkdir -p "$HOME/.steam/sdk32" "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk32/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux32/steamclient.so "$HOME/.steam/sdk32/steamclient.so"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so" 2>/dev/null || true

START_OPTIONS=(
  -game garrysmod
  -console
  -norestart
  -port "${GARRYSMOD_PORT:-27015}"
  +gamemode "${GARRYSMOD_GAMEMODE:-sandbox}"
  +map "${GARRYSMOD_MAP:-gm_construct}"
  +maxplayers "${GARRYSMOD_MAXPLAYERS:-16}"
  +servercfgfile server.cfg
)

# Workshop content: a collection ID pulls down a set of addons on boot. A
# workshop API key (+gmod_mountcfg is not needed) is only required for large
# collections; a bare collection ID works for most servers.
if [[ -n ${GARRYSMOD_WORKSHOP_COLLECTION:-} ]]; then
  START_OPTIONS+=(+host_workshop_collection "$GARRYSMOD_WORKSHOP_COLLECTION")
fi
if [[ -n ${GARRYSMOD_WORKSHOP_AUTH_KEY:-} ]]; then
  START_OPTIONS+=(-authkey "$GARRYSMOD_WORKSHOP_AUTH_KEY")
fi

# Game Server Login Token - recommended by Facepunch (unranked without it) but
# not strictly required: anonymous servers still run for direct/LAN connects.
if [[ -n ${GARRYSMOD_GSLT:-} ]]; then
  START_OPTIONS+=(+sv_setsteamaccount "$GARRYSMOD_GSLT")
fi

echo "Starting Garry's Mod Dedicated Server..."
set -x
exec ./srcds_run "${START_OPTIONS[@]}"
