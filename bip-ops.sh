#!/command/with-contenv bash

if [ -z "${BIPOPS_GAMESERVER+x}" ]; then
  echo "BIPOPS_GAMESERVER is not set" && exit 1
fi

if [ ! -d "/gameservers/$BIPOPS_GAMESERVER" ]; then
  echo "BIPOPS_GAMESERVER $BIPOPS_GAMESERVER is not supported" && exit 1
fi

echo "Launching Game Server: $BIPOPS_GAMESERVER"

function shutdownhook() {
  echo "Shutting down..."

  s6-setuidgid bipops /usr/bin/rsnapshot latest

  if [ -f "/gameservers/$BIPOPS_GAMESERVER/shutdown.sh" ]; then
    s6-setuidgid bipops /gameservers/$BIPOPS_GAMESERVER/shutdown.sh
  fi

}

trap shutdownhook EXIT

if [ ! -f "/gameservers/$BIPOPS_GAMESERVER/start.sh" ]; then
  echo "$BIPOPS_GAMESERVER/start.sh not found!"
  exit 1
fi

USEX=$(yq '.usex' "/gameservers/$BIPOPS_GAMESERVER/.bip-ops.yaml")

if [ "$USEX" == "true" ]; then
  # Wait for X socket
  for i in {1..30}; do
    if xset q >/dev/null 2>&1; then
        echo "X display $DISPLAY is ready"
        break
    fi
  sleep 1
  done
fi

USER=bipops HOME=/home/bipops s6-setuidgid bipops /gameservers/$BIPOPS_GAMESERVER/start.sh 2>&1 | s6-log -bp n3 1 /var/log/$BIPOPS_GAMESERVER
