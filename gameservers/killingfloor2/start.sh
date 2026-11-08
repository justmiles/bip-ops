#!/bin/bash
set -e

# Killing Floor 2 Dedicated Server (server appid 232130) - native 64-bit UE3
# Linux binary, anonymous SteamCMD. Store/library appid is 232090.
# https://wiki.killingfloor2.com/index.php?title=Dedicated_Server_(Killing_Floor_2)

cd /game

# The UE3 server resolves steamclient.so from its own Binaries/Win64 dir and from
# ~/.steam/sdk64. Wire both up so Steamworks init succeeds on a headless host.
mkdir -p "$HOME/.steam/sdk64"
[ -f "$HOME/.steam/sdk64/steamclient.so" ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so "$HOME/.steam/sdk64/steamclient.so"
[ -f /game/Binaries/Win64/steamclient.so ] || \
  ln -s /usr/lib/steamcmd/linux64/steamclient.so /game/Binaries/Win64/steamclient.so

export SteamAppId=232090
export LD_LIBRARY_PATH="/game/Binaries/Win64:${LD_LIBRARY_PATH}"

# Ports (all configurable):
#   7777/udp  - game traffic      (?Port=)
#   27015/udp - Steam A2S query   (?QueryPort=)
#   20560/udp - Steam master/P2P  (fixed by Steamworks; expose it or the server won't list)
#   8080/tcp  - WebAdmin console  (KFWeb.ini ListenPort)
#
# KF2 rewrites its *.ini files on shutdown, so gameplay rules are passed as
# Unreal-style URL params on the command line (these take priority over the ini)
# while passwords/WebAdmin live in the rendered config files. MaxPlayers caps at
# 6 for Survival and 12 for VersusSurvival.

KF2_MAP="${KILLINGFLOOR2_MAP:-KF-BioticsLab}"
KF2_GAMEMODE="${KILLINGFLOOR2_GAMEMODE:-KFGameContent.KFGameInfo_Survival}"

KF2_URL="${KF2_MAP}?Game=${KF2_GAMEMODE}"
KF2_URL="${KF2_URL}?Difficulty=${KILLINGFLOOR2_DIFFICULTY:-0}"
KF2_URL="${KF2_URL}?GameLength=${KILLINGFLOOR2_GAME_LENGTH:-1}"
KF2_URL="${KF2_URL}?MaxPlayers=${KILLINGFLOOR2_MAX_PLAYERS:-6}"

echo "Starting Killing Floor 2 Dedicated Server..."
set -x
exec ./Binaries/Win64/KFGameSteamServer.bin.x86_64 \
  "${KF2_URL}" \
  -Port="${KILLINGFLOOR2_PORT:-7777}" \
  -QueryPort="${KILLINGFLOOR2_QUERY_PORT:-27015}" \
  -WebAdminPort="${KILLINGFLOOR2_WEBADMIN_PORT:-8080}"
