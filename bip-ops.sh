#!/command/with-contenv bash

if [ -z "${BIPOPS_GAMESERVER+x}" ]; then
  echo "BIPOPS_GAMESERVER is not set" && exit 1
fi

if [ ! -d "/gameservers/$BIPOPS_GAMESERVER" ]; then
  echo "BIPOPS_GAMESERVER "$BIPOPS_GAMESERVER" is not supported" && exit 1
fi

echo "Launching Game Server: $BIPOPS_GAMESERVER"

function shutdownhook() {
  echo "Shutting down..."

  if [ -f "/gameservers/$BIPOPS_GAMESERVER/backup.sh" ]; then
    /gameservers/$BIPOPS_GAMESERVER/backup.sh
  fi

  if [ -f "/gameservers/$BIPOPS_GAMESERVER/shutdown.sh" ]; then
    /gameservers/$BIPOPS_GAMESERVER/shutdown.sh
  fi

}

trap shutdownhook EXIT

if [ ! -f "/gameservers/$BIPOPS_GAMESERVER/start.sh" ]; then
  echo "$BIPOPS_GAMESERVER/start.sh"" not found!"
  exit 1
fi

/gameservers/$BIPOPS_GAMESERVER/start.sh
