#!/command/with-contenv bash

if [ -z "${GAMESERVER+x}" ]; then
  echo "GAMESERVER is not set" && exit 1
fi

if [ ! -d "/gameservers/$GAMESERVER" ]; then
  echo "GAMESERVER "$GAMESERVER" is not supported" && exit 1
fi

echo "Launching Game Server: $GAMESERVER"

function shutdownhook() {
  echo "Shutting down..."

  if [ -f "/gameservers/$GAMESERVER/backup.sh" ]; then
    exec /gameservers/$GAMESERVER/backup.sh
  fi

  if [ -f "/gameservers/$GAMESERVER/shutdown.sh" ]; then
    exec /gameservers/$GAMESERVER/shutdown.sh
  fi

}

trap shutdownhook EXIT

if [ ! -f "/gameservers/$GAMESERVER/start.sh" ]; then
  echo "$GAMESERVER/start.sh"" not found!"
  exit 1
fi

exec /gameservers/$GAMESERVER/start.sh

