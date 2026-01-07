#!/bin/bash

# Configure wine
export WINEPREFIX=/game/.wine
wineboot -u

if WINEPREFIX="$WINEPREFIX" winetricks list-installed | grep -q "^vcrun2022$"; then
  echo "vcrun2022 is already installed in $WINEPREFIX"
else
  echo "vcrun2022 not found, installing..."
  WINEPREFIX="$WINEPREFIX" winetricks -q vcrun2022
  echo "vcrun2022 installation complete for $WINEPREFIX"
fi

# Defaults
STARRUPTURE_SERVER_NAME=${STARRUPTURE_SERVER_NAME:-"BipOps StarRupture Server"}
STARRUPTURE_IP=${STARRUPTURE_IP:-"0.0.0.0"}
STARRUPTURE_GAME_PORT=${STARRUPTURE_GAME_PORT:-7777}
STARRUPTURE_QUERY_PORT=${STARRUPTURE_QUERY_PORT:-27015}

cd /game

# Launch arguments
ARGS="-Log"
ARGS="$ARGS -MULTIHOME=$STARRUPTURE_IP"
ARGS="$ARGS -Port=$STARRUPTURE_GAME_PORT"
ARGS="$ARGS -ServerName=\"$STARRUPTURE_SERVER_NAME\""

if [ -n "$STARRUPTURE_MAX_PLAYERS" ]; then
    ARGS="$ARGS -MaxPlayers=$STARRUPTURE_MAX_PLAYERS"
fi

echo "Starting StarRupture with args: $ARGS"

# Launch
wine /game/StarRupture/Binaries/Win64/StarRuptureServerEOS-Win64-Shipping.exe $ARGS -unattended
