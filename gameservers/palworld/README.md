# Palworld Server

This directory contains the configuration and scripts for running a Palworld game server using BipOps.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=palworld \
  -e PALWORLD_SERVER_NAME="BipOps Palworld Server" \
  -e PALWORLD_SERVER_PASSWORD=yourpassword \
  -e PALWORLD_ADMIN_PASSWORD=youradminpassword \
  -e PALWORLD_MAX_PLAYERS=32 \
  -p 8211:8211/udp \
  -p 8212:8212/tcp \
  -p 25575:25575/tcp \
  -v /path/to/gameservers/palworld/game:/game \
  -v /path/to/gameservers/palworld/saves:/palworld/Pal/Saved \
  -v /path/to/gameservers/palworld/backups:/backups \
  justmiles/bip-ops
```

## Required Ports

| Port  | Protocol | Description     |
| ----- | -------- | --------------- |
| 8211  | UDP      | Game connection |
| 8212  | TCP      | REST API        |
| 25575 | TCP      | RCON            |

## Volume Mounts

| Host Path                             | Container Path      | Description            |
| ------------------------------------- | ------------------- | ---------------------- |
| /path/to/gameservers/palworld/game    | /game               | Game files directory   |
| /path/to/gameservers/palworld/saves   | /palworld/Pal/Saved | Game save files        |
| /path/to/gameservers/palworld/backups | /backups            | Backup files directory |

## Environment Variables

### Basic Server Settings

| Variable                          | Default                                         | Description                                                                       |
| --------------------------------- | ----------------------------------------------- | --------------------------------------------------------------------------------- |
| BIPOPS_GAMESERVER                 | (required)                                      | Must be set to "palworld"                                                         |
| BIPOPS_VALIDATE_SERVER_FILES      | true                                            | Validate server files are up to date before launching server instance             |
| PALWORLD_SERVER_NAME              | "BipOps Palworld Server"                        | Server name                                                                       |
| PALWORLD_SERVER_DESCRIPTION       | "Palworld Dedicated Server running with BipOps" | Server description                                                                |
| PALWORLD_SERVER_PASSWORD          | ""                                              | Password required for server login                                                |
| PALWORLD_ADMIN_PASSWORD           | ""                                              | Password used to obtain administrative privileges on the server                   |
| PALWORLD_MAX_PLAYERS              | 32                                              | Maximum number of players that can join the server                                |
| PALWORLD_PUBLIC_PORT              | 8211                                            | Explicitly specify the external public port in the community server configuration |
| PALWORLD_PUBLIC_IP                | ""                                              | Explicitly specify an external public IP in the community server settings         |
| PALWORLD_RCON_ENABLED             | true                                            | Enable RCON                                                                       |
| PALWORLD_RCON_PORT                | 25575                                           | Port Number for RCON                                                              |
| PALWORLD_RESTAPI_ENABLED          | true                                            | Enable REST API                                                                   |
| PALWORLD_RESTAPI_PORT             | 8212                                            | Listen port for REST API                                                          |
| PALWORLD_COMMUNITY_SERVER         | true                                            | Set to true to appear in the Community Server list                                |
| PALWORLD_MULTITHREAD_ENABLED      | true                                            | Enable multi-threading for better performance                                     |
| PALWORLD_NET_SERVER_MAX_TICK_RATE | 120                                             | Server tick rate (30-120)                                                         |

### Game Settings

| Variable                                | Default   | Description                                       |
| --------------------------------------- | --------- | ------------------------------------------------- |
| PALWORLD_DIFFICULTY                     | None      | Game difficulty (None, Normal, Difficult)         |
| PALWORLD_DAYTIME_SPEEDRATE              | 1.000000  | Day time speed rate                               |
| PALWORLD_NIGHTTIME_SPEEDRATE            | 1.000000  | Night time speed rate                             |
| PALWORLD_EXP_RATE                       | 1.000000  | Experience gain rate                              |
| PALWORLD_PAL_CAPTURE_RATE               | 1.000000  | Pal capture rate                                  |
| PALWORLD_PAL_SPAWN_NUM_RATE             | 1.000000  | Pal spawn rate                                    |
| PALWORLD_DEATH_PENALTY                  | All       | Death penalty (None, Item, ItemAndEquipment, All) |
| PALWORLD_ENABLE_PLAYER_TO_PLAYER_DAMAGE | false     | Enable PvP damage                                 |
| PALWORLD_ENABLE_FRIENDLY_FIRE           | false     | Enable friendly fire                              |
| PALWORLD_ENABLE_INVADER_ENEMY           | true      | Enable enemy raids                                |
| PALWORLD_IS_PVP                         | false     | Enable PvP mode                                   |
| PALWORLD_BASE_CAMP_WORKER_MAXNUM        | 15        | Maximum number of Pals working at a base camp     |
| PALWORLD_DROP_ITEM_MAX_NUM              | 3000      | Maximum number of dropped items in the world      |
| PALWORLD_AUTO_SAVE_SPAN                 | 30.000000 | Auto-save interval in minutes                     |

### Advanced Settings

For a complete list of all available environment variables, please refer to the [Palworld Tech Guide](https://tech.palworldgame.com/settings-and-operation/configuration).

## Server Administration

You can use RCON to administer your server. Connect to the RCON port (default: 25575) using an RCON client with the PALWORLD_ADMIN_PASSWORD you set.

Common RCON commands:

- `Shutdown <Seconds> <MessageText>`: Shutdown the server after specified seconds with a message
- `DoExit`: Immediately shutdown the server
- `Broadcast <MessageText>`: Send a message to all players
- `KickPlayer <SteamID>`: Kick a player from the server
- `BanPlayer <SteamID>`: Ban a player from the server
- `ShowPlayers`: Show all connected players
- `Save`: Save the current game state
