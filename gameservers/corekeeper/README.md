# Core Keeper Server

This directory contains the configuration and scripts for running a Core Keeper
dedicated server using BipOps.

Core Keeper ships a native 64-bit Linux dedicated server that SteamCMD downloads
anonymously (server appid 1963720). It is a Unity server: part of its procedural
world generation runs on the GPU, so it needs a virtual X display even headless.
BipOps brings up Xvfb automatically (`usex: true`) and launches the server binary
under it with `-batchmode` (never `-nographics`). No Wine is involved.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=corekeeper \
  -e COREKEEPER_SERVER_NAME="BipOps Core Keeper Server" \
  -e COREKEEPER_MAX_PLAYERS=8 \
  -e COREKEEPER_WORLD_MODE=0 \
  -p 27015:27015/udp \
  -p 27016:27016/udp \
  -v /path/to/gameservers/corekeeper/game:/game \
  -v /path/to/gameservers/corekeeper/backups:/backups \
  justmiles/bipops
```

By default the server runs in direct-connect mode on UDP 27015 (and uses 27016 for
Steam query), so players connect with the host's public IP and port. Share the
in-game **Game ID** shown in the server log with friends, or set a fixed one via
`COREKEEPER_GAME_ID` so it survives restarts.

## Required Ports

| Port  | Protocol | Description                                         |
| ----- | -------- | --------------------------------------------------- |
| 27015 | UDP      | Game traffic (direct connect), set by `COREKEEPER_PORT` |
| 27016 | UDP      | Steam query / relay (port + 1)                      |

Core Keeper reserves the port given by `-port` plus the next port above it, so both
27015/udp and 27016/udp must be reachable. Map the same values on the host.

## Volume Mounts

| Host Path                              | Container Path | Description            |
| -------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/corekeeper/game   | /game          | Game files directory   |
| /path/to/gameservers/corekeeper/backups| /backups       | Backup files directory |

Worlds and the rendered `ServerConfig.json` live under
`/game/.config/unity3d/Pugstorm/Core Keeper/DedicatedServer`, which is the backup
source.

## World Modes

Set `COREKEEPER_WORLD_MODE` to pick the ruleset:

| Value | Mode     |
| ----- | -------- |
| 0     | Normal (default) |
| 1     | Hard     |
| 2     | Creative |
| 4     | Casual   |

## Environment Variables

| Variable                    | Default                      | Description                                                        |
| --------------------------- | ---------------------------- | ------------------------------------------------------------------ |
| `COREKEEPER_SERVER_NAME`    | `BipOps Core Keeper Server`  | World / server name shown to players                               |
| `COREKEEPER_MAX_PLAYERS`    | `8`                          | Maximum number of players allowed to connect                      |
| `COREKEEPER_WORLD_MODE`     | `0`                          | Ruleset: 0 Normal, 1 Hard, 2 Creative, 4 Casual                   |
| `COREKEEPER_WORLD_SEED`     | `0`                          | World generation seed (`0` = random; changing it generates a new world) |
| `COREKEEPER_WORLD_INDEX`    | `0`                          | World save slot index (0-29)                                      |
| `COREKEEPER_SEASON`         | `-1`                         | Seasonal event override (`-1` = automatic/current)                |
| `COREKEEPER_GAME_ID`        | _(empty)_                    | Fixed in-game Game ID; leave empty to auto-generate per world     |
| `COREKEEPER_PORT`           | `27015`                      | UDP game port (enables direct connect; also reserves `port + 1`)  |

## Notes

- **X display required.** Core Keeper offloads part of world generation to the GPU
  and will not boot with `-nographics`. BipOps' `usex: true` provides the Xvfb
  display automatically; the binary is launched with `-batchmode` only.
- **Game ID.** On first boot the server prints a Game ID used for in-game direct
  joins. Set `COREKEEPER_GAME_ID` (at least 28 alphanumeric chars, excluding
  `Y y x 0 O`) to keep it stable across restarts.
- **Changing the seed** (`COREKEEPER_WORLD_SEED`) or **world index**
  (`COREKEEPER_WORLD_INDEX`) selects a different world; it does not edit an existing
  one.
- **Max players.** The game supports large lobbies, but 2-8 is recommended; higher
  counts increase mob-spawning and tile-update load.
