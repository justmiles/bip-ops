#!/bin/bash
set -e

# Colony Survival Dedicated Server (appid 748090) - native 64-bit Linux build,
# anonymous SteamCMD download, runs fully headless (Unity -batchmode -nographics).
# https://colonysurvival.miraheze.org/wiki/Hosting_a_server
# https://github.com/pipliz/ColonySurvival/blob/master/gamedata/help/hosting.txt

cd /game

# Colony Survival is a Unity + Steamworks server. It resolves the Steam client
# library from ~/.steam/sdk64/steamclient.so for Steam networking (SteamOnline),
# so wire it to the copy SteamCMD already ships to let Steamworks init headless.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# Ports (both UDP, Steam datagram networking):
#   27004/udp - game/query port advertised to the server browser (+server.gameport)
#   27005/udp - Steam port (ServerGamePort in server.config.json)
#
# Most settings (server name, password, max players, world, seed, difficulty,
# network type, listing) come from the rendered server.config.json, which BipOps
# writes to /game/server.config.json. The browser-facing gameport is passed on the
# command line because it is not part of that config file.

START_OPTIONS=(
  -batchmode
  -nographics
  +server.config "/game/server.config.json"
  +server.gameport "${COLONYSURVIVAL_GAME_PORT:-27004}"
)

echo "Starting Colony Survival Dedicated Server..."
set -x
./colonyserver.x86_64 "${START_OPTIONS[@]}"
