#!/command/with-contenv bash

if [ -z "${GAMESERVER+x}" ]; then
  echo "GAMESERVER is not set" && exit 1
else

if [ ! -d "/gameservers/$GAMESERVER" ]; then
  echo "GAMESERVER "$GAMESERVER" is not supported" && exit 1
fi
