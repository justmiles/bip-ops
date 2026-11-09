# Arma Reforger Server

This directory contains the configuration and scripts for running an Arma Reforger
dedicated server using BipOps.

Arma Reforger ships a native 64-bit Linux dedicated server that SteamCMD downloads
anonymously (Steam appid 1874900) and runs fully headless with no Wine or X display.
The server is driven by a single JSON config file (`/game/config/server.json`) that
BipOps renders from the environment variables below.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=armareforger \
  -e ARMAREFORGER_SERVER_NAME="BipOps Arma Reforger Server" \
  -e ARMAREFORGER_MAX_PLAYERS=64 \
  -e ARMAREFORGER_SCENARIO_ID="{ECC61978EDCC2B5A}Missions/23_Campaign.conf" \
  -e ARMAREFORGER_ADMIN_PASSWORD=youradminpassword \
  -p 2001:2001/udp \
  -p 17777:17777/udp \
  -v /path/to/gameservers/armareforger/game:/game \
  -v /path/to/gameservers/armareforger/backups:/backups \
  justmiles/bipops
```

First boot downloads the server (a large multi-GB download) before it starts
listening. An empty Conflict Everon session uses roughly 3 GB of RAM; larger
scenarios and player counts need more.

## Required Ports

| Port  | Protocol | Description                                               |
| ----- | -------- | --------------------------------------------------------- |
| 2001  | UDP      | Game traffic (`bindPort` / `publicPort`)                  |
| 17777 | UDP      | Steam A2S query (`a2s.port`, lists the server in browser) |
| 19999 | UDP      | RCON remote console (`rcon.port`, only when a password set)|

## Volume Mounts

| Host Path                                 | Container Path | Description            |
| ----------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/armareforger/game    | /game          | Game files directory   |
| /path/to/gameservers/armareforger/backups | /backups       | Backup files directory |

The rendered config and the server profile (logs, crash reports, session saves)
live under `/game/config/server.json` and `/game/profile/`, which is what BipOps
backs up.

## Environment Variables

| Variable                           | Default                                       | Description                                                            |
| ---------------------------------- | --------------------------------------------- | ---------------------------------------------------------------------- |
| ARMAREFORGER_SERVER_NAME           | "BipOps Arma Reforger Server"                 | Server name shown in the browser (`game.name`)                         |
| ARMAREFORGER_MAX_PLAYERS           | 64                                            | Maximum player slots, 1-128 (`game.maxPlayers`)                        |
| ARMAREFORGER_SCENARIO_ID           | {ECC61978EDCC2B5A}Missions/23_Campaign.conf   | Scenario loaded on boot (`game.scenarioId`)                            |
| ARMAREFORGER_PASSWORD              | ""                                            | Password required to join, empty = public (`game.password`)            |
| ARMAREFORGER_ADMIN_PASSWORD        | ""                                            | In-game admin password (`game.passwordAdmin`)                          |
| ARMAREFORGER_VISIBLE               | true                                          | List the server in the public browser (`game.visible`)                 |
| ARMAREFORGER_CROSS_PLATFORM        | true                                          | Allow PC/Xbox/PlayStation crossplay (`game.crossPlatform`)             |
| ARMAREFORGER_BATTLEYE              | true                                          | Enable BattlEye anti-cheat (`gameProperties.battlEye`)                 |
| ARMAREFORGER_DISABLE_THIRD_PERSON  | false                                         | Force first-person only (`gameProperties.disableThirdPerson`)          |
| ARMAREFORGER_MAX_VIEW_DISTANCE     | 1600                                          | Server view distance in meters (`serverMaxViewDistance`)               |
| ARMAREFORGER_NETWORK_VIEW_DISTANCE | 1500                                          | Network replication view distance (`networkViewDistance`)              |
| ARMAREFORGER_MIN_GRASS_DISTANCE    | 50                                            | Minimum grass render distance (`serverMinGrassDistance`)               |
| ARMAREFORGER_VON_CROSS_FACTION     | false                                         | Allow VON voice across factions (`VONCanTransmitCrossFaction`)         |
| ARMAREFORGER_FAST_VALIDATION       | true                                          | Fast client validation (`gameProperties.fastValidation`)              |
| ARMAREFORGER_GAME_PORT             | 2001                                          | UDP game port (`bindPort`)                                             |
| ARMAREFORGER_QUERY_PORT            | 17777                                         | UDP Steam A2S query port (`a2s.port`)                                  |
| ARMAREFORGER_RCON_PASSWORD         | ""                                            | RCON password, 3+ chars no spaces; empty disables RCON (`rcon.password`)|
| ARMAREFORGER_RCON_PORT             | 19999                                         | UDP RCON port (`rcon.port`)                                            |
| ARMAREFORGER_RCON_PERMISSION       | admin                                         | RCON permission level: `admin` or `monitor` (`rcon.permission`)        |
| ARMAREFORGER_RCON_MAX_CLIENTS      | 16                                            | Max simultaneous RCON clients, 1-16 (`rcon.maxClients`)                |
| ARMAREFORGER_MAX_FPS               | 60                                            | Server frame-rate cap, `-maxFPS` (stops CPU pinning)                   |
| ARMAREFORGER_LOG_STATS             | 60000                                         | Milliseconds between FPS/perf log lines, `-logStats`                   |
| ARMAREFORGER_LOG_LEVEL             | normal                                        | Log verbosity, `-logLevel` (normal, warning, error)                    |
| ARMAREFORGER_AI_LIMIT              | ""                                            | Cap total AI agents, `-aiLimit` (unset = scenario default)             |

## Server Administration

Arma Reforger exposes an RCON console over UDP (BattlEye RCON protocol) on
`rcon.port` (default 19999). Set `ARMAREFORGER_RCON_PASSWORD` (3+ characters, no
spaces) to enable it; the `rcon` block is omitted from the config entirely when no
password is set. Connect with any BattlEye RCON client.

`ARMAREFORGER_ADMIN_PASSWORD` is separate: it grants in-game admin (the `#login`
command) to connected players.

## Notes

- The dedicated server installs via SteamCMD appid `1874900` (anonymous). The
  `1874880` store appid is only used for library/capsule art, not the server.
- The default scenario is Conflict on Everon
  (`{ECC61978EDCC2B5A}Missions/23_Campaign.conf`). Copy any custom `scenarioId`
  exactly; a single wrong character makes the server fail to load the scenario.
  Use `-listScenarios` to print the installed scenario IDs.
- Networking and performance flags (`-maxFPS`, `-logStats`, `-aiLimit`) are passed
  on the command line in `start.sh`; gameplay/world settings live in the rendered
  `server.json`.
- Crossplay requires BattlEye to be enabled; console players cannot join a
  BattlEye-disabled server.
