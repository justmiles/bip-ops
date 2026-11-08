#!/bin/bash
set -e

# Valheim Dedicated Server - native 64-bit Linux build, anonymous SteamCMD.
# Server install appid 896660; the binary must identify as the game app 892970.
# https://valheim.fandom.com/wiki/Dedicated_servers
# https://www.gameserverkings.com/knowledge-base/valheim/valheim-world-modifiers/

cd /game

# Valheim's Steamworks init resolves steamclient.so from ~/.steam/sdk64. Point it
# at the copy SteamCMD already ships so headless Steamworks init succeeds.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"

# The server ships its bundled runtime libs in ./linux64 and MUST report itself as
# the game app (892970), not the server install app (896660), or it refuses to boot.
export LD_LIBRARY_PATH="/game/linux64:${LD_LIBRARY_PATH}"
export SteamAppId=892970

# Save data (worlds + characters) is pinned to /game/saves so BipOps backs it up at
# a known path (see backupdir in .bip-ops.yaml). Do not change without updating it.
SAVE_DIR="/game/saves"
mkdir -p "$SAVE_DIR"

# A password is mandatory for a non-crossplay public server: it must be >= 5 chars
# and must NOT appear inside the server name, or the server exits at boot.
VALHEIM_SERVER_NAME="${VALHEIM_SERVER_NAME:-BipOps Valheim Server}"
VALHEIM_PASSWORD="${VALHEIM_PASSWORD:-valheim}"

VALHEIM_OPTIONS=(
  -nographics
  -batchmode
  -name "${VALHEIM_SERVER_NAME}"
  -port "${VALHEIM_PORT:-2456}"
  -world "${VALHEIM_WORLD:-Dedicated}"
  -password "${VALHEIM_PASSWORD}"
  -public "${VALHEIM_PUBLIC:-1}"
  -savedir "${SAVE_DIR}"
)

# Crossplay routes players through the Steam Datagram / PlayFab relay instead of
# binding a raw UDP game socket on -port. BipOps gives each server a dedicated
# public IP + port, so direct Steam connection is the default; set
# VALHEIM_CROSSPLAY=true to route console + PC players through the relay instead.
if [[ "${VALHEIM_CROSSPLAY:-false}" == "true" ]]; then
  VALHEIM_OPTIONS+=(-crossplay)
fi

# World difficulty preset (casual|easy|normal|hard|hardcore|immersive|hammer).
# "normal" is the default balance; only pass a preset when it is set to non-normal.
if [[ -n "${VALHEIM_PRESET:-}" && "${VALHEIM_PRESET}" != "normal" ]]; then
  VALHEIM_OPTIONS+=(-preset "${VALHEIM_PRESET}")
fi

# Individual world modifiers override the preset (pass "-modifier <key> <value>").
# Empty values are skipped so the game keeps its default dial for that key.
[[ -n "${VALHEIM_COMBAT:-}" ]]       && VALHEIM_OPTIONS+=(-modifier Combat "${VALHEIM_COMBAT}")
[[ -n "${VALHEIM_DEATH_PENALTY:-}" ]] && VALHEIM_OPTIONS+=(-modifier DeathPenalty "${VALHEIM_DEATH_PENALTY}")
[[ -n "${VALHEIM_RESOURCES:-}" ]]    && VALHEIM_OPTIONS+=(-modifier Resources "${VALHEIM_RESOURCES}")
[[ -n "${VALHEIM_RAIDS:-}" ]]        && VALHEIM_OPTIONS+=(-modifier Raids "${VALHEIM_RAIDS}")
[[ -n "${VALHEIM_PORTALS:-}" ]]      && VALHEIM_OPTIONS+=(-modifier Portals "${VALHEIM_PORTALS}")

echo "Starting Valheim Dedicated Server..."
set -x
./valheim_server.x86_64 "${VALHEIM_OPTIONS[@]}"
