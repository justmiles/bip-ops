# Garry's Mod Server

This directory contains the configuration and scripts for running a Garry's Mod
dedicated server (SRCDS) using BipOps.

Garry's Mod ships a self-contained native 32-bit Source-engine dedicated server that
SteamCMD downloads anonymously (Steam appid 4020), runs fully headless (no X display),
and needs no Wine. The server launches through the shipped `srcds_run` wrapper, which
auto-selects the 32-bit `srcds_linux` binary and sets `LD_LIBRARY_PATH`. The i386
multilib runtime is already present in the base image.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=garrysmod \
  -e GARRYSMOD_HOSTNAME="BipOps Garry's Mod Server" \
  -e GARRYSMOD_RCON_PASSWORD=youradminpassword \
  -e GARRYSMOD_GAMEMODE=sandbox \
  -e GARRYSMOD_MAP=gm_construct \
  -e GARRYSMOD_MAXPLAYERS=16 \
  -p 27015:27015/udp \
  -p 27015:27015/tcp \
  -v /path/to/gameservers/garrysmod/game:/game \
  -v /path/to/gameservers/garrysmod/backups:/backups \
  justmiles/bipops
```

To list the server publicly on the Steam server browser (and avoid Facepunch's
unranked penalty), obtain a Game Server Login Token (GSLT) for app 4000 from
https://steamcommunity.com/dev/managegameservers and pass it via `GARRYSMOD_GSLT`.
Without a token the server still runs and accepts direct connects.

## Required Ports

| Port  | Protocol | Description                                      |
| ----- | -------- | ------------------------------------------------ |
| 27015 | UDP      | Game traffic and Steam A2S query                 |
| 27015 | TCP      | RCON remote administration                       |

The UDP game/query port is set by `GARRYSMOD_PORT` (default 27015); map the same value
on the host.

## Volume Mounts

| Host Path                              | Container Path | Description            |
| -------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/garrysmod/game    | /game          | Game files directory   |
| /path/to/gameservers/garrysmod/backups | /backups       | Backup files directory |

## Environment Variables

| Variable                      | Default                      | Description                                                        |
| ----------------------------- | ---------------------------- | ------------------------------------------------------------------ |
| GARRYSMOD_HOSTNAME            | "BipOps Garry's Mod Server"  | Server name shown in the browser                                   |
| GARRYSMOD_RCON_PASSWORD      | ""                           | RCON administration password. Blank disables remote console        |
| GARRYSMOD_PASSWORD           | ""                           | Password required to join. Blank = public server                   |
| GARRYSMOD_PORT               | 27015                        | UDP game/query port (command line `-port`)                         |
| GARRYSMOD_GAMEMODE           | sandbox                      | Startup gamemode (`+gamemode`, e.g. sandbox, darkrp, ttt, prop_hunt) |
| GARRYSMOD_MAP                | gm_construct                 | Map loaded on startup (`+map`, e.g. gm_construct, gm_flatgrass)     |
| GARRYSMOD_MAXPLAYERS         | 16                           | Advertised player slots (`+maxplayers`; startup-only, max 128)     |
| GARRYSMOD_GSLT               | ""                           | Game Server Login Token (app 4000); recommended to list publicly   |
| GARRYSMOD_WORKSHOP_COLLECTION | ""                          | Steam Workshop collection ID to auto-install addons on boot        |
| GARRYSMOD_WORKSHOP_AUTH_KEY  | ""                           | Steam Web API key for large workshop collections (`-authkey`)      |
| GARRYSMOD_LAN                | 0                            | 1 = LAN only, 0 = internet-reachable                               |
| GARRYSMOD_CHEATS             | 0                            | Enable `sv_cheats` (0 = off)                                       |
| GARRYSMOD_REGION             | 255                          | Master-server region hint (255 = world)                            |
| GARRYSMOD_MAX_PROPS          | 150                          | Max spawned props per player (`sbox_maxprops`)                     |
| GARRYSMOD_MAX_RAGDOLLS       | 15                           | Max spawned ragdolls per player (`sbox_maxragdolls`)               |
| GARRYSMOD_NOCLIP             | 1                            | Allow noclip in sandbox (`sbox_noclip`)                            |
| GARRYSMOD_GODMODE            | 0                            | Allow godmode in sandbox (`sbox_godmode`)                          |
| GARRYSMOD_ALLOWDOWNLOAD      | 1                            | Allow clients to download content (`sv_allowdownload`)            |
| GARRYSMOD_ALLOWUPLOAD        | 1                            | Allow clients to upload content (`sv_allowupload`)                |
| GARRYSMOD_DOWNLOADURL        | ""                           | Fast-download (`sv_downloadurl`) base URL for custom content       |
| GARRYSMOD_VOICE_ENABLE       | 1                            | Enable voice chat (`sv_voiceenable`)                              |
| GARRYSMOD_MINRATE            | 0                            | Minimum client network rate (`sv_minrate`, 0 = default)           |
| GARRYSMOD_MAXRATE            | 0                            | Maximum client network rate (`sv_maxrate`, 0 = default)           |

## Server Administration

Set `GARRYSMOD_RCON_PASSWORD` and connect with any Source RCON client to the TCP port
(default 27015). Useful commands:

- `changelevel <map>` - switch map
- `gamemode <name>` - change gamemode on next map (set via console/cfg)
- `status` - list connected players and their SteamIDs
- `kick <name>` / `banid <minutes> <userid>` - moderation
- `exec server.cfg` - re-apply the rendered configuration

## Notes

- The server config template renders to `/game/garrysmod/cfg/server.cfg` and is loaded
  at startup via `+servercfgfile server.cfg`. Edit values through the `GARRYSMOD_*`
  environment variables above.
- `+maxplayers`, `+gamemode`, and `+map` are startup-only settings; changing them
  requires a restart.
- Garry's Mod is a 32-bit Source server: `start.sh` symlinks the 32-bit SteamCMD
  `steamclient.so` into `~/.steam/sdk32/` so Steamworks initializes headless.
- To install Workshop addons, create a collection on the Steam Workshop and pass its ID
  via `GARRYSMOD_WORKSHOP_COLLECTION`.
- VAC secure mode is managed by Valve and does not require configuration here.
