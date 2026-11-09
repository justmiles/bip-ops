# Colony Survival Server

This directory contains the configuration and scripts for running a Colony Survival
dedicated server using BipOps.

Colony Survival ships a native 64-bit Linux dedicated server that SteamCMD downloads
anonymously (Steam appid 748090) and runs fully headless (Unity `-batchmode
-nographics`) with no Wine or X display. Settings are supplied through a rendered
`server.config.json` file.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=colonysurvival \
  -e COLONYSURVIVAL_SERVER_NAME="BipOps Colony Survival Server" \
  -e COLONYSURVIVAL_MAX_PLAYERS=10 \
  -e COLONYSURVIVAL_WORLD_NAME=BipOps \
  -e COLONYSURVIVAL_SEED=BipOps \
  -e COLONYSURVIVAL_DIFFICULTY=2 \
  -p 27004:27004/udp \
  -p 27005:27005/udp \
  -v /path/to/gameservers/colonysurvival/game:/game \
  -v /path/to/gameservers/colonysurvival/backups:/backups \
  justmiles/bipops
```

First boot downloads the server and generates the world from `COLONYSURVIVAL_SEED`.
The world is created once under its `COLONYSURVIVAL_WORLD_NAME`; subsequent boots load
that existing world. Changing the world name starts a fresh world, while changing the
seed only affects a world that has not been generated yet.

## Required Ports

| Port  | Protocol | Description                                                       |
| ----- | -------- | ---------------------------------------------------------------- |
| 27004 | UDP      | Game/query port advertised to the server browser (`+server.gameport`) |
| 27005 | UDP      | Steam networking port (`ServerGamePort` in `server.config.json`) |

## Volume Mounts

| Host Path                                   | Container Path | Description            |
| ------------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/colonysurvival/game    | /game          | Game files directory   |
| /path/to/gameservers/colonysurvival/backups | /backups       | Backup files directory |

World saves live under `/game/gamedata/savegames/<WorldName>/`, which is what BipOps
backs up.

## Environment Variables

| Variable                           | Default                          | Description                                                               |
| ---------------------------------- | -------------------------------- | ------------------------------------------------------------------------- |
| COLONYSURVIVAL_SERVER_NAME         | "BipOps Colony Survival Server"  | Server name shown in the browser (`ServerName`)                           |
| COLONYSURVIVAL_PASSWORD            | ""                               | Password required to join; empty = open server (`ServerPassword`)         |
| COLONYSURVIVAL_MAX_PLAYERS         | 10                               | Maximum player slots (`MaxPlayerCount`)                                    |
| COLONYSURVIVAL_WORLD_NAME          | BipOps                           | World/save name under `gamedata/savegames/` (`NewOptions.WorldName`)      |
| COLONYSURVIVAL_SEED                | BipOps                           | Terrain generation seed for a new world (`NewOptions.Seed`)               |
| COLONYSURVIVAL_DIFFICULTY          | 2                                | Difficulty preset key from `gamedata/settings/server.json` (`DifficultyKey`) |
| COLONYSURVIVAL_NETWORK_TYPE        | SteamOnline                      | Network type: SteamOnline, SteamLAN, LAN, Singleplayer (`NetworkType`)    |
| COLONYSURVIVAL_LIST_PUBLICLY       | true                             | List the server in the public server browser (`ServerListPublicly`)      |
| COLONYSURVIVAL_LIST_LAN            | true                             | Answer LAN discovery (`ServerListLAN`)                                     |
| COLONYSURVIVAL_LIST_FRIENDS        | true                             | Expose via Steam friends/rich presence (`ServerListFriends`)             |
| COLONYSURVIVAL_USE_VAC             | false                            | Enable Valve Anti-Cheat (`UseVAC`)                                        |
| COLONYSURVIVAL_MAX_DRAW_DISTANCE   | 1024                             | Maximum server draw distance (`MaxDrawDistance`)                          |
| COLONYSURVIVAL_RCON_PASSWORD       | ""                               | RCON password; empty disables RCON (`RCONPassword`)                       |
| COLONYSURVIVAL_GAME_PORT           | 27004                            | UDP browser/query port (`+server.gameport`)                              |
| COLONYSURVIVAL_STEAM_PORT          | 27005                            | UDP Steam networking port (`ServerGamePort`)                             |

## Server Administration

- The first admin is the first player to connect; permissions are then managed in
  `gamedata/savegames/<WorldName>/permissionusers.json`.
- Mods are configured via `gamedata/savegames/<WorldName>/modstate.json`.
- An RCON console is available when `COLONYSURVIVAL_RCON_PASSWORD` is set.

## Notes

- Colony Survival is a colony-management / tower-defense sandbox: direct colonists to
  gather, craft, farm, and build while defending against nightly monster waves.
- The full `server.config.json` (including the terrain generator block) is rendered
  from the template in `config/server.config.json`. The curated env vars above cover
  the common server and world settings; deeper terrain-generation tuning can be done by
  editing that template.
- The browser-facing game port is passed on the command line in `start.sh` because it
  is not part of `server.config.json`; the Steam networking port comes from the config.
