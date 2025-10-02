#!/command/with-contenv bash
set -e


echo "Updating steamcmd..."

LOGIN="anonymous"
if [ ! -z ${STEAM_USER+x} ] && [ ! -z ${STEAM_PASSWORD+x} ]; then
  LOGIN="${STEAM_USER} ${STEAM_PASSWORD}"
fi

HOME=/home/bipops s6-setuidgid bipops /usr/lib/steamcmd/steamcmd.sh \
  +login $LOGIN \
  +quit

echo "steamcmd up to date!"
