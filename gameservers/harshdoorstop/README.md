# Operation: Harsh Doorstop

Operation: Harsh Doorstop is a free, community-funded Unreal Engine tactical-shooter
sandbox with full Steam Workshop support. The dedicated server is a native 64-bit Linux
build installed anonymously via SteamCMD (appid `950900`).

- Store / Steam appid: `736590`
- Dedicated server appid (SteamCMD `+app_update`): `950900`
- Launch binary: `./HarshDoorstop/Binaries/Linux/HarshDoorstopServer-Linux-Shipping`
- Config: `HarshDoorstop/Saved/Config/LinuxServer/Game.ini`

## Quickstart

```bash
docker run -d --name harshdoorstop \
  -e BIPOPS_GAMESERVER=harshdoorstop \
  -e HARSHDOORSTOP_SERVER_NAME="My Harsh Doorstop Server" \
  -e HARSHDOORSTOP_MAX_PLAYERS=32 \
  -e HARSHDOORSTOP_MAP=AAS-TestMap \
  -p 7777:7777/udp \
  -p 27005:27005/udp \
  -v harshdoorstop-game:/game \
  -v harshdoorstop-backups:/backups \
  justmiles/bipops:v0.11.0
```

To enable RCON, additionally set `HARSHDOORSTOP_RCON_PASSWORD` and publish `7779/tcp`.

## Ports

| Port    | Protocol | Purpose                                   | Env                        |
|---------|----------|-------------------------------------------|----------------------------|
| `7777`  | UDP      | Game traffic                              | `HARSHDOORSTOP_PORT`       |
| `27005` | UDP      | Steam A2S server query / master list      | `HARSHDOORSTOP_QUERY_PORT` |
| `7779`  | TCP      | RCON (only when RCON password is set)     | `HARSHDOORSTOP_RCON_PORT`  |
| `7778`  | UDP      | Steam client (outbound, not forwarded)    | -                          |

## Volumes

| Mount      | Purpose                                             |
|------------|-----------------------------------------------------|
| `/game`    | Game installation + saves and config                |
| `/backups` | rsnapshot backup storage                            |

Save data backed up from `/game/HarshDoorstop/Saved/SaveGames`.

## Environment Variables

| Variable                              | Default                        | Description                                                        |
|---------------------------------------|--------------------------------|--------------------------------------------------------------------|
| `HARSHDOORSTOP_SERVER_NAME`           | `BipOps Harsh Doorstop Server` | Server name shown in the browser / master list                     |
| `HARSHDOORSTOP_MAX_PLAYERS`           | `32`                           | Maximum player slots                                               |
| `HARSHDOORSTOP_MAP`                   | `AAS-TestMap`                  | Starting map / scenario (the launch URL map segment)              |
| `HARSHDOORSTOP_PASSWORD`              | _(empty)_                      | Join password (empty = public, no password)                        |
| `HARSHDOORSTOP_PORT`                  | `7777`                         | Game traffic UDP port                                              |
| `HARSHDOORSTOP_QUERY_PORT`            | `27005`                        | Steam A2S query UDP port                                           |
| `HARSHDOORSTOP_MULTIHOME`             | `0.0.0.0`                      | Bind address                                                       |
| `HARSHDOORSTOP_MUTATORS`              | _(empty)_                      | Comma-separated mutator paths, appended as a `?Mutators=` URL arg  |
| `HARSHDOORSTOP_EXTRA_URL_ARGS`        | _(empty)_                      | Extra `?key=value` URL params appended to the map (e.g. factions)  |
| `HARSHDOORSTOP_RCON_ENABLED`          | `False`                        | `bEnabled` in Game.ini `[/Script/RCON.RCONServerSystem]`           |
| `HARSHDOORSTOP_RCON_PASSWORD`         | _(empty)_                      | RCON password. RCON is only launched when this is set              |
| `HARSHDOORSTOP_RCON_PORT`             | `7779`                         | RCON TCP listen port                                               |
| `HARSHDOORSTOP_RCON_MAX_CONNECTIONS`  | `5`                            | Max simultaneous RCON connections                                 |
| `HARSHDOORSTOP_RCON_MAX_AUTH_ATTEMPTS`| `3`                            | Max RCON auth attempts before lockout                             |

## Admin Notes

- The server is **free** and installs anonymously; no Steam login or GSLT is required.
- The launch URL takes the form `<Map>?MaxPlayers=<N>?Mutators=<...>`; additional
  gameplay options (factions, bot counts, game mode, ticket counts) can be passed via
  `HARSHDOORSTOP_EXTRA_URL_ARGS`, for example
  `BluforFaction=US?OpforFaction=INS?bBotAutofill?BluforNumBots=4`.
- RCON writes `bEnabled` / `ListenPort` / `Password` into Game.ini **and** is activated
  on the command line; set `HARSHDOORSTOP_RCON_PASSWORD` (and `HARSHDOORSTOP_RCON_ENABLED=True`)
  together.
- Steam Workshop mods are supported by the game; mod handling is out of scope for this
  baseline definition.
