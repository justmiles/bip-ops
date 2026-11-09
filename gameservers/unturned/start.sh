#!/bin/bash
set -e

# Unturned Dedicated Server (U3DS, appid 1110390) - native 64-bit Linux,
# anonymous SteamCMD, fully headless (no Wine, no X display).
# Official docs: https://github.com/SmartlyDressedGames/U3-Docs/blob/master/ServerHosting.md

cd /game

# The stock ServerHelper.sh copies the bundled steamclient.so next to the binary
# and points LD_LIBRARY_PATH at it, then runs:
#   ./Unturned_Headless.x86_64 -batchmode -nographics <args>
# We launch the headless binary directly so we control the server id and logging,
# wiring up steamclient.so the same way ServerHelper.sh does. Unturned ships its
# own steamclient.so under Linux/ -- prefer it, falling back to SteamCMD's copy.
if [ -f /game/Linux/steamclient.so ]; then
  export LD_LIBRARY_PATH="/game/Linux:${LD_LIBRARY_PATH}"
else
  mkdir -p "$HOME/.steam/sdk64"
  [ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
    ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"
  export LD_LIBRARY_PATH="/game:${LD_LIBRARY_PATH}"
fi

export TERM="${TERM:-xterm}"

# The server identity is fixed to "bipops" so the rendered Commands.dat / Config.json
# and all save data live at a known path (/game/Servers/bipops) that BipOps backs up.
# Do not change it without updating backupdir/configs in .bip-ops.yaml. Gameplay and
# presentation settings (Name, Map, MaxPlayers, Password, ...) are applied from the
# rendered Servers/bipops/Server/Commands.dat + Config.json by configure-game.sh.

# Ports:
#   27015/udp - game traffic          (+Port)
#   27016/udp - Steam A2S query        (game port + 1, implicit)
# Unturned always binds the query port as game-port+1; it is not separately set.

echo "Starting Unturned Dedicated Server (identity: bipops)..."
set -x
./Unturned_Headless.x86_64 -batchmode -nographics +InternetServer/bipops
