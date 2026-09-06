#!/bin/bash
set -e

cd /game

# Enshrouded ships only a Windows dedicated-server binary. bip-ops runs it under
# GE-Proton (rather than plain Wine) because Proton delivers substantially better
# CPU performance for this title.
# https://discourse.cubecoders.com/t/configuration-with-enshrouded-high-load-and-poor-performance-with-resources-to-spare/9200/8
# The server reads enshrouded_server.json from the current working directory,
# which bip-ops renders to /game/enshrouded_server.json (see .bip-ops.yaml configs).

export WINEDEBUG=-all
export SteamAppId=2278520

# Proton compatibility environment. Keep the prefix and steam-client dir on the
# /game volume so they persist across restarts and are only built once.
PROTON="/opt/${GE_PROTON_VERSION}/proton"
export STEAM_COMPAT_DATA_PATH=/game/.proton
export STEAM_COMPAT_CLIENT_INSTALL_PATH=/game/.steam

# Ensure the savegame/log and Proton directories exist (config saveDirectory is ./savegame)
mkdir -p /game/savegame /game/logs "$STEAM_COMPAT_DATA_PATH" "$STEAM_COMPAT_CLIENT_INSTALL_PATH"

set -x
"$PROTON" run /game/enshrouded_server.exe
