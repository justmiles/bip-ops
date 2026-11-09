#!/bin/bash
set -e

# Half-Life 2: Deathmatch Dedicated Server (SRCDS)
# Native 32-bit Linux build, anonymous SteamCMD download (appid 232370), fully headless.
# Mod/game dir is "hl2mp". https://developer.valvesoftware.com/wiki/Half-Life_2:_Deathmatch

cd /game

# The 32-bit Source dedicated server resolves the Steam client library from
# ~/.steam/sdk32/steamclient.so. Point it at the 32-bit copy SteamCMD already
# ships so Steamworks init succeeds headless. Also wire up sdk64 harmlessly.
mkdir -p "$HOME/.steam/sdk32" "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk32/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux32/steamclient.so "$HOME/.steam/sdk32/steamclient.so"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so" 2>/dev/null || true

# srcds_run auto-detects the 32-bit srcds_linux binary and sets LD_LIBRARY_PATH.
# Game + Steam A2S query share the UDP -port; RCON is TCP on the same number.
START_OPTIONS=(
  -game hl2mp
  -console
  -norestart
  -port "${HL2DM_PORT:-27015}"
  +map "${HL2DM_MAP:-dm_lockdown}"
  +maxplayers "${HL2DM_MAXPLAYERS:-16}"
  +servercfgfile server.cfg
)

# Game Server Login Token - only required to list the server on the public
# Steam master list. Anonymous (unset) servers still run for direct/LAN connects.
if [[ -n $HL2DM_GSLT ]]; then
  START_OPTIONS+=(+sv_setsteamaccount "$HL2DM_GSLT")
fi

# SourceTV relay, enabled only when a port is provided.
if [[ -n $HL2DM_TV_PORT ]]; then
  START_OPTIONS+=(+tv_enable 1 +tv_port "$HL2DM_TV_PORT")
else
  START_OPTIONS+=(-nohltv)
fi

echo "Starting Half-Life 2: Deathmatch Dedicated Server..."
set -x
exec ./srcds_run "${START_OPTIONS[@]}"
