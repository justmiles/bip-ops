#!/command/with-contenv bash
set -e

echo "Updating game..."

# Read game metadata from the game server's .bip-ops.yaml config
GAME_ID=$(yq '.steamid' "/gameservers/$BIPOPS_GAMESERVER/.bip-ops.yaml")
USE_WINE=$(yq '.usewine' "/gameservers/$BIPOPS_GAMESERVER/.bip-ops.yaml")
# Optional: some games require a specific Steam beta branch (e.g. HumanitZ needs "linuxbranch")
# Use -r for raw output to avoid yq wrapping the string value in quotes
STEAM_BRANCH=$(yq -r '.steambranch // ""' "/gameservers/$BIPOPS_GAMESERVER/.bip-ops.yaml")

# Use authenticated login if Steam credentials are provided, otherwise anonymous
LOGIN="anonymous"
if [ ! -z ${STEAM_USER+x} ] && [ ! -z ${STEAM_PASSWORD+x} ]; then
  LOGIN="${STEAM_USER} ${STEAM_PASSWORD}"
fi

# Build the SteamCMD app_update arguments:
#   - Start with the game's Steam App ID
#   - Append "-beta <branch>" if a beta branch is specified
#   - Append "validate" if file validation is enabled
APP_UPDATE="${GAME_ID}"
if [ ! -z "${STEAM_BRANCH}" ]; then
  APP_UPDATE="${APP_UPDATE} -beta ${STEAM_BRANCH}"
fi
if [ "${BIPOPS_VALIDATE_SERVER_FILES}" == "true" ]; then
  APP_UPDATE="${APP_UPDATE} validate"
fi

# Wine-based games need Windows binaries; native games use Linux
PLATFORM_TYPE="linux"
if [ "${USE_WINE}" == "true" ]; then
  PLATFORM_TYPE="windows"
fi

CURRENT_OWNER=$(stat -c "%U" /game)

cd /game

# Run SteamCMD to install or update the game server files as the bipops user
function updateServer {
  USER=bipops HOME=/home/bipops s6-setuidgid bipops /usr/lib/steamcmd/steamcmd.sh \
    +@sSteamCmdForcePlatformType ${PLATFORM_TYPE} \
    +force_install_dir /game \
    +login ${LOGIN} \
    +app_update ${APP_UPDATE} \
    +quit

  BYTES_DOWNLOADED=$(grep 'BytesDownloaded' steamapps/appmanifest_$GAME_ID.acf | awk '{print $2}' | tr -d '"')
  if [ "${BYTES_DOWNLOADED}" -eq 0 ]; then
    echo "Install/Update failed. Bytes downloaded: ${BYTES_DOWNLOADED}"
    echo "Ensure your STEAM_USER and STEAM_PASSWORD are correct."
    echo 1 > /run/s6-linux-init-container-results/exitcode
    /run/s6/basedir/bin/halt
  fi
}

# If an existing install manifest exists, check if a newer version is available
# before downloading. Otherwise, perform a fresh install.
if [ -f steamapps/appmanifest_$GAME_ID.acf ]; then
  # Extract the currently installed build ID from the local manifest
  CURRENT_VERSION=$(grep '"buildid"' steamapps/appmanifest_$GAME_ID.acf | awk '{print $2}' | tr -d '"')
  # Query Steam for the latest public build ID
  LATEST_VERSION=$(/usr/lib/steamcmd/steamcmd.sh +login anonymous +app_info_print $GAME_ID +quit \
    | grep -EA 1000 '^\s+"branches"' \
    | grep -EA 5 '^\s+"public"' \
    | grep -m 1 -E '^\s+"buildid"' \
    | awk '{print $2}' | tr -d '"')

  if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then
    echo "Update available: $CURRENT_VERSION -> $LATEST_VERSION"
    # Remove stale manifest so SteamCMD performs a full update
    rm -f steamapps/appmanifest_$GAME_ID.acf
    updateServer
  else
    echo "No update available. Current version: $CURRENT_VERSION"
  fi
else
  # No manifest found — this is a fresh install
  updateServer
fi
