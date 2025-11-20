#!/command/with-contenv bash
set -e

echo "Updating game..."

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

# install the latest
function updateServer {
  USER=bipops HOME=/home/bipops s6-setuidgid bipops /usr/lib/steamcmd/steamcmd.sh \
    +@sSteamCmdForcePlatformType ${PLATFORM_TYPE} \
    +force_install_dir /game \
    +login ${LOGIN} \
    +app_update ${APP_UPDATE} \
    +quit
}

# Check for updates
if [ -f steamapps/appmanifest_$GAME_ID.acf ]; then
  CURRENT_VERSION=$(grep '"buildid"' steamapps/appmanifest_$GAME_ID.acf | awk '{print $2}' | tr -d '"')
  LATEST_VERSION=$(/usr/lib/steamcmd/steamcmd.sh +login anonymous +app_info_print $GAME_ID +quit \
    | grep -EA 1000 '^\s+"branches"' \
    | grep -EA 5 '^\s+"public"' \
    | grep -m 1 -E '^\s+"buildid"' \
    | awk '{print $2}' | tr -d '"')

  if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
    echo "Update available: $CURRENT_VERSION -> $LATEST_VERSION"
    rm -f steamapps/appmanifest_$GAME_ID.acf
    updateServer
  else
    echo "No update available. Current version: $CURRENT_VERSION"
  fi
else
  # no steamapps manifest found, let's install the game
  updateServer
fi
