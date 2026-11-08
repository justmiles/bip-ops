# Killing Floor 2 Server

This directory contains the configuration and scripts for running a Killing Floor 2
dedicated server using BipOps.

Killing Floor 2 ships a native 64-bit Linux (Unreal Engine 3) dedicated server that
SteamCMD downloads anonymously (server appid `232130`, distinct from the store/library
appid `232090`) and runs fully headless -- no Wine or X display. Gameplay rules are
passed to the binary as Unreal-style URL parameters, while passwords and WebAdmin
settings are seeded from rendered config files.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=killingfloor2 \
  -e KILLINGFLOOR2_SERVER_NAME="BipOps Killing Floor 2 Server" \
  -e KILLINGFLOOR2_ADMIN_PASSWORD=youradminpassword \
  -e KILLINGFLOOR2_GAMEMODE=KFGameContent.KFGameInfo_Survival \
  -e KILLINGFLOOR2_MAP=KF-BioticsLab \
  -e KILLINGFLOOR2_DIFFICULTY=0 \
  -e KILLINGFLOOR2_MAX_PLAYERS=6 \
  -p 7777:7777/udp \
  -p 27015:27015/udp \
  -p 20560:20560/udp \
  -p 8080:8080/tcp \
  -v /path/to/gameservers/killingfloor2/game:/game \
  -v /path/to/gameservers/killingfloor2/backups:/backups \
  justmiles/bipops
```

First boot downloads the server files (several GB) via SteamCMD, which can take a few
minutes before the server begins listening.

## Required Ports

| Port  | Protocol | Description                                                |
| ----- | -------- | ---------------------------------------------------------- |
| 7777  | UDP      | Game traffic (`?Port=`)                                    |
| 27015 | UDP      | Steam A2S query (`?QueryPort=`)                            |
| 20560 | UDP      | Steam master server / P2P (fixed; required to list)       |
| 8080  | TCP      | WebAdmin console (`KFWeb.ini` `ListenPort`)               |

If the 20560 UDP Steam port is not reachable, the server will run but will not appear
in the public server browser.

## Volume Mounts

| Host Path                                   | Container Path | Description            |
| ------------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/killingfloor2/game     | /game          | Game files directory   |
| /path/to/gameservers/killingfloor2/backups  | /backups       | Backup files directory |

Server configuration lives under `/game/KFGame/Config/`, which is what BipOps backs up.
Killing Floor 2 is wave-based and has no player save games; the backed-up config dir
holds server settings, bans, and map cycles.

## Environment Variables

| Variable                       | Default                                   | Description                                                              |
| ------------------------------ | ----------------------------------------- | ------------------------------------------------------------------------ |
| KILLINGFLOOR2_SERVER_NAME      | "BipOps Killing Floor 2 Server"           | Server name shown in the browser (`ServerName`)                          |
| KILLINGFLOOR2_GAME_PASSWORD    | ""                                        | Password to join; empty = public (`GamePassword`)                        |
| KILLINGFLOOR2_ADMIN_PASSWORD   | ""                                        | WebAdmin / in-game admin password (`AdminPassword`)                      |
| KILLINGFLOOR2_GAMEMODE         | KFGameContent.KFGameInfo_Survival         | Game mode class (`?Game=`): Survival, WeeklySurvival, Endless, VersusSurvival |
| KILLINGFLOOR2_MAP              | KF-BioticsLab                             | Starting map (`?` URL)                                                   |
| KILLINGFLOOR2_DIFFICULTY       | 0                                         | 0=Normal, 1=Hard, 2=Suicidal, 3=Hell on Earth (`?Difficulty=`)          |
| KILLINGFLOOR2_GAME_LENGTH      | 1                                         | 0=Short (4 waves), 1=Normal (7 waves), 2=Long (10 waves) (`?GameLength=`)|
| KILLINGFLOOR2_MAX_PLAYERS      | 6                                         | Max players: up to 6 (Survival), up to 12 (Versus) (`?MaxPlayers=`)      |
| KILLINGFLOOR2_VERSUS_MAX_PLAYERS | 12                                      | Max players for Versus mode in config (`KFGameInfo_VersusSurvival`)      |
| KILLINGFLOOR2_MAX_SPECTATORS   | 2                                         | Maximum spectator slots (`MaxSpectators`)                               |
| KILLINGFLOOR2_MOTD             | "Welcome to a BipOps Killing Floor 2 server." | Message of the day on connect (`ServerMOTD`)                      |
| KILLINGFLOOR2_PORT             | 7777                                      | UDP game port (`?Port=`)                                                 |
| KILLINGFLOOR2_QUERY_PORT       | 27015                                     | UDP Steam query port (`?QueryPort=`)                                     |
| KILLINGFLOOR2_WEBADMIN_PORT    | 8080                                      | TCP WebAdmin console port (`KFWeb.ini` `ListenPort`)                     |
| KILLINGFLOOR2_WEBADMIN_ENABLED | true                                      | Enable the browser-based WebAdmin console (`KFWeb.ini` `bEnabled`)       |

## Server Administration

Killing Floor 2 ships a browser-based **WebAdmin** console. Enable it with
`KILLINGFLOOR2_WEBADMIN_ENABLED=true` (default), set `KILLINGFLOOR2_ADMIN_PASSWORD`, and
browse to `http://<host>:8080/`. Log in with user `Admin` and your admin password to
change maps, kick/ban players, adjust game settings, and view the live match.

## Notes

- Gameplay rules (map, game mode, difficulty, length, max players) are passed on the
  command line as Unreal URL parameters in `start.sh`. Killing Floor 2 **rewrites its
  `*.ini` files on shutdown**, so command-line params are authoritative at boot and the
  rendered `LinuxServer-KFGame.ini` / `KFWeb.ini` seed passwords and WebAdmin settings.
- Survival/Endless/Weekly modes cap at 6 players; VersusSurvival supports up to 12.
- The server uses the Linux binary `Binaries/Win64/KFGameSteamServer.bin.x86_64` (the
  `Win64` path name is a quirk of the shared build layout; the `.x86_64` file is native
  ELF).
