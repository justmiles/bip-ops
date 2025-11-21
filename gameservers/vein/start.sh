#!/bin/bash
set -e

# https://ramjet.notion.site/dedicated-servers

cd /game

export SteamAppId=1857950
export WINEPREFIX="/game/.wine"

[ -f ./Vein/Binaries/Linux/steamclient.so ] || ln -s /usr/lib/steamcmd/linux64/steamclient.so ./Vein/Binaries/Linux/steamclient.so

# 27015/udp - Steam query port
# 7777/udp - VEIN sends gameplay packets

# Run VeinServer to start the server. You should see a lot of lines. 
# At the bottom, you should see some lines from LogRamjetSteamSocketsAPI 
# with SDR RelayNetworkStatus: avail=OK. This means Steam has connected successfully.
#  If you don’t get that, you may be missing some Steam dll or so files (see @Troubleshooting)
set -x
./VeinServer.sh -QueryPort=$VEIN_QUERY_PORT -Port=$VEIN_PORT -log
