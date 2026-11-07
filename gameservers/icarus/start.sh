#!/bin/bash
set -e

cd /game

# Icarus (RocketWerkz) ships only a Windows dedicated-server binary
# (IcarusServer.exe), so bip-ops downloads the Windows build via SteamCMD
# (steamid 2089300, usewine: true) and runs it under the distro Wine.
# The server reads Icarus/Saved/Config/WindowsServer/ServerSettings.ini, which
# bip-ops renders from config/ServerSettings.ini (see .bip-ops.yaml configs).

export WINEPREFIX=/game/.wine
export WINEARCH=win64
export WINEDEBUG=-all

# Create/initialise the prefix (idempotent and cheap on subsequent restarts).
wineboot -u

# Icarus' Unreal Engine runtime needs the Visual C++ 2022 redistributable. Install
# it into the persistent prefix once; skip the (slow) winetricks run on restarts.
if WINEPREFIX="$WINEPREFIX" winetricks list-installed | grep -q "^vcrun2022$"; then
  echo "vcrun2022 is already installed in $WINEPREFIX"
else
  echo "vcrun2022 not found, installing..."
  WINEPREFIX="$WINEPREFIX" winetricks -q vcrun2022
  echo "vcrun2022 installation complete for $WINEPREFIX"
fi

# Defaults (ports can be overridden; config values come from ServerSettings.ini).
ICARUS_GAME_PORT=${ICARUS_GAME_PORT:-17777}
ICARUS_QUERY_PORT=${ICARUS_QUERY_PORT:-27015}

# Launch arguments. -log keeps the server console attached so output is captured.
ARGS="-log"
ARGS="$ARGS -PORT=$ICARUS_GAME_PORT"
ARGS="$ARGS -QueryPort=$ICARUS_QUERY_PORT"

echo "Starting Icarus Dedicated Server (game port $ICARUS_GAME_PORT, query port $ICARUS_QUERY_PORT)..."

set -x
exec wine /game/IcarusServer.exe $ARGS
