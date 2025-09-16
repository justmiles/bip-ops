#!/bin/bash

set -e

# create backup before restore
/gameservers/$BIPOPS_GAMESERVER/backup.sh

rm -rf /userdata/Saves
mkdir /userdata/Saves
tar -xzvf /backups/$1 -C /userdata/Saves
