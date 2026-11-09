# Half-Life 2: Deathmatch Server

This directory contains the configuration and scripts for running a Half-Life 2: Deathmatch
dedicated server (SRCDS) using BipOps.

Half-Life 2: Deathmatch ships a native **32-bit** Linux dedicated server that SteamCMD
downloads anonymously (Steam appid 232370), runs fully headless (no X display), and needs
no Wine. The BipOps base image enables i386 multilib so the 32-bit `srcds_linux` binary runs.
The game/mod directory is `hl2mp`.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=hl2dm \
  -e HL2DM_HOSTNAME="BipOps Half-Life 2: Deathmatch Server" \
  -e HL2DM_RCON_PASSWORD=youradminpassword \
  -e HL2DM_MAP=dm_lockdown \
  -p 27015:27015/udp \
  -p 27015:27015/tcp \
  -v /path/to/gameservers/hl2dm/game:/game \
  -v /path/to/gameservers/hl2dm/backups:/backups \
  justmiles/bipops
```

To list the server publicly on the Steam server browser, obtain a Game Server Login
Token (GSLT) for app 320 from https://steamcommunity.com/dev/managegameservers and pass
it via `HL2DM_GSLT`. Without a token the server still runs and accepts direct connects.

## Required Ports

| Port  | Protocol | Description                                         |
| ----- | -------- | --------------------------------------------------- |
| 27015 | UDP      | Game traffic and Steam A2S query (same port)        |
| 27015 | TCP      | RCON remote administration                          |
| 27020 | UDP      | SourceTV relay (only when `HL2DM_TV_PORT` set)      |

The UDP port is set by `HL2DM_PORT` (default 27015); map the same value on the host. The
Steam query shares the game UDP port with no offset, and RCON is TCP on the same number.

## Volume Mounts

| Host Path                            | Container Path | Description            |
| ------------------------------------ | -------------- | ---------------------- |
| /path/to/gameservers/hl2dm/game      | /game          | Game files directory   |
| /path/to/gameservers/hl2dm/backups   | /backups       | Backup files directory |

## Environment Variables

| Variable             | Default                                   | Description                                                         |
| -------------------- | ----------------------------------------- | ------------------------------------------------------------------- |
| HL2DM_HOSTNAME       | "BipOps Half-Life 2: Deathmatch Server"   | Server name shown in the browser                                   |
| HL2DM_RCON_PASSWORD  | ""                                        | RCON administration password. Blank disables remote console        |
| HL2DM_PASSWORD       | ""                                        | Password required to join. Blank = public server                   |
| HL2DM_PORT           | 27015                                     | UDP game/query port (command line `-port`)                         |
| HL2DM_MAP            | dm_lockdown                               | Map to load on startup                                             |
| HL2DM_MAXPLAYERS     | 16                                        | Player slots (`-maxplayers`)                                       |
| HL2DM_GSLT           | ""                                        | Game Server Login Token; required only to list the server publicly |
| HL2DM_LAN            | 0                                         | 1 = LAN only, 0 = internet-reachable                               |
| HL2DM_CHEATS         | 0                                         | Enable `sv_cheats` (0 = off)                                       |
| HL2DM_ALLTALK        | 0                                         | Let all players hear each other on voice                          |
| HL2DM_REGION         | 255                                       | Server browser region hint (255 = world)                          |
| HL2DM_TIMELIMIT      | 0                                         | Minutes before the map changes (`mp_timelimit`, 0 = no limit)     |
| HL2DM_FRAGLIMIT      | 0                                         | Frags to end the map (`mp_fraglimit`, 0 = unlimited)              |
| HL2DM_TEAMPLAY       | 0                                         | 1 = team deathmatch, 0 = free-for-all (`mp_teamplay`)            |
| HL2DM_FRIENDLYFIRE   | 0                                         | Enable friendly fire (team mode)                                  |
| HL2DM_FALLDAMAGE     | 0                                         | Enable fall damage (`mp_falldamage`)                             |
| HL2DM_FLASHLIGHT     | 1                                         | Allow player flashlight (`mp_flashlight`)                        |
| HL2DM_FORCERESPAWN   | 1                                         | Auto-respawn dead players (`mp_forcerespawn`)                    |
| HL2DM_WEAPONSTAY     | 0                                         | Weapons remain after pickup (`mp_weaponstay`)                    |
| HL2DM_MEGA_PHYSCANNON| 0                                         | Super gravity gun (`physcannon_mega_enabled`)                    |
| HL2DM_DOWNLOADURL    | ""                                        | `sv_downloadurl` base URL for custom-content fast downloads      |
| HL2DM_TV_PORT        | ""                                        | SourceTV relay UDP port. Unset = SourceTV disabled               |
| HL2DM_TV_DELAY       | 30                                        | SourceTV broadcast delay (seconds)                               |
| HL2DM_TV_NAME        | "BipOps SourceTV"                         | SourceTV bot display name                                        |

## Maps

Half-Life 2: Deathmatch ships with several stock maps:

- `dm_lockdown` (default)
- `dm_overwatch`
- `dm_powerhouse`
- `dm_resistance`
- `dm_runoff`
- `dm_steamlab`
- `dm_underpass`

## Server Administration

Set `HL2DM_RCON_PASSWORD` and connect with any Source RCON client to the TCP port (default
27015). Useful commands:

- `changelevel <map>` - switch map
- `mp_restartgame 1` - restart the current round
- `status` - list connected players and their SteamIDs
- `kick <name>` / `banid <minutes> <userid>` - moderation

## Notes

- The server config template renders to `/game/hl2mp/cfg/server.cfg` and is executed
  on startup via `+servercfgfile server.cfg`. Edit values through the `HL2DM_*` environment
  variables above.
- HL2:DM is a 32-bit Source engine server; `start.sh` symlinks the 32-bit SteamCMD
  `steamclient.so` into `~/.steam/sdk32/` so Steamworks initializes headless.
- The dedicated-server download (appid 232370) ships only the classic 32-bit `srcds_linux`
  binary; the newer 64-bit server binaries are not part of the anonymous download, so BipOps
  runs the proven 32-bit build via i386 multilib.
- VAC secure mode is managed by Valve and does not require configuration here.
