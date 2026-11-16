#!/bin/bash
set -e

cd /game

VERSION="${MINECRAFTBEDROCK_VERSION:-latest}"
VERSION_FILE="/game/.minecraftbedrock_version"

echo "Checking for Minecraft Bedrock Server updates..."

# Scrape the official Mojang download page for the Linux server URL
DOWNLOAD_URL=$(curl -fsSL -A "Mozilla/5.0 (Linux x86_64)" \
  "https://www.minecraft.net/en-us/download/server/bedrock" \
  | grep -oP 'https://[^"]+bin-linux/bedrock-server-[^"]+\.zip' | head -1)

if [ -z "$DOWNLOAD_URL" ]; then
  echo "ERROR: Could not find Bedrock server download URL on Mojang's download page"
  exit 1
fi

LATEST_VERSION=$(echo "$DOWNLOAD_URL" | grep -oP 'bedrock-server-\K[0-9.]+(?=\.zip)')
echo "Latest version available: $LATEST_VERSION"

if [ "$VERSION" == "latest" ]; then
  VERSION="$LATEST_VERSION"
fi

# Check if the requested version is already installed
if [ -f "$VERSION_FILE" ] && [ -f "/game/bedrock_server" ]; then
  INSTALLED_VERSION=$(cat "$VERSION_FILE")
  if [ "$INSTALLED_VERSION" == "$VERSION" ]; then
    echo "No update available. Current version: $VERSION"
    exit 0
  fi
  echo "Update available: $INSTALLED_VERSION -> $VERSION"
fi

# For non-latest version requests, substitute the version in the URL
if [ "$VERSION" != "$LATEST_VERSION" ]; then
  DOWNLOAD_URL=$(echo "$DOWNLOAD_URL" | sed "s/${LATEST_VERSION}/${VERSION}/g")
fi

echo "Downloading Minecraft Bedrock Server $VERSION..."
curl -fsSL -o /tmp/bedrock-server.zip "$DOWNLOAD_URL"

echo "Extracting server files..."
unzip -o /tmp/bedrock-server.zip -d /game
rm /tmp/bedrock-server.zip
chmod +x /game/bedrock_server

echo "$VERSION" > "$VERSION_FILE"
echo "Minecraft Bedrock Server $VERSION installed successfully"
