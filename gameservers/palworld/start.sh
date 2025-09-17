#!/bin/bash
set -e

cd /game

# Set any required environment variables
# None required for basic operation

# Start options
START_OPTIONS=()

# Add community server option if enabled
if [[ -n $PALWORLD_COMMUNITY_SERVER ]] && [[ "${PALWORLD_COMMUNITY_SERVER,,}" == "true" ]]; then
  echo "Setting Community-Mode to enabled"
  START_OPTIONS+=("-publiclobby")
fi

# Add multi-threading options if enabled
if [[ -n $PALWORLD_MULTITHREAD_ENABLED ]] && [[ "${PALWORLD_MULTITHREAD_ENABLED,,}" == "true" ]]; then
  echo "Setting Multi-Core-Enhancements to enabled"
  START_OPTIONS+=("-useperfthreads" "-NoAsyncLoadingThread" "-UseMultithreadForDS")
fi

# Start the game server
echo "Starting Palworld Dedicated Server..."
set -x
./PalServer.sh "${START_OPTIONS[@]}"