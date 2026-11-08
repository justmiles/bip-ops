# Valheim Server

This directory contains the configuration and scripts for running a Valheim dedicated
server using BipOps.

Valheim ships a native 64-bit Linux dedicated server (`valheim_server.x86_64`) that
SteamCMD downloads anonymously (server install appid 896660) and runs fully headless
(`-nographics -batchmode`) with no Wine or X display. The binary must report itself as
the game app (892970) via `SteamAppId`, and loads its bundled runtime from `./linux64`.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=valheim \
  -e VALHEIM_SERVER_NAME="BipOps Valheim Server" \
  -e VALHEIM_WORLD="Dedicated" \
  -e VALHEIM_PASSWORD="change-me" \
  -e VALHEIM_PUBLIC=1 \
  -p 2456:2456/udp \
  -p 2457:2457/udp \
  -v /path/to/gameservers/valheim/game:/game \
  -v /path/to/gameservers/valheim/backups:/backups \
  justmiles/bipops
```

First boot downloads the server (~2 GB) and generates the world named by
`VALHEIM_WORLD`, which can take a minute or two. A world is created once and then
reused; changing `VALHEIM_WORLD` starts (or loads) a different world rather than
wiping the existing one.

> **Password rule:** `VALHEIM_PASSWORD` must be at least 5 characters and must **not**
> appear anywhere inside `VALHEIM_SERVER_NAME`, or the server exits immediately at boot.

## Required Ports

| Port | Protocol | Description                                         |
| ---- | -------- | --------------------------------------------------- |
| 2456 | UDP      | Game traffic (`-port`)                              |
| 2457 | UDP      | Steam A2S query (`-port` + 1, derived automatically) |

Crossplay is **off by default** so the server binds a raw UDP socket on 2456 for direct
Steam connects to the server's public IP. Set `VALHEIM_CROSSPLAY=true` to instead route
console and PC players through the PlayFab relay (note: with the relay enabled the server
does not listen on 2456 directly).

## Volume Mounts

| Host Path                             | Container Path | Description            |
| ------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/valheim/game     | /game          | Game files directory   |
| /path/to/gameservers/valheim/backups  | /backups       | Backup files directory |

World saves and characters live under `/game/saves/` (pinned via `-savedir`), which is
what BipOps backs up.

## Environment Variables

| Variable               | Default                  | Description                                                              |
| ---------------------- | ------------------------ | ------------------------------------------------------------------------ |
| VALHEIM_SERVER_NAME    | "BipOps Valheim Server"  | Server name shown in the browser (`-name`)                               |
| VALHEIM_WORLD          | "Dedicated"              | World save name; created on first boot, reused after (`-world`)          |
| VALHEIM_PASSWORD       | "valheim"                | Join password; >= 5 chars and not contained in the server name (`-password`) |
| VALHEIM_PUBLIC         | 1                        | 1 = listed in community browser, 0 = joinable by address only (`-public`) |
| VALHEIM_CROSSPLAY      | false                    | Route players through the PlayFab relay instead of direct connect (`-crossplay`); off = direct Steam connect, binds UDP 2456 |
| VALHEIM_PORT           | 2456                     | UDP game port; query port is this + 1 (`-port`)                          |
| VALHEIM_PRESET         | "" (normal)              | World preset: casual, easy, normal, hard, hardcore, immersive, hammer (`-preset`) |
| VALHEIM_COMBAT         | "" (normal)              | Combat difficulty: veryeasy, easy, hard, veryhard (`-modifier Combat`)   |
| VALHEIM_DEATH_PENALTY  | "" (normal)              | Death penalty: casual, veryeasy, easy, hard, hardcore (`-modifier DeathPenalty`) |
| VALHEIM_RESOURCES      | "" (normal)              | Resource rate: muchless, less, more, muchmore, most (`-modifier Resources`) |
| VALHEIM_RAIDS          | "" (normal)              | Raid frequency: none, muchless, less, more, muchmore (`-modifier Raids`) |
| VALHEIM_PORTALS        | "" (normal)              | Portal rules: casual, hard, veryhard (`-modifier Portals`)               |

Modifier/preset variables default to empty, which leaves the game's own normal
balance in place. A `VALHEIM_PRESET` of `normal` is treated the same as empty. When
both a preset and individual modifiers are set, the modifiers override the preset.

## Server Administration

Valheim has no RCON. Administration is done via an admin list of Steam ID64s. On first
boot the server creates `adminlist.txt`, `permittedlist.txt`, and `bannedlist.txt`
under the server config directory; add Steam ID64s (one per line) to grant admin,
whitelist, or ban players, then restart the server to apply.

In-game, admins can open the console (F5) and use commands such as `kick <name>`,
`ban <name>`, `save`, and `ping`.

## Notes

- `SteamAppId=892970` is exported in `start.sh` because the server install app is
  896660 but the binary identifies as the game app; without it the server will not start.
- `LD_LIBRARY_PATH` includes `/game/linux64` so the binary finds its bundled libs, and
  `steamclient.so` is symlinked into `~/.steam/sdk64/` for headless Steamworks init.
- Networking and world/difficulty options are passed on the command line in `start.sh`;
  there is no file-based config template for this game.
