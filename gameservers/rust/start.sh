#!/bin/bash
set -e

# Rust Dedicated Server (appid 258550) - native 64-bit Linux, anonymous SteamCMD.
# https://wiki.facepunch.com/rust/Creating-a-server

cd /game

# RustDedicated resolves steamclient.so from ~/.steam/sdk64 and loads its bundled
# plugin libs from RustDedicated_Data/Plugins/x86_64. Wire both up so Steamworks
# init succeeds on a headless host.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"
export LD_LIBRARY_PATH="/game:/game/RustDedicated_Data/Plugins/x86_64:${LD_LIBRARY_PATH}"

# server.identity is fixed to "bipops" so the rendered config and save data live at
# a known path (/game/server/bipops) that BipOps backs up. Do not change it without
# updating backupdir/configs in .bip-ops.yaml. Gameplay convars (hostname, pve, tags,
# ...) are applied from server/bipops/cfg/server.cfg, which Rust auto-executes.

# Ports:
#   28015/udp - game        (+server.port)
#   28016/udp - Steam query (+server.queryport)
#   28016/tcp - RCON web    (+rcon.port, only when a password is set)
#   28082/tcp - Rust+ app   (+app.port)
RUST_OPTIONS=(
  -batchmode -nographics
  +server.identity "bipops"
  +server.port "${RUST_SERVER_PORT:-28015}"
  +server.queryport "${RUST_QUERY_PORT:-28016}"
  +server.maxplayers "${RUST_MAX_PLAYERS:-50}"
  +server.seed "${RUST_SEED:-1337}"
  +server.worldsize "${RUST_WORLD_SIZE:-3000}"
  +app.port "${RUST_APP_PORT:-28082}"
)

# Enable web RCON only when a password is set. Rust's web RCON redacts the
# password from its logs via String.Replace and crashes at boot (Bootstrap
# Init_Tier0) if the password is an empty string.
if [[ -n "${RUST_RCON_PASSWORD:-}" ]]; then
  RUST_OPTIONS+=(
    +rcon.port "${RUST_RCON_PORT:-28016}"
    +rcon.password "${RUST_RCON_PASSWORD}"
    +rcon.web 1
  )
else
  echo "RUST_RCON_PASSWORD not set - RCON disabled."
fi

echo "Starting Rust Dedicated Server..."
set -x
./RustDedicated "${RUST_OPTIONS[@]}"
