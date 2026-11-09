#!/bin/bash
set -e

# Counter-Strike: Source Dedicated Server (SRCDS)
# Native 32-bit Linux build, anonymous SteamCMD download (appid 232330), fully headless.
# https://developer.valvesoftware.com/wiki/Counter-Strike:_Source

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
  -game cstrike
  -console
  -norestart
  -port "${CSS_PORT:-27015}"
  +map "${CSS_MAP:-de_dust2}"
  +maxplayers "${CSS_MAXPLAYERS:-16}"
  +servercfgfile server.cfg
)

# Game Server Login Token - only required to list the server on the public
# Steam master list. Anonymous (unset) servers still run for direct/LAN connects.
if [[ -n $CSS_GSLT ]]; then
  START_OPTIONS+=(+sv_setsteamaccount "$CSS_GSLT")
fi

# SourceTV relay, enabled only when a port is provided.
if [[ -n $CSS_TV_PORT ]]; then
  START_OPTIONS+=(+tv_enable 1 +tv_port "$CSS_TV_PORT")
else
  START_OPTIONS+=(-nohltv)
fi

echo "Starting Counter-Strike: Source Dedicated Server..."
set -x
exec ./srcds_run "${START_OPTIONS[@]}"
