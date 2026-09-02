#!/bin/bash
set -e

cd /game

# Enshrouded is a Windows-only dedicated server run through Wine.
# The server reads enshrouded_server.json from the current working directory,
# which bip-ops renders to /game/enshrouded_server.json (see .bip-ops.yaml configs).

export WINEDEBUG=-all
export SteamAppId=2278520

# Ensure the savegame directory exists (config saveDirectory is ./savegame)
mkdir -p /game/savegame /game/logs

set -x
wine /game/enshrouded_server.exe
