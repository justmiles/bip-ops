#!/bin/bash
set -e

# Core Keeper Dedicated Server
# Native 64-bit Linux Unity build, anonymous SteamCMD download (server appid 1963720).
# https://core-keeper.fandom.com/wiki/Command-line_arguments
#
# Core Keeper is a Unity dedicated server. Part of its procedural world generation
# runs on the GPU, so it needs an X display even headless: pass -batchmode (NOT
# -nographics) and run under the X display that svc-x11 brings up (usex: true).
#
# Persistent world settings (name, seed, mode, slots, game id) come from
# ServerConfig.json, which configure-game.sh renders to
#   $HOME/.config/unity3d/Pugstorm/Core Keeper/DedicatedServer/ServerConfig.json
# before this script runs. Networking (-port, -datapath) must be passed on the
# command line; -port also switches the server from the Steam relay network to
# direct connect so BipOps can expose a fixed UDP port.

cd /game

# Some Unity Steamworks servers resolve steamclient.so from ~/.steam/sdk64.
# Point it at the copy SteamCMD already ships so Steam init succeeds headless.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# Save data lives next to the rendered config under the Unity3d data dir, which is
# the backupdir in .bip-ops.yaml.
# Data dir MUST be a space-free path: configure-game.sh writes it into rsnapshot.conf
# as a backup point, and rsnapshot's tab-separated config rejects paths with spaces
# (the default Unity path ".../Core Keeper/..." breaks configtest -> boot fails).
DATA_PATH="/game/corekeeper"
mkdir -p "$DATA_PATH"

START_OPTIONS=(
  -batchmode
  -logfile -
  -datapath "$DATA_PATH"
  -port "${COREKEEPER_PORT:-27015}"
)

# The dedicated server ships a _launch.sh wrapper and the raw binary `CoreKeeperServer`
# (no .x86_64 extension). Launch it directly since the X display is already up.
echo "Starting Core Keeper Dedicated Server..."
set -x
./CoreKeeperServer "${START_OPTIONS[@]}"
