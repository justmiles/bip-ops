#!/bin/bash

set -e

# create backup before restore
/gameservers/$BIPOPS_GAMESERVER/backup.sh

rm -rf /backups/current/Saves
mkdir /backups/current/Saves
tar -xzvf /backups/$1 -C /backups/current/Saves
