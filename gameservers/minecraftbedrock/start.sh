#!/bin/bash
set -e

cd /game

# Bedrock server .so files live alongside the binary
export LD_LIBRARY_PATH=/game:$LD_LIBRARY_PATH

# Generate allowlist.json from MINECRAFTBEDROCK_ALLOWED_PLAYERS if set.
# Format: comma-separated Xbox gamertags, e.g. "Alice,Bob, Charlie"
if [ -n "${MINECRAFTBEDROCK_ALLOWED_PLAYERS:-}" ]; then
  echo "Generating allowlist.json from MINECRAFTBEDROCK_ALLOWED_PLAYERS..."
  printf '[\n' > /game/allowlist.json
  first=true
  IFS=',' read -ra players <<< "$MINECRAFTBEDROCK_ALLOWED_PLAYERS"
  for player in "${players[@]}"; do
    # trim leading/trailing whitespace
    player="${player#"${player%%[! ]*}"}"
    player="${player%"${player##*[! ]}"}"
    [ -n "$player" ] || continue
    [ "$first" = true ] || printf ',\n' >> /game/allowlist.json
    printf '  {"ignoresPlayerLimit": false, "name": "%s"}' "$player" >> /game/allowlist.json
    first=false
  done
  printf '\n]\n' >> /game/allowlist.json
  echo "allowlist.json written ($(grep -c '"name"' /game/allowlist.json) players)"
fi

echo "Starting Minecraft Bedrock Server..."
exec ./bedrock_server
