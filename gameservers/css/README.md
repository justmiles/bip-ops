# Counter-Strike: Source Server

This directory contains the configuration and scripts for running a Counter-Strike: Source
dedicated server (SRCDS) using BipOps.

Counter-Strike: Source ships a native **32-bit** Linux dedicated server that SteamCMD
downloads anonymously (Steam appid 232330), runs fully headless (no X display), and needs
no Wine. The BipOps base image enables i386 multilib so the 32-bit `srcds_linux` binary runs.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=css \
  -e CSS_HOSTNAME="BipOps Counter-Strike: Source Server" \
  -e CSS_RCON_PASSWORD=youradminpassword \
  -e CSS_MAP=de_dust2 \
  -p 27015:27015/udp \
  -p 27015:27015/tcp \
  -v /path/to/gameservers/css/game:/game \
  -v /path/to/gameservers/css/backups:/backups \
  justmiles/bipops
```

To list the server publicly on the Steam server browser, obtain a Game Server Login
Token (GSLT) for app 240 from https://steamcommunity.com/dev/managegameservers and pass
it via `CSS_GSLT`. Without a token the server still runs and accepts direct connects.

## Required Ports

| Port  | Protocol | Description                                         |
| ----- | -------- | --------------------------------------------------- |
| 27015 | UDP      | Game traffic and Steam A2S query (same port)        |
| 27015 | TCP      | RCON remote administration                          |
| 27020 | UDP      | SourceTV relay (only when `CSS_TV_PORT` set)        |

The UDP port is set by `CSS_PORT` (default 27015); map the same value on the host. The
Steam query shares the game UDP port with no offset, and RCON is TCP on the same number.

## Volume Mounts

| Host Path                         | Container Path | Description            |
| --------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/css/game     | /game          | Game files directory   |
| /path/to/gameservers/css/backups  | /backups       | Backup files directory |

## Environment Variables

| Variable             | Default                                   | Description                                                         |
| -------------------- | ----------------------------------------- | ------------------------------------------------------------------- |
| CSS_HOSTNAME         | "BipOps Counter-Strike: Source Server"    | Server name shown in the browser                                   |
| CSS_RCON_PASSWORD    | ""                                        | RCON administration password. Blank disables remote console        |
| CSS_PASSWORD         | ""                                        | Password required to join. Blank = public server                   |
| CSS_PORT             | 27015                                     | UDP game/query port (command line `-port`)                         |
| CSS_MAP              | de_dust2                                  | Map to load on startup                                             |
| CSS_MAXPLAYERS       | 16                                        | Player slots (`-maxplayers`)                                       |
| CSS_GSLT             | ""                                        | Game Server Login Token; required only to list the server publicly |
| CSS_LAN              | 0                                         | 1 = LAN only, 0 = internet-reachable                               |
| CSS_CHEATS           | 0                                         | Enable `sv_cheats` (0 = off)                                       |
| CSS_ALLTALK          | 0                                         | Let both teams hear each other on voice                           |
| CSS_REGION           | 255                                       | Server browser region hint (255 = world)                          |
| CSS_TIMELIMIT        | 30                                        | Minutes before the map changes (`mp_timelimit`, 0 = no limit)     |
| CSS_MAXROUNDS        | 0                                         | Rounds per map (`mp_maxrounds`, 0 = unlimited)                    |
| CSS_WINLIMIT         | 0                                         | Rounds a team must win to end the map (`mp_winlimit`, 0 = off)    |
| CSS_ROUNDTIME        | 5                                         | Round length in minutes (`mp_roundtime`)                          |
| CSS_FREEZETIME       | 6                                         | Freeze/buy time at round start (seconds)                          |
| CSS_FRIENDLYFIRE     | 0                                         | Enable friendly fire                                              |
| CSS_AUTOTEAMBALANCE  | 1                                         | Auto-balance team sizes                                           |
| CSS_LIMITTEAMS       | 2                                         | Max team size difference before balancing                        |
| CSS_STARTMONEY       | 800                                       | Starting money each round (`mp_startmoney`)                      |
| CSS_BOT_QUOTA        | 0                                         | Number of bots to add at startup (0 = none)                      |
| CSS_BOT_DIFFICULTY   | 1                                         | Bot difficulty 0 (easy) to 3 (expert)                            |
| CSS_TV_PORT          | ""                                        | SourceTV relay UDP port. Unset = SourceTV disabled               |
| CSS_TV_DELAY         | 30                                        | SourceTV broadcast delay (seconds)                               |
| CSS_TV_NAME          | "BipOps SourceTV"                         | SourceTV bot display name                                        |
| CSS_DOWNLOADURL      | ""                                        | `sv_downloadurl` base URL for custom-content fast downloads      |

## Server Administration

Set `CSS_RCON_PASSWORD` and connect with any Source RCON client to the TCP port (default
27015). Useful commands:

- `changelevel <map>` - switch map
- `mp_restartgame 1` - restart the current round
- `bot_add` / `bot_kick` - manage bots
- `status` - list connected players and their SteamIDs
- `kick <name>` / `banid <minutes> <userid>` - moderation

## Notes

- The server config template renders to `/game/cstrike/cfg/server.cfg` and is executed
  on startup via `+servercfgfile server.cfg`. Edit values through the `CSS_*` environment
  variables above.
- CS:S is a 32-bit Source engine server; `start.sh` symlinks the 32-bit SteamCMD
  `steamclient.so` into `~/.steam/sdk32/` so Steamworks initializes headless.
- VAC secure mode is managed by Valve and does not require configuration here.
