#!/command/with-contenv bash

if [  -f "/gameservers/$GAMESERVER/configure.sh" ]; then
  exec /gameservers/$GAMESERVER/configure.sh
fi
