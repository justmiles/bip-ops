#!/bin/bash
set -e

# Barotrauma Dedicated Server (appid 1026340) - native 64-bit Linux build,
# anonymous SteamCMD download, runs fully headless (no Wine, no X display).
# https://barotraumagame.com/wiki/Hosting_a_Dedicated_Server

cd /game

# Barotrauma reads/writes its config and saves under the XDG data dir:
#   $HOME/.local/share/Daedalic Entertainment GmbH/Barotrauma/
# Pin HOME to /game so serversettings.xml and the Multiplayer campaign saves
# live on the mounted volume (and get backed up) instead of /home/bipops.
# This path MUST stay in sync with backupdir/configs in .bip-ops.yaml.
export HOME=/game

# The dedicated server needs steamclient.so for Steamworks init / player auth.
# Without it you get "Exception: InitGameServer returned false". Point the
# standard lookup path at the copy SteamCMD already ships.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# Barotrauma bundles its own native libs (libsteam_api.so, etc.) next to the
# binary; make sure the loader can find them.
export LD_LIBRARY_PATH="/game:/game/linux64:${LD_LIBRARY_PATH}"

# Networking (game + Steam query ports) is configured in serversettings.xml,
# which configure-game.sh renders from the BAROTRAUMA_* env vars before this
# script runs. Barotrauma rewrites serversettings.xml on shutdown, so the
# rendered file is the source of truth for the FIRST boot of each run.
#   27015/udp - game traffic   (port)
#   27016/udp - Steam A2S query (queryport)

# ./DedicatedServer is a shell launcher shipped in the server root that sets up
# the environment and execs the native server binary.
echo "Starting Barotrauma Dedicated Server..."
set -x
./DedicatedServer
