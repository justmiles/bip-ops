#!/bin/bash
set -e

# Hurtworld Dedicated Server (appid 405100) - native 64-bit Linux Unity build,
# anonymous SteamCMD download. Runs fully headless (-batchmode -nographics), no
# Wine or X display.
# https://hurtworld.fandom.com/wiki/Hosting_A_Server

cd /game

# Hurtworld is a Unity game built on Steamworks. It resolves the Steam client
# library from ~/.steam/sdk64/steamclient.so; point it at the copy SteamCMD
# already ships so the Steam query port / server listing works on a headless host.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# World saves (autosave_*.hwb) are written to the directory passed via the
# "savedirectory" exec command (rendered into /game/bipops/exec.txt). That path
# is what BipOps backs up (backupdir in .bip-ops.yaml). Make sure it exists.
mkdir -p /game/bipops

# Hurtworld takes its runtime configuration as a single semicolon-separated
# command string via -exec. configure-game.sh renders config/exec.txt (one
# command per line) from the HURTWORLD_* env vars; collapse it into that string
# here, dropping blank lines.
EXEC_FILE="/game/bipops/exec.txt"
EXEC_STRING=""
if [[ -f "$EXEC_FILE" ]]; then
  while IFS= read -r line; do
    [[ -z "${line// }" ]] && continue
    if [[ -z "$EXEC_STRING" ]]; then
      EXEC_STRING="$line"
    else
      EXEC_STRING="$EXEC_STRING;$line"
    fi
  done < "$EXEC_FILE"
fi

# Ports:
#   12871/udp - game   (host)
#   12881/udp - Steam query (queryport; required for the server browser listing)
echo "Hurtworld exec string: ${EXEC_STRING}"

HURTWORLD_OPTIONS=(
  -batchmode
  -nographics
  -logfile /dev/stdout
  -exec "${EXEC_STRING}"
)

echo "Starting Hurtworld Dedicated Server..."
set -x
./Hurtworld.x86_64 "${HURTWORLD_OPTIONS[@]}"
