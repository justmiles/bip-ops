#!/bin/bash
set -e

# Satisfactory Dedicated Server (server appid 1690800, store appid 526870).
# Native 64-bit Linux dedicated server, downloaded anonymously via SteamCMD.
# Runs fully headless (no Wine, no X display).
# https://satisfactory.wiki.gg/wiki/Dedicated_servers

cd /game

# Satisfactory writes its save games, server-settings .sav, and the
# Config/LinuxServer/*.ini files under $HOME/.config/Epic/FactoryGame/Saved/.
# Pin $HOME to /game so all persistent state (and the rendered Game.ini) lands
# under /game, which is the mounted volume BipOps backs up. Do not change this
# without updating backupdir/configs in .bip-ops.yaml.
export HOME=/game

# FactoryServer.sh / the UE4 server resolve steamclient.so from ~/.steam/sdk64.
# Wire it up so the online/Steam query subsystem initializes on a headless host.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# Ports (as of patch 1.1.0.0):
#   7777/udp - game traffic + Lightweight Query API  (-Port)
#   7777/tcp - server traffic + HTTPS API            (-Port)
#   8888/tcp - reliable messaging                    (-ReliablePort)
SATISFACTORY_OPTIONS=(
  "-Port=${SATISFACTORY_PORT:-7777}"
  "-ReliablePort=${SATISFACTORY_RELIABLE_PORT:-8888}"
  -log
  -unattended
)

# Multiplayer phase-2 networking is the modern transport; it is on by default,
# but allow opting into the legacy query-port path if a client needs it.
if [[ -n "${SATISFACTORY_SERVER_QUERY_PORT:-}" ]]; then
  SATISFACTORY_OPTIONS+=("-ServerQueryPort=${SATISFACTORY_SERVER_QUERY_PORT}")
fi

if [[ -n "${SATISFACTORY_BEACON_PORT:-}" ]]; then
  SATISFACTORY_OPTIONS+=("-BeaconPort=${SATISFACTORY_BEACON_PORT}")
fi

echo "Starting Satisfactory Dedicated Server..."
set -x
./FactoryServer.sh "${SATISFACTORY_OPTIONS[@]}"
