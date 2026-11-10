# Icarus Dedicated Server

This document describes the configuration options for the Icarus dedicated server.

Icarus (RocketWerkz) ships only a Windows server binary, so bip-ops downloads the
Windows build via SteamCMD (Steam app `2089300`) and runs `IcarusServer.exe` under
Wine. On first launch the Visual C++ 2022 redistributable is installed into the Wine
prefix at `/game/.wine` (cached across restarts). The rendered `ServerSettings.ini`
is placed at `/game/Icarus/Saved/Config/WindowsServer/ServerSettings.ini` and read by
the server at launch.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=icarus \
  -e ICARUS_SESSION_NAME="BipOps Icarus Server" \
  -e ICARUS_ADMIN_PASSWORD=changeme \
  -p 17777:17777/udp \
  -p 27015:27015/udp \
  -v /path/to/gameservers/icarus/game:/game \
  justmiles/bipops
```

Once running, connect from the Icarus client via the in-game dedicated-server browser
and create or load a prospect. A prospect can also be launched automatically at boot by
setting `ICARUS_CREATE_PROSPECT` (see below).

## Network Ports

| Port  | Protocol | Description                             |
| ----- | -------- | --------------------------------------- |
| 17777 | UDP      | Game port (`ICARUS_GAME_PORT`)          |
| 27015 | UDP      | Steam query port (`ICARUS_QUERY_PORT`)  |

## Volumes

| Path  | Description                                                  |
| ----- | ------------------------------------------------------------ |
| /game | Server files, Wine prefix (`.wine`), rendered config, saves  |

Save data (prospects and config) lives under `/game/Icarus/Saved` and is backed up by
bip-ops (`backupdir`).

## Configuration

The server is configured using environment variables. Each option has a default value
that is used if the environment variable is not set. Port values are passed as launch
arguments; all other values are rendered into `ServerSettings.ini`.

For details on each setting, see the
[official Icarus dedicated server wiki](https://github.com/RocketWerkz/IcarusDedicatedServer/wiki).

## Environment Variables

| Environment Variable                         | Default               | Description                                                              | Accepted Values  |
| -------------------------------------------- | --------------------- | ------------------------------------------------------------------------ | ---------------- |
| `BIPOPS_GAMESERVER`                          | `icarus`              | Must be set to "icarus" for bip-ops to run Icarus                        | icarus           |
| `BIPOPS_VALIDATE_SERVER_FILES`               | `true`                | Validate server files are up to date before launching                    | true, false      |
| `ICARUS_SESSION_NAME`                        | `BipOps Icarus Server`| Browser display name (passed via `-SteamServerName`; the ini `SessionName` key is ignored by Icarus) | any string (<=64 chars) |
| `ICARUS_JOIN_PASSWORD`                       | (empty)               | Password required to join the server                                     | any string       |
| `ICARUS_ADMIN_PASSWORD`                      | (empty)               | Admin password for server management                                     | any string       |
| `ICARUS_MAX_PLAYERS`                         | `8`                   | Maximum number of player slots                                           | integer          |
| `ICARUS_MULTIHOME`                           | `0.0.0.0`             | Address the server binds to (all interfaces by default)                  | IP address       |
| `ICARUS_GAME_PORT`                           | `17777`               | Game UDP port                                                            | integer          |
| `ICARUS_QUERY_PORT`                          | `27015`               | Steam query UDP port                                                     | integer          |
| `ICARUS_SHUTDOWN_IF_NOT_JOINED_FOR`          | `300.000000`          | Seconds to wait for a first join before shutting down (0 disables)       | number           |
| `ICARUS_SHUTDOWN_IF_EMPTY_FOR`               | `300.000000`          | Seconds the server may stay empty before shutting down (0 disables)      | number           |
| `ICARUS_ALLOW_NON_ADMINS_TO_LAUNCH_PROSPECTS`| `True`                | Allow non-admin players to launch prospects                              | True, False      |
| `ICARUS_ALLOW_NON_ADMINS_TO_DELETE_PROSPECTS`| `False`               | Allow non-admin players to delete prospects                              | True, False      |
| `ICARUS_LOAD_PROSPECT`                        | (empty)               | Name of an existing prospect to load on boot                             | any string       |
| `ICARUS_CREATE_PROSPECT`                      | (empty)               | Prospect to create on boot (e.g. `Olympus_Styx`)                         | prospect id      |
| `ICARUS_RESUME_PROSPECT`                      | `True`                | Resume the last active prospect on boot                                  | True, False      |
| `ICARUS_LAST_PROSPECT_NAME`                   | (empty)               | Name of the last prospect (set automatically by the server)             | any string       |
