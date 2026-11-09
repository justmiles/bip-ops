#!/bin/bash
set -e

# Fistful of Frags Dedicated Server (SRCDS, Source SDK 2013 mod "fof").
# Native 32-bit Linux build, anonymous SteamCMD download (server appid 295230).
# https://steamcommunity.com/app/265630/discussions/6/540739862043310160/
#   ./srcds_run -console -game fof +maxplayers 20 +map fof_fistful -port 27015

cd /game

# SRCDS is a 32-bit binary and resolves the Steam client library from
# ~/.steam/sdk32/steamclient.so (NOT sdk64). Point it at the 32-bit copy that
# SteamCMD already ships so Steamworks init succeeds headless. Also wire up the
# 64-bit path harmlessly in case anything probes it.
mkdir -p "$HOME/.steam/sdk32" "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk32/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux32/steamclient.so "$HOME/.steam/sdk32/steamclient.so"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# Launch options. Gameplay convars (hostname, rcon_password, sv_password, map
# rules, bots) are applied from fof/cfg/server.cfg, which srcds auto-execs and
# we also exec explicitly below.
START_OPTIONS=(
  -game fof
  -console
  -port "${FOF_PORT:-27015}"
  +maxplayers "${FOF_MAXPLAYERS:-12}"
  +map "${FOF_MAP:-fof_depot}"
  +exec server.cfg
)

# Game Server Login Token - only required to list the server on the public
# Steam master list. Anonymous (unset) servers still run for direct/LAN connects.
if [[ -n "${FOF_GSLT:-}" ]]; then
  START_OPTIONS+=(+sv_setsteamaccount "$FOF_GSLT")
fi

# Launch through the shipped srcds_run wrapper rather than the raw binary: it
# auto-selects the 32-bit srcds_linux binary and sets LD_LIBRARY_PATH for the
# bundled Source runtime libraries.
echo "Starting Fistful of Frags Dedicated Server..."
set -x
./srcds_run "${START_OPTIONS[@]}"
