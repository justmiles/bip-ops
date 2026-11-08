# Rust Server

This directory contains the configuration and scripts for running a Rust dedicated
server using BipOps.

Rust ships a native 64-bit Linux dedicated server that SteamCMD downloads anonymously
(Steam appid 258550) and runs fully headless (`-batchmode -nographics`) with no Wine or
X display.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=rust \
  -e RUST_SERVER_NAME="BipOps Rust Server" \
  -e RUST_RCON_PASSWORD=youradminpassword \
  -e RUST_MAX_PLAYERS=50 \
  -e RUST_WORLD_SIZE=3000 \
  -e RUST_SEED=1337 \
  -p 28015:28015/udp \
  -p 28016:28016/udp \
  -p 28016:28016/tcp \
  -v /path/to/gameservers/rust/game:/game \
  -v /path/to/gameservers/rust/backups:/backups \
  justmiles/bipops
```

First boot downloads the server (~15 GB) and procedurally generates the world from
`RUST_SEED` + `RUST_WORLD_SIZE`, which can take several minutes. Changing the seed or
world size regenerates (wipes) the map.

## Required Ports

| Port  | Protocol | Description                               |
| ----- | -------- | ----------------------------------------- |
| 28015 | UDP      | Game traffic (`server.port`)              |
| 28016 | UDP      | Steam A2S query (`server.queryport`)      |
| 28016 | TCP      | RCON web console (`rcon.port`)            |
| 28082 | TCP      | Rust+ companion app API (`app.port`)      |

## Volume Mounts

| Host Path                          | Container Path | Description            |
| ---------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/rust/game     | /game          | Game files directory   |
| /path/to/gameservers/rust/backups  | /backups       | Backup files directory |

Save data and config live under `/game/server/bipops/` (the fixed server identity),
which is what BipOps backs up.

## Environment Variables

| Variable                  | Default                             | Description                                                        |
| ------------------------- | ----------------------------------- | ------------------------------------------------------------------ |
| RUST_SERVER_NAME          | "BipOps Rust Server"                | Server name shown in the browser (`server.hostname`)               |
| RUST_SERVER_DESCRIPTION   | "A Rust server hosted with BipOps"  | Server description (`server.description`)                           |
| RUST_SERVER_URL           | ""                                  | Website link shown in the browser (`server.url`)                   |
| RUST_SERVER_HEADER_IMAGE  | ""                                  | Banner image URL, 512x256 (`server.headerimage`)                   |
| RUST_SERVER_TAGS          | "monthly vanilla"                   | Space-separated server browser tags (`server.tags`)               |
| RUST_MAX_PLAYERS          | 50                                  | Maximum player slots (`server.maxplayers`)                         |
| RUST_SEED                 | 1337                                | World generation seed (`server.seed`)                              |
| RUST_WORLD_SIZE           | 3000                                | World size, 1000-6000 (`server.worldsize`)                         |
| RUST_SAVE_INTERVAL        | 600                                 | Seconds between world saves (`server.saveinterval`)                |
| RUST_PVE                  | false                               | PvE mode; true disables player-vs-player damage (`server.pve`)     |
| RUST_SERVER_PORT          | 28015                               | UDP game port (`server.port`)                                      |
| RUST_QUERY_PORT           | 28016                               | UDP Steam query port (`server.queryport`)                          |
| RUST_RCON_PORT            | 28016                               | TCP RCON web port (`rcon.port`)                                     |
| RUST_RCON_PASSWORD        | ""                                  | RCON admin password; required to use RCON (`rcon.password`)        |
| RUST_APP_PORT             | 28082                               | TCP Rust+ companion app port (`app.port`)                          |

## Server Administration

Rust exposes a WebSocket RCON console on `rcon.port` (TCP, default 28016). Set
`RUST_RCON_PASSWORD` and connect with any Rust RCON client (e.g. RustAdmin or the
in-browser `rcon.facepunch.com`) using `ws://<host>:28016/<password>`.

Common console commands:

- `say <message>` - broadcast a chat message
- `serverinfo` - show server state and player count
- `playerlist` - list connected players
- `kick "<name>"` / `ban "<name>"` - moderation
- `server.writecfg` - persist current convars
- `quit` - save and shut down

## Notes

- The server identity is fixed to `bipops`; the rendered `server.cfg` and all save
  data live at `/game/server/bipops/`. Rust auto-executes that `cfg/server.cfg` at
  startup, which is where the presentation/gameplay convars above are applied.
- Networking, world-generation, and RCON convars are passed on the command line in
  `start.sh` because they must bind before `server.cfg` runs.
