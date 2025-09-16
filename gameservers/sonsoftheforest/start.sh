#!/bin/bash

cd /game

echo "1326470" > steam_appid.txt

export SteamAppId=1326470
export SteamGameId=1326470

wine /game/SonsOfTheForestDS.exe -userdatapath /config

