# Hurtworld Server

This directory contains the configuration and scripts for running a Hurtworld dedicated
server using BipOps.

Hurtworld ships a native 64-bit Linux Unity dedicated server that SteamCMD downloads
anonymously (Steam appid 405100) and runs fully headless (`-batchmode -nographics`) with
no Wine or X display. Runtime settings are passed as a single semicolon-separated command
string via the game's `-exec` argument.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=hurtworld \
  -e HURTWORLD_SERVER_NAME="BipOps Hurtworld Server" \
  -e HURTWORLD_MAX_PLAYERS=50 \
  -e HURTWORLD_ADMIN_IDS="76561198084911985" \
  -p 12871:12871/udp \
  -p 12881:12881/udp \
  -v /path/to/gameservers/hurtworld/game:/game \
  -v /path/to/gameservers/hurtworld/backups:/backups \
  justmiles/bipops
```

First boot downloads the server via SteamCMD, which can take a few minutes. The world is
saved as `autosave_*.hwb` files under `/game/bipops/` (set via the `savedirectory` exec
command), which is what BipOps backs up.

## Required Ports

| Port  | Protocol | Description                                      |
| ----- | -------- | ------------------------------------------------ |
| 12871 | UDP      | Game traffic (`host`)                            |
| 12881 | UDP      | Steam A2S query / server browser (`queryport`)   |

The query port is required for the server to appear in the in-game server browser.

## Volume Mounts

| Host Path                              | Container Path | Description            |
| -------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/hurtworld/game    | /game          | Game files directory   |
| /path/to/gameservers/hurtworld/backups | /backups       | Backup files directory |

Save data lives under `/game/bipops/` (the `savedirectory`), which is what BipOps backs up.

## Environment Variables

| Variable                      | Default                     | Description                                                              |
| ----------------------------- | --------------------------- | ------------------------------------------------------------------------ |
| HURTWORLD_SERVER_NAME         | "BipOps Hurtworld Server"   | Server name shown in the server browser (`servername`)                   |
| HURTWORLD_MAX_PLAYERS         | 50                          | Maximum player slots (`maxplayers`)                                      |
| HURTWORLD_PORT                | 12871                       | UDP game port (`host`)                                                   |
| HURTWORLD_QUERY_PORT          | 12881                       | UDP Steam query port (`queryport`)                                       |
| HURTWORLD_CREATIVE_MODE       | 0                           | Creative mode: 0 = survival, 1 = creative (`creativemode`)              |
| HURTWORLD_CLAN_TAGS_ENABLED   | 1                           | Allow clan tags: 0 = off, 1 = on (`clantagsenabled`)                     |
| HURTWORLD_DIFFICULTY_LOOT     | 1                           | Global loot difficulty multiplier (`difficultygloballoot`)               |
| HURTWORLD_ANTICHEAT           | 1                           | Enable built-in anti-cheat: 0 = off, 1 = on (`antiCheat`)                |
| HURTWORLD_SAVE_INTERVAL       | 300                         | Seconds between automatic world saves (`saveevery`)                      |
| HURTWORLD_ADMIN_IDS           | ""                          | Comma-separated SteamID64s granted admin via `addadmin` (empty = none)   |

## Server Administration

Admins are granted at boot via the `addadmin <steamid64>` exec command for every ID in
`HURTWORLD_ADMIN_IDS` (comma-separated). An in-game admin can open the console (`F1`) and
issue runtime commands such as:

- `kick <player>` / `ban <player>` - moderation
- `say <message>` - broadcast a chat message
- `saveserver` - force an immediate world save
- `creativemode 1` - toggle creative mode

## Notes

- Hurtworld has no on-disk settings file the server reads; all configuration is passed on
  the command line via `-exec`. BipOps renders `config/exec.txt` (one command per line) from
  the `HURTWORLD_*` env vars, and `start.sh` collapses it into the semicolon-separated string
  the game expects.
- The `savedirectory` is fixed to `/game/bipops` so saves and config live at a known path
  that BipOps backs up. Do not change it without updating `backupdir`/`configs` in
  `.bip-ops.yaml`.
- Changing `HURTWORLD_PORT`/`HURTWORLD_QUERY_PORT` requires remapping the published Docker
  ports to match.
