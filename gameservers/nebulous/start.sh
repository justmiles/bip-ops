#!/bin/bash
set -e

# NEBULOUS: Fleet Command Dedicated Server (appid 2353090)
# Native 64-bit Linux Unity server, anonymous SteamCMD download, runs fully
# headless with -nographics -batchmode (no Wine, no X display).
# Refs:
#   https://steamcommunity.com/sharedfiles/filedetails/?id=2963605370  (official guide)
#   https://github.com/CubeCoders/AMPTemplates (nebulous-fleet-command.kvp)

cd /game

# The Unity server links against Steamworks. Point the Steam SDK path at the
# steamclient.so SteamCMD already ships so Steamworks init succeeds headless.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# NEBULOUS resolves its game identity against the store appid (887570), not the
# server appid. The AMP template sets SteamAppId=887570; mirror that here.
export SteamAppId="${NEBULOUS_STEAM_APP_ID:-887570}"

# Help the Unity player resolve its bundled native libs (libsteam_api.so, etc.).
export LD_LIBRARY_PATH="/game:/game/linux64:${LD_LIBRARY_PATH}"

# The server config parser requires CRLF (Windows) line endings; it crashes on a
# plain LF file. configure-game.sh renders the gomplate template with LF, so
# convert the rendered copy in place before launch.
CONFIG_FILE="/game/DedicatedServerConfig.xml"
if [ -f "$CONFIG_FILE" ]; then
  sed -i 's/\r$//; s/$/\r/' "$CONFIG_FILE"
fi

# Ports (set in DedicatedServerConfig.xml, defaults shown):
#   7777/tcp  - GamePort  (all gameplay traffic; TCP in/out)
#   27016/udp - QueryPort (Steam server-browser A2S query; UDP inbound)
echo "Starting NEBULOUS: Fleet Command Dedicated Server..."
set -x
exec ./NebulousDedicatedServer \
  -nographics \
  -batchmode \
  -serverConfig "$CONFIG_FILE" \
  -logFile -
