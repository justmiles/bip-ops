# Fistful of Frags

[Fistful of Frags](https://store.steampowered.com/app/265630/Fistful_of_Frags/) is a free
Wild-West themed multiplayer shooter built on the Source engine. BipOps runs the native 32-bit
Linux dedicated server (SRCDS, mod directory `fof`, server appid `295230`) headless - no Wine,
no X11.

## Quickstart

```sh
docker run -d --name fof \
  -e BIPOPS_GAMESERVER=fof \
  -e FOF_HOSTNAME="My Fistful of Frags Server" \
  -e FOF_MAP=fof_depot \
  -e FOF_MAXPLAYERS=12 \
  -p 27015:27015/udp \
  -p 27015:27015/tcp \
  -v fof-game:/game \
  -v fof-backups:/backups \
  justmiles/bipops:latest
```

## Ports

| Container Port | Protocol | Purpose |
|----------------|----------|---------|
| 27015 | udp | Game traffic **and** Steam A2S query (same socket) |
| 27015 | tcp | Source RCON (only active when `FOF_RCON_PASSWORD` is set) |

The game and Steam query share the single UDP port (`-port`). Publish the same number for both
UDP and TCP.

## Volumes

| Mount | Purpose |
|-------|---------|
| `/game` | Game installation (SteamCMD installs the `fof` mod here) |
| `/backups` | rsnapshot backup storage |

BipOps backs up `/game/fof/cfg` (where the rendered `server.cfg` lives).

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `FOF_HOSTNAME` | `BipOps Fistful of Frags Server` | Server name shown in the browser |
| `FOF_PORT` | `27015` | Game + query UDP port |
| `FOF_MAXPLAYERS` | `12` | Maximum player slots |
| `FOF_MAP` | `fof_depot` | Map loaded on startup (e.g. `fof_depot`, `fof_fistful`, `fof_desperados`) |
| `FOF_PASSWORD` | _(empty)_ | Password required to join (empty = public) |
| `FOF_RCON_PASSWORD` | _(empty)_ | Remote console admin password (empty disables RCON) |
| `FOF_LAN` | `0` | `1` restricts the server to LAN only |
| `FOF_CHEATS` | `0` | `1` enables `sv_cheats` |
| `FOF_TIMELIMIT` | `25` | Map time limit in minutes (`0` = no limit) |
| `FOF_FRAGLIMIT` | `0` | Frag limit before map change (`0` = no limit) |
| `FOF_FRIENDLYFIRE` | `0` | `1` enables friendly fire |
| `FOF_VOICE_ENABLE` | `1` | `1` enables voice chat |
| `FOF_ALLTALK` | `0` | `1` lets all players hear each other regardless of team |
| `FOF_BOT_SLOTPCT` | `0` | Percentage of empty slots bots backfill (`0` = no bots) |
| `FOF_REGION` | `255` | Steam master-server region (`255` = world) |
| `FOF_GSLT` | _(empty)_ | Game Server Login Token for appid 295230; required only to list the server publicly |

## Admin Notes

- **Config**: `FOF_*` values render into `/game/fof/cfg/server.cfg`, exec'd at startup via
  `+exec server.cfg`.
- **RCON**: set `FOF_RCON_PASSWORD` to administer the server with any Source RCON client over
  TCP 27015.
- **Public listing**: anonymous servers run for direct/LAN connects. To appear on the public
  Steam server browser, supply a GSLT via `FOF_GSLT`
  (https://steamcommunity.com/dev/managegameservers, app 295230).
- **Maps / modes**: Fistful of Frags ships modes like Shootout (free-for-all), Team Shootout,
  Elimination, and Versus; the active mode is tied to the map. Change the starting map with
  `FOF_MAP`.
