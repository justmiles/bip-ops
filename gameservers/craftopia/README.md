# Craftopia Server

This directory contains the configuration and scripts for running a Craftopia dedicated
server using BipOps.

Craftopia ships a native 64-bit Linux dedicated server (a headless Unity build) that
SteamCMD downloads anonymously (dedicated-server Steam appid `1670340`; the store appid is
`1307550`). It runs fully headless (`-batchmode -nographics`) with no Wine or X display.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=craftopia \
  -e CRAFTOPIA_SERVER_NAME="BipOps Craftopia Server" \
  -e CRAFTOPIA_MAX_PLAYERS=7 \
  -e CRAFTOPIA_USE_PASSWORD=1 \
  -e CRAFTOPIA_SERVER_PASSWORD=changeme \
  -p 6587:6587/udp \
  -v /path/to/gameservers/craftopia/game:/game \
  -v /path/to/gameservers/craftopia/backups:/backups \
  justmiles/bipops
```

First boot downloads the server via SteamCMD and generates a fresh world under
`/game/DedicatedServerSave/`, which can take a few minutes.

## Required Ports

| Port | Protocol | Description                                        |
| ---- | -------- | -------------------------------------------------- |
| 6587 | UDP      | Game / direct-connect port (`[Host] port`)         |

By default `isUseSteamLobby=1`, so players discover and join the server through the Steam
lobby (friends / invite / lobby ID). The UDP port above is still used for the networking
transport and for direct connections when `CRAFTOPIA_USE_STEAM_LOBBY=0`.

## Volume Mounts

| Host Path                               | Container Path | Description            |
| --------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/craftopia/game     | /game          | Game files directory   |
| /path/to/gameservers/craftopia/backups  | /backups       | Backup files directory |

Save data lives under `/game/DedicatedServerSave/`, which is what BipOps backs up. The
rendered `ServerSetting.ini` is written to the install root at `/game/ServerSetting.ini`.

## Environment Variables

| Variable                          | Default                     | Description                                                                 |
| --------------------------------- | --------------------------- | --------------------------------------------------------------------------- |
| CRAFTOPIA_SERVER_NAME             | "BipOps Craftopia Server"   | Server name shown to players (`[GameWorld] name`)                           |
| CRAFTOPIA_MAX_PLAYERS             | 7                           | Maximum player slots, 1-127 (`[Host] maxPlayerNumber`)                      |
| CRAFTOPIA_PORT                    | 6587                        | UDP game / direct-connect port (`[Host] port`)                             |
| CRAFTOPIA_USE_STEAM_LOBBY         | 1                           | Use the Steam lobby for discovery/join; 0 = direct-connect only (`[Host] isUseSteamLobby`) |
| CRAFTOPIA_USE_PASSWORD            | 0                           | Require a password to join (`[Host] usePassword`)                          |
| CRAFTOPIA_SERVER_PASSWORD         | "00000000"                  | Join password (used when `CRAFTOPIA_USE_PASSWORD=1`) (`[Host] serverPassword`) |
| CRAFTOPIA_BIND_ADDRESS            | "0.0.0.0"                   | Address the server binds to (`[Host] bindAddress`)                         |
| CRAFTOPIA_DIFFICULTY              | 1                           | World difficulty (`[GameWorld] difficulty`)                                |
| CRAFTOPIA_GAME_MODE               | 1                           | Game mode; 0=Creative, 1=Survival (`[GameWorld] gameMode`)                 |
| CRAFTOPIA_MAX_FPS                 | 60                          | Server simulation FPS cap (`[Graphics] maxFPS`)                            |
| CRAFTOPIA_AUTOSAVE_SEC            | 300                         | Seconds between autosaves (`[Save] autoSaveSec`)                           |
| CRAFTOPIA_AUTOSAVE_PER_HOUR       | 1                           | Keep one rolling autosave per hour (`[Save] autoSavePerHour`)             |
| CRAFTOPIA_QUICK_CRAFT             | 1                           | Creative-mode quick craft (`[CreativeModeSetting] quickCraft`)           |
| CRAFTOPIA_AGE_LEVEL               | 7                           | Creative-mode age level (`[CreativeModeSetting] ageLevel`)                |
| CRAFTOPIA_ISLAND_LEVEL            | -1                          | Creative-mode island level, -1=default (`[CreativeModeSetting] islandLevel`) |
| CRAFTOPIA_NO_DEATH                | 1                           | Disable death (`[CreativeModeSetting] noDeath`)                           |
| CRAFTOPIA_NO_DAMAGE               | 1                           | Disable damage (`[CreativeModeSetting] noDamage`)                         |
| CRAFTOPIA_NO_HUNGER               | 1                           | Disable hunger (`[CreativeModeSetting] noHunger`)                         |
| CRAFTOPIA_INFINITE_STAMINA        | 1                           | Infinite stamina (`[CreativeModeSetting] infinitStamina`)                |
| CRAFTOPIA_FORCE_DAYTIME           | -1                          | Force time of day, -1=normal cycle (`[CreativeModeSetting] forceDayTime`) |
| CRAFTOPIA_BUILDING_IGNORE_DAMAGE  | 0                           | Buildings ignore damage (`[CreativeModeSetting] buildingIgnoreDamage`)   |
| CRAFTOPIA_NO_BUILD                | 0                           | Disable building (`[CreativeModeSetting] noBuild`)                        |
| CRAFTOPIA_START_MONEY             | 1000                        | Starting money for creative status (`[CreativeModePlStatus] Money`)      |

## Server Administration

Craftopia's dedicated server is configured entirely through `ServerSetting.ini`, which
BipOps renders from the `CRAFTOPIA_*` environment variables above into
`/game/ServerSetting.ini`. Change settings by restarting the container with new env
values; there is no in-game RCON console.

## Notes

- `savePath` is fixed to `DedicatedServerSave/` (relative to the install root `/game`) so
  save data lives at a known path (`/game/DedicatedServerSave/`) that BipOps backs up.
- When `isUseSteamLobby=1` (the default), players join via the Steam lobby rather than a
  server browser; share the lobby/invite in-game. Set `CRAFTOPIA_USE_STEAM_LOBBY=0` for
  direct-connect hosting on the UDP port.
- The Steam client library is symlinked into `~/.steam/sdk64/steamclient.so` at startup so
  Steamworks init succeeds on the headless host.
