#!/bin/bash
set -e

cd /game

# Enshrouded ships only a Windows dedicated-server binary. bip-ops runs it under
# the Wine build bundled with GE-Proton (wine-9.0 Staging with esync/fsync) rather
# than the distro Wine, because it delivers substantially better CPU performance
# for this title.
# https://discourse.cubecoders.com/t/configuration-with-enshrouded-high-load-and-poor-performance-with-resources-to-spare/9200/8
#
# We invoke GE-Proton's wine binary DIRECTLY instead of via the `proton` wrapper.
# `proton run` forces all Steamworks calls through Proton's lsteamclient shim,
# which requires a running Steam client and aborts on a headless dedicated server
# ("Assertion failed ... src-lsteamclient/steamclient_main.c"). Enshrouded ships
# its own standalone Steamworks redistributable (steamclient64.dll + steam_appid.txt),
# so once lsteamclient is out of the way the game initialises Steam on its own.
#
# The server reads enshrouded_server.json from the current working directory,
# which bip-ops renders to /game/enshrouded_server.json (see .bip-ops.yaml configs).

GE_DIR="/opt/${GE_PROTON_VERSION}/files"
WINE64="${GE_DIR}/bin/wine64"

export WINEDEBUG=-all
export WINEARCH=win64
export WINEESYNC=1
export WINEFSYNC=1
export SteamAppId=2278520

# Keep the Wine prefix on the /game volume so it persists across restarts and is
# only built once.
export WINEPREFIX=/game/.wine

# Use GE-Proton's runtime libraries and Wine DLLs.
export PATH="${GE_DIR}/bin:${PATH}"
export LD_LIBRARY_PATH="${GE_DIR}/lib64:${GE_DIR}/lib:${LD_LIBRARY_PATH}"

# Disable Proton's lsteamclient so the game loads its own steamclient64.dll.
export WINEDLLOVERRIDES="lsteamclient=d"

# Ensure the savegame/log directories exist (config saveDirectory is ./savegame)
mkdir -p /game/savegame /game/logs

# Create/initialise the prefix, then strip GE-Proton's lsteamclient shim and any
# registry redirect pointing at it so Enshrouded falls back to its bundled
# Steamworks SDK. These steps are idempotent and cheap on subsequent restarts.
"$WINE64" wineboot --init
find "$WINEPREFIX" -iname lsteamclient.dll -delete 2>/dev/null || true
"$WINE64" reg delete "HKCU\\Software\\Valve\\Steam\\ActiveProcess" /f >/dev/null 2>&1 || true

set -x
exec "$WINE64" /game/enshrouded_server.exe
