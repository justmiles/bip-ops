#!/bin/bash

TS=$(date +"%Y%m%d_%H%M%S") tar -czvf /backups/$TS.tar.gz /game/UDKGame/SaveData
rm -rf /game/UDKGame/SaveData
tar -xzvf /backups/$1 -C /game/UDKGame/SaveData
