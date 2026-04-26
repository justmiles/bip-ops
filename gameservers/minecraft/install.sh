#!/bin/bash
set -e

# Minecraft server installer for BipOps
# Downloads the Minecraft server JAR from Mojang's version manifest API.
# Runs during the update-game s6 phase (via devbox run, so Java is available).
# Supports version pinning via MINECRAFT_VERSION env var.

cd /game

VERSION="${MINECRAFT_VERSION:-latest}"
VERSION_FILE="/game/.minecraft_version"
MANIFEST_URL="https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"

echo "Checking for Minecraft server updates..."

# Fetch the version manifest
MANIFEST=$(curl -fsSL "$MANIFEST_URL")

# Resolve "latest" to an actual version number
if [ "$VERSION" == "latest" ]; then
  VERSION=$(echo "$MANIFEST" | jq -r '.latest.release')
  echo "Latest release version: $VERSION"
fi

# Check if the requested version is already installed
if [ -f "$VERSION_FILE" ] && [ -f "/game/server.jar" ]; then
  INSTALLED_VERSION=$(cat "$VERSION_FILE")
  if [ "$INSTALLED_VERSION" == "$VERSION" ]; then
    echo "No update available. Current version: $VERSION"
    exit 0
  fi
  echo "Update available: $INSTALLED_VERSION -> $VERSION"
fi

# Find the version entry in the manifest
VERSION_URL=$(echo "$MANIFEST" | jq -r --arg v "$VERSION" '.versions[] | select(.id == $v) | .url')

if [ -z "$VERSION_URL" ] || [ "$VERSION_URL" == "null" ]; then
  echo "ERROR: Minecraft version '$VERSION' not found in manifest"
  exit 1
fi

# Fetch version-specific metadata to get the server JAR download URL
VERSION_META=$(curl -fsSL "$VERSION_URL")
SERVER_URL=$(echo "$VERSION_META" | jq -r '.downloads.server.url')
SERVER_SHA1=$(echo "$VERSION_META" | jq -r '.downloads.server.sha1')

if [ -z "$SERVER_URL" ] || [ "$SERVER_URL" == "null" ]; then
  echo "ERROR: No server download URL found for version '$VERSION'"
  exit 1
fi

# Download the server JAR
echo "Downloading Minecraft server $VERSION..."
curl -fsSL -o /game/server.jar "$SERVER_URL"

# Verify checksum
DOWNLOADED_SHA1=$(sha1sum /game/server.jar | awk '{print $1}')
if [ "$DOWNLOADED_SHA1" != "$SERVER_SHA1" ]; then
  echo "ERROR: Checksum mismatch! Expected $SERVER_SHA1, got $DOWNLOADED_SHA1"
  rm -f /game/server.jar
  exit 1
fi

# Record installed version
echo "$VERSION" > "$VERSION_FILE"
echo "Minecraft server $VERSION installed successfully"
