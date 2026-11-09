# Half-Life Deathmatch: Source Server

This directory contains the configuration and scripts for running a
Half-Life Deathmatch: Source dedicated server (SRCDS) using BipOps.

Half-Life Deathmatch: Source is the Source-engine remake of the original Half-Life
multiplayer. It ships a native **32-bit** Linux dedicated server that SteamCMD
downloads anonymously (Steam appid 255470), runs fully headless (no X display),
and needs no Wine. The BipOps base image enables i386 multilib so the 32-bit
binaries run. The server mod directory is `hl1mp` and it is launched through the
shipped `srcds_run` wrapper.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=hldms \
  -e HLDMS_HOSTNAME="BipOps Half-Life Deathmatch Source Server" \
  -e HLDMS_RCON_PASSWORD=youradminpassword \
  -e HLDMS_MAP=crossfire \
  -p 27015:27015/udp \
  -p 27015:27015/tcp \
  -v /path/to/gameservers/hldms/game:/game \
  -v /path/to/gameservers/hldms/backups:/backups \
  justmiles/bipops
```

To list the server publicly on the Steam server browser, obtain a Game Server
Login Token (GSLT) from https://steamcommunity.com/dev/managegameservers and pass
it via `HLDMS_GSLT`. Without a token the server still runs and accepts direct
connects.

## Required Ports

| Port  | Protocol | Description                                         |
| ----- | -------- | --------------------------------------------------- |
| 27015 | UDP      | Game traffic and Steam A2S query                    |
| 27015 | TCP      | RCON remote administration                          |
| 27020 | UDP      | SourceTV relay (only when `HLDMS_TV_PORT` is set)   |

The UDP port is set by `HLDMS_PORT` (default 27015); map the same value on the host.

## Volume Mounts

| Host Path                           | Container Path | Description            |
| ----------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/hldms/game     | /game          | Game files directory   |
| /path/to/gameservers/hldms/backups  | /backups       | Backup files directory |

## Environment Variables

| Variable             | Default                                       | Description                                                          |
| -------------------- | --------------------------------------------- | ------------------------------------------------------------------- |
| HLDMS_HOSTNAME       | "BipOps Half-Life Deathmatch Source Server"   | Server name shown in the browser                                    |
| HLDMS_RCON_PASSWORD  | ""                                            | RCON administration password. Blank disables remote console         |
| HLDMS_PASSWORD       | ""                                            | Password required to join. Blank = public server                    |
| HLDMS_PORT           | 27015                                         | UDP game/query port (command line `-port`)                          |
| HLDMS_MAP            | crossfire                                     | Map to load on startup                                              |
| HLDMS_MAXPLAYERS     | 16                                            | Player slots (`+maxplayers`)                                        |
| HLDMS_GSLT           | ""                                            | Game Server Login Token; required only to list the server publicly  |
| HLDMS_LAN            | 0                                             | 1 = LAN only, 0 = internet-reachable                               |
| HLDMS_CHEATS         | 0                                             | Enable `sv_cheats` (0 = off)                                        |
| HLDMS_REGION         | 255                                           | Master-list region (0=US East ... 255=World)                       |
| HLDMS_TIMELIMIT      | 0                                             | Map time limit in minutes (`mp_timelimit`, 0 = unlimited)          |
| HLDMS_FRAGLIMIT      | 0                                             | Frags before map change (`mp_fraglimit`, 0 = unlimited)            |
| HLDMS_FRIENDLYFIRE   | 0                                             | Enable friendly fire (`mp_friendlyfire`)                           |
| HLDMS_FALLDAMAGE     | 0                                             | Enable fall damage (`mp_falldamage`)                               |
| HLDMS_FLASHLIGHT     | 1                                             | Allow player flashlight (`mp_flashlight`)                          |
| HLDMS_FOOTSTEPS      | 1                                             | Audible footsteps (`mp_footsteps`)                                 |
| HLDMS_FORCERESPAWN   | 1                                             | Force respawn on death (`mp_forcerespawn`)                         |
| HLDMS_WEAPONSTAY     | 0                                             | Weapons stay after pickup (`mp_weaponstay`)                        |
| HLDMS_MAXRATE        | 0                                             | Max client bandwidth bytes/sec (`sv_maxrate`, 0 = unlimited)       |
| HLDMS_MINRATE        | 0                                             | Min client bandwidth bytes/sec (`sv_minrate`)                      |
| HLDMS_TV_PORT        | ""                                            | SourceTV relay UDP port. Unset = SourceTV disabled                 |
| HLDMS_TV_DELAY       | 30                                            | SourceTV broadcast delay (seconds)                                 |
| HLDMS_TV_NAME        | "BipOps SourceTV"                             | SourceTV bot display name                                          |

## Maps

Classic Half-Life Deathmatch maps include `crossfire` (default), `datacore`,
`stalkyard`, `undertow`, `bounce`, `boot_camp`, `lambda_bunker`, `rapidcore`,
`frenzy`, `gasworks`, and `snark_pit`. Set the starting map with `HLDMS_MAP`.

## Server Administration

Set `HLDMS_RCON_PASSWORD` and connect with any Source RCON client to the TCP port
(default 27015). Useful commands:

- `changelevel <map>` - switch map
- `status` - list connected players and their SteamIDs
- `kick <name>` / `banid <minutes> <userid>` - moderation
- `mp_timelimit <minutes>` / `mp_fraglimit <frags>` - adjust match rules live

## Notes

- The server config template renders to `/game/hl1mp/cfg/server.cfg` and is executed
  on map load via `+exec server.cfg`. Edit values through the `HLDMS_*` env vars above.
- As a 32-bit Source server, HLDM:S locates `steamclient.so` under `~/.steam/sdk32/`;
  `start.sh` symlinks the SteamCMD 32-bit copy there automatically so Steamworks
  initializes headless.
- VAC secure mode is managed by Valve and does not require configuration here.
