# Palworld Server

This directory contains the configuration and scripts for running a Palworld game server using BipOps.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=palworld \
  -e PALWORLD_SERVER_NAME="BipOps Palworld Server" \
  -e PALWORLD_SERVER_PASSWORD=yourpassword \
  -e PALWORLD_ADMIN_PASSWORD=youradminpassword \
  -e PALWORLD_MAX_PLAYERS=24 \
  -p 8211:8211/udp \
  -v /path/to/gameservers/palworld/game:/game \
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

| Host Path                             | Container Path | Description            |
| ------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/palworld/game    | /game          | Game files directory   |
| /path/to/gameservers/palworld/backups | /backups       | Backup files directory |

## Environment Variables

Below is a comprehensive list of all available configuration options for the Palworld server:

| Variable                                          | Default                                         | Description                                                                                                                                       |
| ------------------------------------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| PALWORLD_ADMIN_PASSWORD                           | ""                                              | Password used to obtain administrative privileges on the server                                                                                   |
| PALWORLD_ALLOW_CONNECT_PLATFORM                   |                                                 | Doesn't work with this version. Please use PALWORLD_CROSSPLAY_PLATFORMS                                                                           |
| PALWORLD_BASE_CAMP_MAX_NUM_IN_GUILD               | 4                                               | Max BaseCamp count per guild (MAX 10). Larger value will increase system load                                                                     |
| PALWORLD_BASE_CAMP_WORKER_MAXNUM                  | 15                                              | Max pals per basecamp (MAX 50). Larger value will increase system load                                                                            |
| PALWORLD_ALLOW_GLOBAL_PALBOX_EXPORT               | true                                            | If set to true, saving to the global palbox is possible                                                                                           |
| PALWORLD_ALLOW_GLOBAL_PALBOX_IMPORT               | false                                           | If set to true, importing from the global palbox is possible                                                                                      |
| PALWORLD_BUILD_AREA_LIMIT                         | false                                           | Prohibit building near structures such as fast travel                                                                                             |
| PALWORLD_CHARACTER_RECREATE_IN_HARDCORE           | false                                           | Allow recreate character when you died in Hardcore mode                                                                                           |
| PALWORLD_ENABLE_FAST_TRAVEL                       | true                                            | Enable Fast Travel                                                                                                                                |
| PALWORLD_ENABLE_INVADER_ENEMY                     | true                                            | Enable Invader                                                                                                                                    |
| PALWORLD_HARDCORE                                 | false                                           | Enable Hardcore. Cannot respawn upon death                                                                                                        |
| PALWORLD_INVISIBLE_OTHER_GUILD_BASE_CAMP_AREA_FX  | false                                           | Enable Show basecamp area                                                                                                                         |
| PALWORLD_IS_RANDOMIZER_PAL_LEVEL_RANDOM           | false                                           | If true, Wild pals level is fully randomized. If false, randomized within a level optimized with the area                                         |
| PALWORLD_ENABLE_WORLD_BACKUP                      | false                                           | Enable world backup. Disk load will increase when enabled                                                                                         |
| PALWORLD_PAL_LOST                                 | false                                           | Permanent lost your Pals upon death                                                                                                               |
| PALWORLD_SHOW_PLAYER_LIST                         | false                                           | Enable player list when the press ESC key                                                                                                         |
| PALWORLD_BUILD_OBJECT_DAMAGE_RATE                 | 1.000000                                        | Damage to Structure Multiplier                                                                                                                    |
| PALWORLD_BUILD_OBJECT_DETERIORATION_DAMAGE_RATE   | 1.000000                                        | Structure Deterioration Rate                                                                                                                      |
| PALWORLD_CHAT_POST_LIMIT_PER_MINUTE               | 10                                              | Number of chats that can be posted per minute                                                                                                     |
| PALWORLD_COLLECTION_DROP_RATE                     | 1.000000                                        | Gatherable Items Multiplier                                                                                                                       |
| PALWORLD_COLLECTION_OBJECT_HP_RATE                | 1.000000                                        | Gatherable Objects Health Multiplier                                                                                                              |
| PALWORLD_COLLECTION_OBJECT_RESPAWN_SPEED_RATE     | 1.000000                                        | Gatherable Objects Respawn Interval                                                                                                               |
| PALWORLD_CROSSPLAY_PLATFORMS                      | "(Steam,Xbox,PS5,Mac)"                          | Allowed platform to connect the server                                                                                                            |
| PALWORLD_DAYTIME_SPEEDRATE                        | 1.000000                                        | Day time speed                                                                                                                                    |
| PALWORLD_DEATH_PENALTY                            | All                                             | Death Penalty (None: No drops, Item: Drop all items except equipment, ItemAndEquipment: Drop all items, All: Drop all items and all Pals on team) |
| PALWORLD_ENEMY_DROP_ITEM_RATE                     | 1.000000                                        | Dropped Items Multiplier                                                                                                                          |
| PALWORLD_EQUIPMENT_DURABILITY_DAMAGE_RATE         | 1.000000                                        | Equipment Durability Loss Multiplier                                                                                                              |
| PALWORLD_EXP_RATE                                 | 1.000000                                        | EXP rate                                                                                                                                          |
| PALWORLD_GUILD_PLAYER_MAX_NUM                     | 20                                              | Max Player Number of Guilds                                                                                                                       |
| PALWORLD_ITEM_CONTAINER_FORCE_MARK_DIRTY_INTERVAL | 1.000000                                        | Interval for force sync when open the container (sec)                                                                                             |
| PALWORLD_ITEM_WEIGHT_RATE                         | 1.000000                                        | Item weight ratio                                                                                                                                 |
| PALWORLD_LOG_FORMAT_TYPE                          | Text                                            | Log format Text or Json                                                                                                                           |
| PALWORLD_MAX_BUILDING_LIMIT_NUM                   | 0                                               | Building num limit per player (0 = unlimit)                                                                                                       |
| PALWORLD_NIGHTTIME_SPEEDRATE                      | 1.000000                                        | Night time speed                                                                                                                                  |
| PALWORLD_PAL_AUTO_HP_REGENE_RATE                  | 1.000000                                        | Pal Auto Health Regeneration Rate                                                                                                                 |
| PALWORLD_PAL_AUTO_HP_REGENE_RATE_IN_SLEEP         | 1.000000                                        | Pal Sleep Health Regeneration Rate (Health Regeneration Rate in Palbox)                                                                           |
| PALWORLD_PAL_CAPTURE_RATE                         | 1.000000                                        | Pal capture rate                                                                                                                                  |
| PALWORLD_PAL_DAMAGE_RATE_ATTACK                   | 1.000000                                        | Damage from Pals Multiplier                                                                                                                       |
| PALWORLD_PAL_DAMAGE_RATE_DEFENSE                  | 1.000000                                        | Damage to Pals Multiplier                                                                                                                         |
| PALWORLD_PAL_EGG_DEFAULT_HATCHING_TIME            | 72.000000                                       | Time (h) to incubate Massive Egg. Note: Other eggs also require time to incubate                                                                  |
| PALWORLD_PAL_SPAWN_NUM_RATE                       | 1.000000                                        | Pal Appearance Rate. Note: Affects game performance                                                                                               |
| PALWORLD_PAL_STAMINA_DECREACE_RATE                | 1.000000                                        | Pal Stamina Reduction Rate                                                                                                                        |
| PALWORLD_PAL_STOMACH_DECREACE_RATE                | 1.000000                                        | Pal Hunger Depletion Rate                                                                                                                         |
| PALWORLD_PLAYER_AUTO_HP_REGENE_RATE               | 1.000000                                        | Player Auto Health Regeneration Rate                                                                                                              |
| PALWORLD_PLAYER_AUTO_HP_REGENE_RATE_IN_SLEEP      | 1.000000                                        | Player Sleep Health Regeneration Rate                                                                                                             |
| PALWORLD_PLAYER_DAMAGE_RATE_ATTACK                | 1.000000                                        | Damage from Player Multiplier                                                                                                                     |
| PALWORLD_PLAYER_DAMAGE_RATE_DEFENSE               | 1.000000                                        | Damage to Player Multiplier                                                                                                                       |
| PALWORLD_PLAYER_STAMINA_DECREACE_RATE             | 1.000000                                        | Player Stamina Reduction Rate                                                                                                                     |
| PALWORLD_PLAYER_STOMACH_DECREASE_RATE             | 1.000000                                        | Player Hunger Depletion Rate                                                                                                                      |
| PALWORLD_PUBLIC_IP                                | ""                                              | Explicitly specify an external public IP in the community server settings                                                                         |
| PALWORLD_PUBLIC_PORT                              | 8211                                            | Explicitly specify the external public port in the community server configuration (This setting does not change the server's listen port)         |
| PALWORLD_RANDOMIZER_SEED                          | ""                                              | Randomize seed                                                                                                                                    |
| PALWORLD_RANDOMIZER_TYPE                          | None                                            | Random Pal Mode (None: No Randomization, Region: Randomize by Region, All: Completely Random)                                                     |
| PALWORLD_RCON_ENABLED                             | true                                            | Enable RCON                                                                                                                                       |
| PALWORLD_RCON_PORT                                | 25575                                           | Port Number for RCON                                                                                                                              |
| PALWORLD_RESTAPI_ENABLED                          | true                                            | Enable REST API                                                                                                                                   |
| PALWORLD_RESTAPI_PORT                             | 8212                                            | Listen port for REST API                                                                                                                          |
| PALWORLD_SERVER_DESCRIPTION                       | "Palworld Dedicated Server running with BipOps" | Server description                                                                                                                                |
| PALWORLD_SERVER_NAME                              | "BipOps Palworld Server"                        | Server name                                                                                                                                       |
| PALWORLD_SERVER_PASSWORD                          | ""                                              | Password required for server login                                                                                                                |
| PALWORLD_MAX_PLAYERS                              | 32                                              | Maximum number of players that can join the server                                                                                                |
| PALWORLD_SERVER_REPLICATE_PAWN_CULL_DISTANCE      | 15000.000000                                    | Pal sync distance from player (cm). Min 5000 ~ Max 15000                                                                                          |
| PALWORLD_SUPPLY_DROP_SPAN                         | 180                                             | Interval for supply drop (minutes)                                                                                                                |

For additional information and the latest updates, please refer to the [Palworld Tech Guide](https://tech.palworldgame.com/settings-and-operation/configuration).

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
