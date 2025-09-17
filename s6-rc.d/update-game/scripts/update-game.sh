#!/command/with-contenv bash
set -e

echo "Update Game Server"

GAME_ID=$(yq '.steamid' "/gameservers/$BIPOPS_GAMESERVER/.bip-ops.yaml")
USE_WINE=$(yq '.usewine' "/gameservers/$BIPOPS_GAMESERVER/.bip-ops.yaml")

LOGIN="anonymous"
if [ ! -z ${STEAM_USER+x} ] && [ ! -z ${STEAM_PASSWORD+x} ]; then
  LOGIN="${STEAM_USER} ${STEAM_PASSWORD}"
fi

APP_UPDATE="${GAME_ID}"
if [ "${BIPOPS_VALIDATE_SERVER_FILES}" == "true" ]; then
  APP_UPDATE="${GAME_ID} validate"
fi

PLATFORM_TYPE="linux"
if [ "${USE_WINE}" == "true" ]; then
  PLATFORM_TYPE="windows"
fi

CURRENT_OWNER=$(stat -c "%U" /game)

cd /game

USER=bipops HOME=/home/bipops s6-setuidgid bipops /usr/lib/steamcmd/steamcmd.sh \
  +@sSteamCmdForcePlatformType ${PLATFORM_TYPE} \
  +force_install_dir /game \
  +login ${LOGIN} \
  +app_update ${APP_UPDATE} \
  +quit

echo "Game Server up to date!"
