# Day of Defeat: Source Server

This directory contains the configuration and scripts for running a Day of Defeat: Source
dedicated server (SRCDS) using BipOps.

Day of Defeat: Source ships a native 32-bit Source-engine dedicated server that SteamCMD
downloads anonymously (Steam appid 232290), runs fully headless (no X display), and needs
no Wine. The BipOps image provides i386 multilib so the 32-bit `srcds_linux` binary runs.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=dods \
  -e DODS_HOSTNAME="BipOps Day of Defeat: Source Server" \
  -e DODS_RCON_PASSWORD=youradminpassword \
  -e DODS_MAP=dod_argentan \
  -e DODS_MAXPLAYERS=24 \
  -p 27015:27015/udp \
  -p 27015:27015/tcp \
  -v /path/to/gameservers/dods/game:/game \
  -v /path/to/gameservers/dods/backups:/backups \
  justmiles/bipops
```

To list the server publicly on the Steam server browser, obtain a Game Server Login
Token (GSLT) for app 300 from https://steamcommunity.com/dev/managegameservers and pass
it via `DODS_GSLT`. Without a token the server still runs and accepts direct connects.

## Required Ports

| Port  | Protocol | Description                                       |
| ----- | -------- | ------------------------------------------------- |
| 27015 | UDP      | Game traffic and Steam A2S query                  |
| 27015 | TCP      | RCON remote administration                        |

The UDP port is set by `DODS_PORT` (default 27015); map the same value on the host. The
Steam A2S query shares the game port unless `DODS_QUERY_PORT` is set to split it off.

## Volume Mounts

| Host Path                          | Container Path | Description            |
| ---------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/dods/game     | /game          | Game files directory   |
| /path/to/gameservers/dods/backups  | /backups       | Backup files directory |

## Stock Maps

Day of Defeat: Source ships these stock maps (set via `DODS_MAP`):

`dod_argentan`, `dod_anzio`, `dod_avalanche`, `dod_colmar`, `dod_donner`, `dod_flash`,
`dod_jagd`, `dod_kalt`, `dod_palermo`, `dod_strand`

## Environment Variables

| Variable             | Default                                   | Description                                                      |
| -------------------- | ----------------------------------------- | ---------------------------------------------------------------- |
| DODS_HOSTNAME        | "BipOps Day of Defeat: Source Server"     | Server name shown in the browser                                 |
| DODS_RCON_PASSWORD   | ""                                        | RCON administration password. Blank disables remote console      |
| DODS_PASSWORD        | ""                                        | Password required to join. Blank = public server                 |
| DODS_PORT            | 27015                                     | UDP game/query port (command line `-port`)                       |
| DODS_QUERY_PORT      | ""                                        | Separate A2S query port (`-steamport`); blank shares the game port |
| DODS_MAP             | dod_argentan                              | Map to load on startup                                           |
| DODS_MAXPLAYERS      | 24                                        | Player slots (`+maxplayers`, DoD:S supports up to 32)            |
| DODS_GSLT            | ""                                        | Game Server Login Token; required only to list publicly          |
| DODS_LAN             | 0                                         | 1 = LAN only, 0 = internet-reachable                             |
| DODS_CHEATS          | 0                                         | Enable `sv_cheats` (0 = off)                                     |
| DODS_CONTACT         | ""                                        | Server contact email shown in the browser                        |
| DODS_TIMELIMIT       | 30                                        | Map time limit in minutes (`mp_timelimit`)                       |
| DODS_FRIENDLYFIRE    | 0                                         | Enable friendly fire                                             |
| DODS_ALLOWSPECTATORS | 1                                         | Allow spectators                                                 |
| DODS_AUTOTEAMBALANCE | 1                                         | Auto-balance teams                                               |
| DODS_LIMITTEAMS      | 2                                         | Max team size difference before balancing                        |
| DODS_DOWNLOADURL     | ""                                        | Fast-download redirect URL for custom content                    |
| DODS_ALLOWDOWNLOAD   | 1                                         | Allow clients to download custom content                         |
| DODS_ALLOWUPLOAD     | 1                                         | Allow clients to upload custom content (sprays)                  |
| DODS_MINRATE         | 0                                         | Minimum network rate (0 = engine default)                        |
| DODS_MAXRATE         | 0                                         | Maximum network rate (0 = unlimited)                             |

## Server Administration

Set `DODS_RCON_PASSWORD` and connect with any Source RCON client to the TCP port (default
27015). Useful commands:

- `changelevel <map>` - switch map
- `mp_restartgame 1` - restart the current match
- `status` - list connected players and their SteamIDs
- `kick <name>` / `banid <minutes> <userid>` - moderation

## Notes

- The server config template renders to `/game/dod/cfg/server.cfg` and is executed at
  startup. Edit values through the `DODS_*` environment variables above.
- DoD:S is a 32-bit Source build and locates `steamclient.so` under `~/.steam/sdk32/`;
  `start.sh` symlinks the SteamCMD 32-bit copy there automatically so Steamworks
  initializes headless.
- The dedicated-server tool is Steam appid 232290; the store/library appid is 300.
- VAC secure mode is managed by Valve and does not require configuration here.
