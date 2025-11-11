#!/bin/bash
set -e

cd /game

export SteamAppId=1898300
export WINEPREFIX="/game/.wine"

# Check for ASKA_SAVE_ID and auto-detect if not set
if [ -z "$ASKA_SAVE_ID" ]; then
    SAVE_DIR="/game/.wine/drive_c/users/bipops/AppData/LocalLow/Sand Sailor Studio/Aska/data/server"
    if [ -d "$SAVE_DIR" ]; then
        # Find the latest modified save_game_* directory
        LATEST_SAVE=$(find "$SAVE_DIR" -maxdepth 1 -type d -name "savegame_*" -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
        if [ -n "$LATEST_SAVE" ]; then
            # Extract the save ID by removing the save_game_ prefix
            SAVE_ID=$(basename "$LATEST_SAVE" | sed 's/^savegame_//')
            export ASKA_SAVE_ID="$SAVE_ID"
            echo "Auto-detected ASKA_SAVE_ID: $ASKA_SAVE_ID"
            # Update the server_properties.txt file with the detected save ID
            sed -i "s/^save id = .*/save id = $ASKA_SAVE_ID/" "/game/server_properties.txt"
        fi
    fi
fi

# Start the server and capture exit code
wine AskaServer.exe -propertiesPath "/game/server_properties.txt"
