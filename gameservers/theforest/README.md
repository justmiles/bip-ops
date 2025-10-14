# The Forest Dedicated Server

This document describes the configuration options for The Forest dedicated server.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=theforest \
  -e THEFOREST_SERVER_NAME="BipOps Forest Server" \
  -e THEFOREST_SERVER_PASSWORD=password \
  -p 8766:8766/udp \
  -p 27015:27015/udp \
  -p 27016:27016/udp \
  -v /path/to/gameservers/theforest/game:/game \
  -v /path/to/gameservers/theforest/backups:/backups \
  justmiles/bip-ops
```

## Network Ports

| Port  | Protocol | Description         |
| ----- | -------- | ------------------- |
| 8766  | UDP      | Steam communication |
| 27015 | UDP      | Game connection     |
| 27016 | UDP      | Query communication |

## Volumes

| Path     | Description                         |
| -------- | ----------------------------------- |
| /game    | Cache for the gameserver files      |
| /backups | Storage for older game save backups |

## Configuration

The server is configured using environment variables. Each configuration option has a default value that will be used if the environment variable is not set.

For detailed information about these settings, please refer to the [Steam Community Guide](https://steamcommunity.com/sharedfiles/filedetails/?id=907906289).

## Environment Variables

| Environment Variable                    | Default Value     | Description                                                           | Accepted Values                   |
| --------------------------------------- | ----------------- | --------------------------------------------------------------------- | --------------------------------- |
| `BIPOPS_GAMESERVER`                     | `theforest`       | Must be set to "theforest" for bip-ops to run The Forest              | theforest                         |
| `BIPOPS_VALIDATE_SERVER_FILES`          | `true`            | Validate server files are up to date before launching server instance | true, false                       |
| `THEFOREST_SERVER_IP`                   | `0.0.0.0`         | Server IP address, usually 0.0.0.0 if listening on all interfaces     | any string formatted ipv4 address |
| `THEFOREST_SERVER_STEAM_PORT`           | `8766`            | Steam Communication Port (requires router port forwarding)            | integer                           |
| `THEFOREST_SERVER_GAME_PORT`            | `27015`           | Game Communication Port (requires router port forwarding)             | integer                           |
| `THEFOREST_SERVER_QUERY_PORT`           | `27016`           | Query Communication Port (requires router port forwarding)            | integer                           |
| `THEFOREST_SERVER_NAME`                 | `The Forest Game` | Server display name visible in the server list                        | any string                        |
| `THEFOREST_SERVER_PLAYERS`              | `8`               | Maximum number of players allowed on the server                       | integer (1-8)                     |
| `THEFOREST_SERVER_PASSWORD`             |                   | Server password for private servers (blank means no password)         | any string                        |
| `THEFOREST_SERVER_PASSWORD_ADMIN`       |                   | Server administration password (blank means no password)              | any string                        |
| `THEFOREST_SERVER_STEAM_ACCOUNT`        |                   | Steam account name for server (blank means anonymous)                 | any string                        |
| `THEFOREST_ENABLE_VAC`                  | `off`             | Enable VAC (Valve Anti Cheat) on the server                           | on, off                           |
| `THEFOREST_SERVER_AUTO_SAVE_INTERVAL`   | `30`              | Time between server auto saves in minutes                             | integer                           |
| `THEFOREST_DIFFICULTY`                  | `Normal`          | Game difficulty mode                                                  | Peaceful, Normal, Hard            |
| `THEFOREST_INIT_TYPE`                   | `Continue`        | Initialize new game or continue existing                              | New, Continue                     |
| `THEFOREST_SLOT`                        | `1`               | Save game slot number                                                 | 1, 2, 3, 4, 5                     |
| `THEFOREST_SHOW_LOGS`                   | `off`             | Show event log                                                        | on, off                           |
| `THEFOREST_SERVER_CONTACT`              |                   | Contact email for server admin                                        | any string                        |
| `THEFOREST_VEGAN_MODE`                  | `off`             | No enemies mode                                                       | on, off                           |
| `THEFOREST_VEGETARIAN_MODE`             | `off`             | No enemies during day time                                            | on, off                           |
| `THEFOREST_RESET_HOLES_MODE`            | `off`             | Reset all structure holes when loading a save                         | on, off                           |
| `THEFOREST_TREE_REGROW_MODE`            | `off`             | Regrow 10% of cut down trees when sleeping                            | on, off                           |
| `THEFOREST_ALLOW_BUILDING_DESTRUCTION`  | `on`              | Allow building destruction                                            | on, off                           |
| `THEFOREST_ALLOW_ENEMIES_CREATIVE_MODE` | `off`             | Allow enemies in creative games                                       | on, off                           |
| `THEFOREST_ALLOW_CHEATS`                | `off`             | Allow clients to use the built-in development console                 | on, off                           |
| `THEFOREST_REALISTIC_PLAYER_DAMAGE`     | `off`             | Use full weapon damage values when attacking other players            | on, off                           |
| `THEFOREST_SAVE_FOLDER_PATH`            |                   | Custom folder for save slots (empty uses default location)            | any string                        |
| `THEFOREST_TARGET_FPS_IDLE`             | `5`               | Target FPS when no client is connected                                | integer                           |
| `THEFOREST_TARGET_FPS_ACTIVE`           | `60`              | Target FPS when there is at least one client connected                | integer                           |
