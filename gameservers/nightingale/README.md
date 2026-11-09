# Nightingale Server

This directory contains the configuration and scripts for running a Nightingale dedicated
server using BipOps.

Nightingale ships a native 64-bit Linux dedicated server (Unreal Engine 5) that SteamCMD
downloads anonymously (Steam appid 3796810) and runs fully headless (no Wine, no X display).
Official co-op is capped at 6 players; higher values are unsupported by the game.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=nightingale \
  -e NIGHTINGALE_ADMIN_PASSWORD=youradminpassword \
  -e NIGHTINGALE_PASSWORD=joinpassword \
  -e NIGHTINGALE_DIFFICULTY=medium \
  -e NIGHTINGALE_MAX_PLAYERS=6 \
  -p 7777:7777/udp \
  -v /path/to/gameservers/nightingale/game:/game \
  -v /path/to/gameservers/nightingale/backups:/backups \
  justmiles/bipops
```

First boot downloads the server via SteamCMD, which can take several minutes. On first run
the server creates `NWX/Config/ServerSettings.ini` from the shipped example; BipOps renders
that file from the environment variables below.

## Required Ports

| Port  | Protocol | Description                                               |
| ----- | -------- | --------------------------------------------------------- |
| 7777  | UDP      | Game traffic (`-port`)                                    |
| varies| TCP      | Optional HTTP status endpoint (`-statusPort`), off by default |

Nightingale has no public server browser and no Steam A2S query port; players connect by
IP. Only the UDP game port must be reachable.

## Volume Mounts

| Host Path                               | Container Path | Description            |
| --------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/nightingale/game   | /game          | Game files directory   |
| /path/to/gameservers/nightingale/backups| /backups       | Backup files directory |

World, realm, character, and persistence data live under `/game/NWX/Saved/`, which is what
BipOps backs up.

## Environment Variables

| Variable                   | Default  | Description                                                           |
| -------------------------- | -------- | -------------------------------------------------------------------- |
| NIGHTINGALE_SERVER_NAME    | BipOps Nightingale Server | Display label in the BipOps UI (the game has no in-game server name) |
| NIGHTINGALE_PASSWORD       | ""       | Password required to join; blank for none (`Password`)               |
| NIGHTINGALE_ADMIN_PASSWORD | ""       | Grants in-game kick/ban admin commands (`AdminPassword`)             |
| NIGHTINGALE_DIFFICULTY     | medium   | Starting realm difficulty: easy, medium, hard, extreme (`StartingDifficulty`) |
| NIGHTINGALE_MAX_PLAYERS    | 6        | Player slots; officially supported max is 6 (`MaxPlayers`)           |
| NIGHTINGALE_PORT           | 7777     | UDP game port (`-port`)                                              |
| NIGHTINGALE_BIND_ADDR      | 0.0.0.0  | Interface to bind (`-multihome`)                                     |
| NIGHTINGALE_STATUS_PORT    | ""       | Optional HTTP status endpoint port, 1024-65535 (`-statusPort`)       |
| NIGHTINGALE_ENABLE_CHEATS  | false    | Enable debug/cheat console commands (`-EnableCheats`)                |

## Server Administration

Set `NIGHTINGALE_ADMIN_PASSWORD` to enable in-game admin commands (kick/ban). Players who
authenticate with the admin password in-game gain moderation access.

Admin and join settings are written to `NWX/Config/ServerSettings.ini` under the
`[/Script/NWX.NWXServerSettings]` section. The full configurable surface is just three keys:
`Password`, `AdminPassword`, and `StartingDifficulty`.

## Notes

- Nightingale supports up to 6 players officially; setting `NIGHTINGALE_MAX_PLAYERS` higher
  than 6 is not supported by the game and may be unstable.
- There is no public server browser and no Steam query port; share the host IP and
  (optional) password with players so they can direct-connect.
- `NIGHTINGALE_STATUS_PORT` exposes a read-only HTTP status endpoint for monitoring; it is
  disabled unless you set a port.
