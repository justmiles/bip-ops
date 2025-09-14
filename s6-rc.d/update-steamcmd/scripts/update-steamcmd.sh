#!/command/with-contenv bash

echo "Update SteamCMD"

LOGIN="anonymous"
if [ ! -z ${STEAM_USER+x} ] && [ ! -z ${STEAM_PASSWORD+x} ]; then
  LOGIN="${STEAM_USER} ${STEAM_PASSWORD}"
fi

/usr/lib/steamcmd/steamcmd.sh \
  +login $LOGIN \
  +quit

echo "SteamCMD up to date!"
