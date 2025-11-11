#!/bin/bash
set -ex

cd /game

export SteamAppId=1898300
export WINEPREFIX="/game/.wine"

cat "/game/server_properties.txt"

# Start the server and capture exit code
wine AskaServer.exe -propertiesPath "/game/server_properties.txt"

sleep infinity