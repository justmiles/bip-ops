#!/bin/bash

rm -rf /game/UDKGame/Logs/Launch.log

monitor_logfile() {
  while [ ! -e "$1" ]; do
    sleep 1
  done
  tail -f "$1"
}

monitor_logfile /game/UDKGame/Logs/Launch.log &

echo "Launching gameserver!"

wine /game/Binaries/Win64/UDK.exe server coldmap1?steamsockets -logroot
