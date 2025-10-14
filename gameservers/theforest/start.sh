#!/bin/bash

cd /game

wine /game/TheForestDedicatedServer.exe -batchmode -dedicated -savefolderpath /backups/current/ -configfilepath /backups/current/server.cfg
