# Team Fortress 2 Server

This directory contains the configuration and scripts for running a Team Fortress 2
dedicated server (SRCDS) using BipOps.

Team Fortress 2 ships a native Linux dedicated server that SteamCMD downloads
anonymously (Steam appid 232250), runs fully headless (no X display), and needs no Wine.
The server launches through the shipped `srcds_run_64` wrapper (64-bit build, released
2024), falling back to the classic 32-bit `srcds_run` if the 64-bit wrapper is absent.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=tf2 \
  -e TF2_HOSTNAME="BipOps Team Fortress 2 Server" \
  -e TF2_RCON_PASSWORD=youradminpassword \
  -e TF2_MAP=ctf_2fort \
  -e TF2_MAXPLAYERS=24 \
  -p 27015:27015/udp \
  -p 27015:27015/tcp \
  -v /path/to/gameservers/tf2/game:/game \
  -v /path/to/gameservers/tf2/backups:/backups \
  justmiles/bipops
```

To list the server publicly on the Steam server browser, obtain a Game Server Login
Token (GSLT) for app 440 from https://steamcommunity.com/dev/managegameservers and pass
it via `TF2_GSLT`. Without a token the server still runs and accepts direct connects.

## Required Ports

| Port  | Protocol | Description                                         |
| ----- | -------- | --------------------------------------------------- |
| 27015 | UDP      | Game traffic and Steam A2S query                    |
| 27015 | TCP      | RCON remote administration                          |
| 27020 | UDP      | SourceTV relay (only when `TF2_TV_PORT` is set)     |

The UDP game/query port is set by `TF2_PORT` (default 27015); map the same value on the
host.

## Volume Mounts

| Host Path                         | Container Path | Description            |
| --------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/tf2/game     | /game          | Game files directory   |
| /path/to/gameservers/tf2/backups  | /backups       | Backup files directory |

## Environment Variables

| Variable                  | Default                        | Description                                                         |
| ------------------------- | ------------------------------ | ------------------------------------------------------------------- |
| TF2_HOSTNAME              | "BipOps Team Fortress 2 Server" | Server name shown in the browser                                   |
| TF2_RCON_PASSWORD         | ""                             | RCON administration password. Blank disables remote console         |
| TF2_PASSWORD              | ""                             | Password required to join. Blank = public server                    |
| TF2_PORT                  | 27015                          | UDP game/query port (command line `-port`)                          |
| TF2_MAP                   | ctf_2fort                      | Map loaded on startup (e.g. ctf_2fort, cp_dustbowl, pl_badwater)     |
| TF2_MAXPLAYERS            | 24                             | Advertised player slots (`+maxplayers`; startup-only, max ~32)      |
| TF2_GSLT                  | ""                             | Game Server Login Token (app 440); required only to list publicly   |
| TF2_LAN                   | 0                              | 1 = LAN only, 0 = internet-reachable                                |
| TF2_CHEATS                | 0                              | Enable `sv_cheats` (0 = off)                                        |
| TF2_ALLTALK               | 0                              | 1 = both teams share voice chat (`sv_alltalk`)                      |
| TF2_REGION                | 255                            | Master-server region hint (255 = world)                             |
| TF2_TIMELIMIT             | 30                             | Map time limit in minutes (`mp_timelimit`)                          |
| TF2_WINLIMIT              | 0                              | Round wins before map change (`mp_winlimit`, 0 = off)               |
| TF2_MAXROUNDS             | 0                              | Rounds before map change (`mp_maxrounds`, 0 = off)                  |
| TF2_FRIENDLYFIRE          | 0                              | Enable friendly fire (`mp_friendlyfire`)                            |
| TF2_AUTOTEAMBALANCE       | 1                              | Auto-balance teams (`mp_autoteambalance`)                           |
| TF2_TEAMS_UNBALANCE_LIMIT | 1                              | Team size difference that triggers balancing                        |
| TF2_RESPAWNWAVETIME       | 10                             | Respawn wave interval in seconds (`mp_respawnwavetime`)             |
| TF2_DOWNLOADURL           | ""                             | Fast-download (`sv_downloadurl`) base URL for custom content        |
| TF2_TV_PORT               | ""                             | SourceTV relay UDP port. Unset = SourceTV disabled (`-nohltv`)      |
| TF2_TV_DELAY              | 30                             | SourceTV broadcast delay (seconds)                                 |
| TF2_TV_NAME               | "BipOps SourceTV"              | SourceTV bot display name                                           |

## Server Administration

Set `TF2_RCON_PASSWORD` and connect with any Source RCON client to the TCP port (default
27015). Useful commands:

- `changelevel <map>` - switch map
- `mp_restartgame 1` - restart the current round
- `status` - list connected players and their SteamIDs
- `kick <name>` / `banid <minutes> <userid>` - moderation
- `exec server.cfg` - re-apply the rendered configuration

## Notes

- The server config template renders to `/game/tf/cfg/server.cfg` and is loaded at
  startup via `+servercfgfile server.cfg`. Edit values through the `TF2_*` environment
  variables above.
- `+maxplayers` is a startup-only setting; changing `TF2_MAXPLAYERS` requires a restart.
- TF2 locates `steamclient.so` under `~/.steam/sdk64/`; `start.sh` symlinks the SteamCMD
  copy there automatically so Steamworks initializes headless.
- VAC secure mode is managed by Valve and does not require configuration here.
