#!/bin/bash

function shutdownhook() {
  echo "Shutting down..."

  if [ -f "/gameservers/$GAMESERVER/shutdown.sh" ]; then
    exec /gameservers/$GAMESERVER/shutdown.sh
  fi

}

trap shutdownhook EXIT

if [ ! -f "/gameservers/$GAMESERVER/start.sh" ]; then
  echo "$GAMESERVER/start.sh"" not found!"; exit 1
fi

exec /gameservers/$GAMESERVER/start.sh
