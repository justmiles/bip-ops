# Counter-Strike 2 Server

This directory contains the configuration and scripts for running a Counter-Strike 2
dedicated server (SRCDS) using BipOps.

Counter-Strike 2 ships a native 64-bit Linux dedicated server that SteamCMD downloads
anonymously (Steam appid 730), runs fully headless (no X display), and needs no Wine.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=cs2 \
  -e CS2_HOSTNAME="BipOps Counter-Strike 2 Server" \
  -e CS2_RCON_PASSWORD=youradminpassword \
  -e CS2_MAP=de_dust2 \
  -p 27015:27015/udp \
  -p 27015:27015/tcp \
  -v /path/to/gameservers/cs2/game:/game \
  -v /path/to/gameservers/cs2/backups:/backups \
  justmiles/bipops
```

To list the server publicly on the Steam server browser, obtain a Game Server Login
Token (GSLT) for app 730 from https://steamcommunity.com/dev/managegameservers and pass
it via `CS2_GSLT`. Without a token the server still runs and accepts direct connects.

## Required Ports

| Port  | Protocol | Description                                       |
| ----- | -------- | ------------------------------------------------- |
| 27015 | UDP      | Game traffic and Steam A2S query                  |
| 27015 | TCP      | RCON remote administration                        |
| 27020 | UDP      | GOTV / SourceTV relay (only when `CS2_TV_PORT` set) |

The UDP port is set by `CS2_PORT` (default 27015); map the same value on the host.

## Volume Mounts

| Host Path                         | Container Path | Description            |
| --------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/cs2/game     | /game          | Game files directory   |
| /path/to/gameservers/cs2/backups  | /backups       | Backup files directory |

## Game Modes

CS2 selects its mode from the `game_type` / `game_mode` pair. Set `CS2_GAME_TYPE` and
`CS2_GAME_MODE` together:

| `CS2_GAME_TYPE` | `CS2_GAME_MODE` | Mode              |
| --------------- | --------------- | ----------------- |
| 0               | 0               | Casual            |
| 0               | 1               | Competitive (default) |
| 0               | 2               | Wingman (2v2)     |
| 1               | 0               | Arms Race         |
| 1               | 1               | Demolition        |
| 1               | 2               | Deathmatch        |
| 2               | 0               | Custom            |

## Environment Variables

| Variable                   | Default                           | Description                                                                 |
| -------------------------- | --------------------------------- | --------------------------------------------------------------------------- |
| CS2_HOSTNAME               | "BipOps Counter-Strike 2 Server"  | Server name shown in the browser                                            |
| CS2_RCON_PASSWORD          | ""                                | RCON administration password. Blank disables remote console                 |
| CS2_PASSWORD               | ""                                | Password required to join. Blank = public server                            |
| CS2_PORT                   | 27015                             | UDP game/query port (command line `-port`)                                  |
| CS2_MAP                    | de_dust2                          | Map to load on startup                                                       |
| CS2_MAPGROUP               | mg_active                         | Map group / rotation                                                        |
| CS2_GAME_TYPE              | 0                                 | Game type (see Game Modes table)                                            |
| CS2_GAME_MODE              | 1                                 | Game mode (see Game Modes table)                                            |
| CS2_MAXPLAYERS             | 10                                | Visible player slots (`+sv_visiblemaxplayers`)                              |
| CS2_GSLT                   | ""                                | Game Server Login Token; required only to list the server publicly          |
| CS2_LAN                    | 0                                 | 1 = LAN only, 0 = internet-reachable                                        |
| CS2_CHEATS                 | 0                                 | Enable `sv_cheats` (0 = off)                                                |
| CS2_HIBERNATE_WHEN_EMPTY   | 1                                 | Hibernate (low CPU) while no players are connected                          |
| CS2_AUTOTEAMBALANCE        | 1                                 | Auto-balance teams                                                          |
| CS2_LIMITTEAMS             | 2                                 | Max team size difference before balancing                                  |
| CS2_MAXROUNDS              | 24                                | Rounds per match (`mp_maxrounds`)                                          |
| CS2_FRIENDLYFIRE           | 1                                 | Enable friendly fire                                                        |
| CS2_ROUNDTIME              | 1.92                              | Round length in minutes (`mp_roundtime`)                                   |
| CS2_FREEZETIME             | 15                                | Freeze time at round start (seconds)                                       |
| CS2_BOT_QUOTA              | 0                                 | Number of bots to fill the server with                                     |
| CS2_TV_PORT                | ""                                | GOTV relay UDP port. Unset = GOTV disabled                                 |
| CS2_TV_DELAY               | 30                                | GOTV broadcast delay (seconds)                                             |
| CS2_TV_NAME                | "BipOps GOTV"                     | GOTV bot display name                                                       |

## Server Administration

Set `CS2_RCON_PASSWORD` and connect with any Source RCON client to the TCP port (default
27015). Useful commands:

- `changelevel <map>` - switch map
- `mp_restartgame 1` - restart the current match
- `bot_add` / `bot_kick` - manage bots
- `status` - list connected players and their SteamIDs
- `kick <name>` / `banid <minutes> <userid>` - moderation

## Notes

- The server config template renders to `/game/game/csgo/cfg/server.cfg` and is executed
  on map load. Edit values through the `CS2_*` environment variables above.
- CS2 locates `steamclient.so` under `~/.steam/sdk64/`; `start.sh` symlinks the SteamCMD
  copy there automatically so Steamworks initializes headless.
- VAC secure mode is managed by Valve and does not require configuration here.
