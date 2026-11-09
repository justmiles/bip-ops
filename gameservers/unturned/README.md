# Unturned Server

This directory contains the configuration and scripts for running an Unturned
dedicated server (U3DS) using BipOps.

Unturned ships a native 64-bit Linux headless dedicated server that SteamCMD downloads
anonymously (Steam appid 1110390) and runs fully headless (`Unturned_Headless.x86_64
-batchmode -nographics`) with no Wine or X display. It is free and anonymous to run.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=unturned \
  -e UNTURNED_SERVER_NAME="BipOps Unturned Server" \
  -e UNTURNED_MAP="PEI" \
  -e UNTURNED_MAX_PLAYERS=24 \
  -e UNTURNED_PERSPECTIVE="Both" \
  -e UNTURNED_MODE="Normal" \
  -p 27015:27015/udp \
  -p 27016:27016/udp \
  -v /path/to/gameservers/unturned/game:/game \
  -v /path/to/gameservers/unturned/backups:/backups \
  justmiles/bipops
```

First boot downloads the server, then generates the save under
`/game/Servers/bipops/` from the configured map. To appear in the in-game internet
server list, set a Steam Game Server Login Token via `UNTURNED_GSLT` (create one at
https://steamcommunity.com/dev/managegameservers for app 304930).

## Required Ports

| Port  | Protocol | Description                                    |
| ----- | -------- | ---------------------------------------------- |
| 27015 | UDP      | Game traffic (`Port`)                          |
| 27016 | UDP      | Steam A2S query (game port + 1, implicit)      |

Unturned always binds the Steam query port at `game port + 1`; it is derived
automatically from `UNTURNED_PORT` and cannot be set separately. If you change
`UNTURNED_PORT`, publish `UNTURNED_PORT` and `UNTURNED_PORT + 1` (both UDP).

## Volume Mounts

| Host Path                             | Container Path | Description            |
| ------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/unturned/game    | /game          | Game files directory   |
| /path/to/gameservers/unturned/backups | /backups       | Backup files directory |

Save data and config live under `/game/Servers/bipops/` (the fixed server
identity), which is what BipOps backs up. The rendered `Commands.dat` and
`Config.json` land in `/game/Servers/bipops/Server/`.

## Environment Variables

| Variable                   | Default                              | Description                                                           |
| -------------------------- | ------------------------------------ | -------------------------------------------------------------------- |
| UNTURNED_SERVER_NAME       | "BipOps Unturned Server"             | Server name shown in the browser (`Name`)                            |
| UNTURNED_DESCRIPTION       | "An Unturned server hosted with BipOps" | Server description (Config.json `Browser.Desc_*`)                 |
| UNTURNED_MAP               | "PEI"                                | Map to load, e.g. PEI, Washington, Russia, Yukon, Germany, Greece (`Map`) |
| UNTURNED_MAX_PLAYERS       | 24                                   | Maximum player slots (`MaxPlayers`)                                  |
| UNTURNED_PERSPECTIVE       | "Both"                               | Camera perspective: First, Third, Both, or Vehicle (`Perspective`)  |
| UNTURNED_MODE              | "Normal"                             | Difficulty mode: Easy, Normal, or Hard (`Mode`)                     |
| UNTURNED_PVP               | true                                 | Enable player-vs-player combat (Config.json `Gameplay.PvP`)         |
| UNTURNED_PVE               | false                                | Shorthand for a PvE server; true emits the `PvE` command            |
| UNTURNED_PASSWORD          | ""                                   | Join password; empty disables it (`Password`)                       |
| UNTURNED_CHEATS            | false                                | Enable the `Cheats` command for admins                              |
| UNTURNED_OWNER             | ""                                   | SteamID64 of the server owner/admin (`Owner`)                       |
| UNTURNED_PORT              | 27015                                | UDP game port (`Port`); query port is this + 1                      |
| UNTURNED_GSLT              | ""                                   | Steam Game Server Login Token for internet server list visibility   |
| UNTURNED_VAC_SECURE        | true                                 | Enable VAC anti-cheat (Config.json `Server.VAC_Secure`)             |
| UNTURNED_BATTLEYE_SECURE   | true                                 | Enable BattlEye anti-cheat (Config.json `Server.BattlEye_Secure`)   |
| UNTURNED_MAX_PING_MS       | 1000                                 | Max player ping in ms before kick (Config.json `Max_Ping_Milliseconds`) |
| UNTURNED_TIMER_HOME        | 5                                    | Seconds to channel the /home teleport (Config.json `Timer_Home`)    |
| UNTURNED_TIMER_RESPAWN     | 5                                    | Seconds before respawn is allowed (Config.json `Timer_Respawn`)     |
| UNTURNED_BROWSER_ICON      | ""                                   | URL of a server browser icon (Config.json `Browser.Icon`)           |
| UNTURNED_BROWSER_THUMBNAIL | ""                                   | URL of a server browser thumbnail (Config.json `Browser.Thumbnail`) |

## Server Administration

Unturned reads admin commands at boot from `Servers/bipops/Server/Commands.dat` and
game rules from `Servers/bipops/Server/Config.json` (both rendered by BipOps from the
`UNTURNED_*` env vars above). Operators are granted via `UNTURNED_OWNER` (SteamID64).

Live administration is done from the server console (when attached) or in-game by an
admin using chat commands such as:

- `/admin <player>` - grant admin to a connected player
- `/kick <player>` / `/ban <player>` - moderation
- `/save` - force a world save
- `/shutdown` - save and stop the server
- `/experience <player> <amount>` - grant experience

## Notes

- The server identity is fixed to `bipops`; the rendered `Commands.dat`/`Config.json`
  and all save data live at `/game/Servers/bipops/`.
- The Steam query port is always the game port + 1 and is not configurable on its own;
  always publish both `UNTURNED_PORT` and `UNTURNED_PORT + 1` (UDP).
- `UNTURNED_GSLT` is optional for LAN/direct-connect play but required to be listed in
  the in-game internet server browser.
- Workshop mods are not wired up here; add a `WorkshopDownloadConfig.json` if needed.
