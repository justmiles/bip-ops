#!/bin/bash
set -e

cd /game

# Bedrock server .so files live alongside the binary
export LD_LIBRARY_PATH=/game:$LD_LIBRARY_PATH

echo "Starting Minecraft Bedrock Server..."
exec ./bedrock_server
