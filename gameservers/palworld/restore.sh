#!/bin/bash

set -e

# Create backup before restore
/gameservers/$BIPOPS_GAMESERVER/backup.sh

rm -rf /game/Pal/Saved
mkdir -p /game/Pal/Saved
tar -xzvf /backups/$1 -C /game/Pal/Saved