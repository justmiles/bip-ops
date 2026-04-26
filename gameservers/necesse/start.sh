#!/bin/bash
set -e

# Necesse dedicated server launch script
# The server files are installed by SteamCMD into /game (App ID 1169370)
# Config is rendered to /home/bipops/.config/Necesse/cfg/server.cfg by gomplate before this runs
# Save data lives at /home/bipops/.config/Necesse/saves/
# Port: 14159/UDP (game, default)

cd /game

# Ensure the config directory exists
mkdir -p /home/bipops/.config/Necesse/cfg

# Build startup arguments
START_ARGS=(-nogui)

# World name
START_ARGS+=(-world "${NECESSE_WORLD:-default}")

# Port
if [[ -n "$NECESSE_PORT" ]]; then
  START_ARGS+=(-port "$NECESSE_PORT")
fi

# Max players / slots
if [[ -n "$NECESSE_SLOTS" ]]; then
  START_ARGS+=(-slots "$NECESSE_SLOTS")
fi

# Owner
if [[ -n "$NECESSE_OWNER" ]]; then
  START_ARGS+=(-owner "$NECESSE_OWNER")
fi

echo "Starting Necesse Dedicated Server..."
set -x
./StartServer-nogui.sh "${START_ARGS[@]}"
