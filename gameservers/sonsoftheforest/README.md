# Sons of the Forest Dedicated Server

This document describes the configuration options for the Sons of the Forest dedicated server.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=sonsoftheforest \
  -e SOTF_SERVER_NAME="BipOps Server" \
  -e SOTF_PASSWORD=password \
  -p 8766:8766/udp \
  -p 9700:9700/udp \
  -p 27016:27016/udp \
  -v /path/to/gameservers/sonsoftheforest/game:/game \
  -v /path/to/gameservers/sonsoftheforest/backups:/backups \
  justmiles/bip-ops
```

## Network Ports

| Port  | Protocol | Description     |
| ----- | -------- | --------------- |
| 8766  | UDP      | Game connection |
| 9700  | UDP      | Blob sync       |
| 27016 | UDP      | Steam query     |

## Volumes

| Path     | Description                         |
| -------- | ----------------------------------- |
| /game    | Cache for the gameserver files      |
| /backups | Storage for older game save backups |

## Configuration

The server is configured using environment variables. Each configuration option has a default value that will be used if the environment variable is not set.

For detailed information about these settings, please refer to the [Steam Community Guide](https://steamcommunity.com/sharedfiles/filedetails/?id=2992700419&snr=1_2108_9__2107).

## Environment Variables

### Basic Server Settings

| Environment Variable                   | Default Value             | Description                                                                                                                       | Accepted Values                                                  |
| -------------------------------------- | ------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `BIPOPS_GAMESERVER`                    |                           | Must be set to "sonsoftheforest" for bip-ops to run Sons of The Forest                                                            | sonsoftheforest                                                  |
| `BIPOPS_VALIDATE_SERVER_FILES`         | `true`                    | Validate server files are up to date before launching server instance                                                             | true, false                                                      |
| `SOTF_IP_ADDRESS`                      | `0.0.0.0`                 | Listening interface for the game server, usually 0.0.0.0 if listening on all interfaces.                                          | any string formatted ipv4 address                                |
| `SOTF_GAME_PORT`                       | `8766`                    | UDP port used for gameplay netcode.                                                                                               | integer                                                          |
| `SOTF_QUERY_PORT`                      | `27016`                   | UDP port used by Steam to list the server and enable the discovery services.                                                      | integer                                                          |
| `SOTF_BLOB_SYNC_PORT`                  | `9700`                    | UDP port used by the BlobSync system to initialize game systems and exchange data.                                                | integer                                                          |
| `SOTF_SERVER_NAME`                     | `BipOps Dedicated Server` | Name of the server visible in the server list, and in the Steam contacts.                                                         | any string                                                       |
| `SOTF_MAX_PLAYERS`                     | `8`                       | The maximum number of players allowed simultaneously on the server.                                                               | integer (1-8)                                                    |
| `SOTF_PASSWORD`                        | `""`                      | Adds a password to make your server "private". Upon connection, this password will be requested before the client can proceed.    | any string up to 40 characters long                              |
| `SOTF_LAN_ONLY`                        | `false`                   | Allows or restricts the server visibility to LAN only.                                                                            | true, false                                                      |
| `SOTF_SAVE_SLOT`                       | `1`                       | When creating a new save, this number will be the id of the save.                                                                 | integer greater or equal to 1                                    |
| `SOTF_SAVE_MODE`                       | `Continue`                | Game save initialization mode.                                                                                                    | new, continue                                                    |
| `SOTF_GAME_MODE`                       | `Normal`                  | Sets the difficulty game mode when creating a new save. "custom", enables CustomGameModeSettings                                  | normal, hard, hardsurvival, peaceful, creative, custom           |
| `SOTF_SAVE_INTERVAL`                   | `600`                     | How often the game server automatically saves the game to SaveSlot, in seconds.                                                   | integer                                                          |
| `SOTF_IDLE_DAY_CYCLE_SPEED`            | `0.0`                     | A multiplier to how quickly the time passes compared to normal gameplay when the server is considered idle (no player connected). | floating point value between 0 and 1, greater than or equal to 0 |
| `SOTF_IDLE_TARGET_FRAMERATE`           | `5`                       | Target framerate of the server when it's considered idle (no player connected).                                                   | integer greater or equal to 1                                    |
| `SOTF_ACTIVE_TARGET_FRAMERATE`         | `60`                      | Target framerate of the server when it's NOT considered idle (one or more player connected).                                      | integer greater of equal to 10                                   |
| `SOTF_LOG_FILES_ENABLED`               | `false`                   | Defines if the logs will be written to files. The logs will be output in <user data folder>/logs.                                 | true, false                                                      |
| `SOTF_TIMESTAMP_LOG_FILENAMES`         | `true`                    | Enabled log files timestamping                                                                                                    | true, false                                                      |
| `SOTF_TIMESTAMP_LOG_ENTRIES`           | `true`                    | Enables each log entry written to file to be timestamped.                                                                         | true, false                                                      |
| `SOTF_SKIP_NETWORK_ACCESSIBILITY_TEST` | `true`                    | Opt-out of network accessibility self tests                                                                                       | true, false                                                      |
| `SOTF_GAMEPLAY_TREE_REGROWTH`          | `true`                    | Enable automatic tree regrowth, triggered when sleeping.                                                                          | true, false                                                      |
| `SOTF_STRUCTURE_DAMAGE`                | `true`                    | Allow buildings to be damaged.                                                                                                    | true, false                                                      |
| `SOTF_OWNERS_WHITELIST`                |                           | Comma separated list of Steam IDs for every server owner                                                                          | SteamIDs (https://store.steampowered.com/account)                |

### Custom Game Mode Settings

These settings will be ignored if the game mode (`SOTF_GAME_MODE`) is not "custom" or if loading a save (save mode set to "continue" with a save that exists on the slot), whether it is "custom" or not, since they are set once upon save creation.

| Environment Variable                       | Default Value | Description                                                                                                    | Accepted Values                 |
| ------------------------------------------ | ------------- | -------------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `SOTF_MULTIPLAYER_CHEATS`                  | `false`       | Allows cheats on the server.                                                                                   | true, false                     |
| `SOTF_MULTIPLAYER_PVP_DAMAGE`              | `Normal`      | Adjust PVP damage.                                                                                             | low, normal, high               |
| `SOTF_VAIL_ENEMY_SPAWN`                    | `true`        | Enable enemies spawning.                                                                                       | true, false                     |
| `SOTF_VAIL_ENEMY_HEALTH`                   | `Normal`      | Adjust enemy starting health.                                                                                  | low, normal, high               |
| `SOTF_VAIL_ENEMY_DAMAGE`                   | `Normal`      | Adjust damage enemies can do.                                                                                  | low, normal, high               |
| `SOTF_VAIL_ENEMY_ARMOUR`                   | `Normal`      | Adjust enemies armor strength.                                                                                 | low, normal, high               |
| `SOTF_VAIL_ENEMY_AGGRESSION`               | `Normal`      | Adjust enemy aggression level.                                                                                 | low, normal, high               |
| `SOTF_VAIL_ANIMAL_SPAWN_RATE`              | `Normal`      | Adjust animal spawn rate.                                                                                      | low, normal, high               |
| `SOTF_VAIL_ENEMY_SEARCH_PARTIES`           | `Normal`      | Adjust the frequency of enemy search parties.                                                                  | low, normal, high               |
| `SOTF_ENVIRONMENT_STARTING_SEASON`         | `Summer`      | Set environmental starting season.                                                                             | spring, summer, autumn, winter  |
| `SOTF_ENVIRONMENT_SEASON_LENGTH`           | `Default`     | Adjust season length.                                                                                          | short, default, long, realistic |
| `SOTF_ENVIRONMENT_DAY_LENGTH`              | `Default`     | Adjust day length.                                                                                             | short, default, long, realistic |
| `SOTF_ENVIRONMENT_PRECIPITATION_FREQUENCY` | `Default`     | Adjust the frequency of rain and snow.                                                                         | low, default, high              |
| `SOTF_SURVIVAL_CONSUMABLE_EFFECTS`         | `Normal`      | Enable damage taken when low hydration and low fullness.                                                       | normal, hard                    |
| `SOTF_SURVIVAL_PLAYER_STATS_DAMAGE`        | `Off`         | Enable damage from each bad or rotten food and drink.                                                          | off, normal, hard               |
| `SOTF_SURVIVAL_COLD_PENALTIES`             | `Off`         | Adjusts the severity that cold will affect health and stamina regeneration.                                    | off, normal, hard               |
| `SOTF_SURVIVAL_STAT_REGENERATION_PENALTY`  | `Off`         | Reduces the rate that health and stamina will regenerate.                                                      | off, normal, hard               |
| `SOTF_SURVIVAL_REDUCED_FOOD_IN_CONTAINERS` | `false`       | Reduces the amount of food found in containers.                                                                | true, false                     |
| `SOTF_SURVIVAL_SINGLE_USE_CONTAINERS`      | `true`        | Containers can only be opened once.                                                                            | true, false                     |
| `SOTF_SURVIVAL_BUILDING_RESISTANCE`        | `Normal`      | Adjust building resistance to attacks.                                                                         | low, normal, high               |
| `SOTF_SURVIVAL_CREATIVE_MODE`              | `false`       | Enable creative mode game.                                                                                     | true, false                     |
| `SOTF_SURVIVAL_PLAYERS_IMMORTAL_MODE`      | `false`       | Enable god mode for all players.                                                                               | true, false                     |
| `SOTF_SURVIVAL_ONE_HIT_TO_CUT_TREES`       | `false`       | Enable chopping tree with a single hit.                                                                        | true, false                     |
| `SOTF_FREE_FORM_FORCE_PLACE_FULL_LOAD`     | `false`       | If true, everything players have in hands will be placed in a single click (stones, stone floors, wood floors) | true, false                     |
| `SOTF_CONSTRUCTION_NO_CUTTINGS_SPAWN`      | `false`       | If true, disable cuttings spawning.                                                                            | true, false                     |
