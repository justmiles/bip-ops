# Enshrouded Dedicated Server

This document describes the configuration options for the Enshrouded dedicated server.

Enshrouded ships only a Windows server binary, so bip-ops runs `enshrouded_server.exe`
under the Wine build bundled with GE-Proton (wine-9.0 Staging with esync/fsync), which
avoids the high CPU load and poor performance the distro Wine suffers with this title.
It invokes GE-Proton's Wine binary directly rather than the `proton` wrapper: `proton run`
routes Steamworks through its lsteamclient shim, which requires a running Steam client and
crashes a headless dedicated server, so start.sh disables lsteamclient and lets the game
use its own bundled Steamworks SDK. The rendered `enshrouded_server.json` is placed at
`/game/enshrouded_server.json` and read from the working directory at launch.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=enshrouded \
  -e ENSHROUDED_SERVER_NAME="BipOps Enshrouded Server" \
  -e ENSHROUDED_ADMIN_PASSWORD=changeme \
  -p 15637:15637/udp \
  -p 27015:27015/udp \
  -v /path/to/gameservers/enshrouded/game:/game \
  justmiles/bipops
```

## Network Ports

| Port  | Protocol | Description                                  |
| ----- | -------- | -------------------------------------------- |
| 15637 | UDP      | Game / query port (`ENSHROUDED_QUERY_PORT`)  |
| 27015 | UDP      | Steam port used for server discovery         |

## Volumes

| Path  | Description                                                      |
| ----- | --------------------------------------------------------------- |
| /game | Server files, rendered config, and `savegame`/`logs` directories |

Save games live in `/game/savegame` and are backed up by bip-ops (`backupdir`).

## Configuration

The server is configured using environment variables. Each configuration option has a
default value that will be used if the environment variable is not set. Values are
rendered into `enshrouded_server.json`.

For details on each setting, see the
[official Enshrouded dedicated server configuration guide](https://enshrouded.zendesk.com/hc/en-us/articles/16055441447709-Dedicated-Server-Configuration).

## Environment Variables

### Core

| Environment Variable             | Default                   | Description                                                            | Accepted Values                   |
| -------------------------------- | ------------------------- | --------------------------------------------------------------------- | --------------------------------- |
| `BIPOPS_GAMESERVER`              | `enshrouded`              | Must be set to "enshrouded" for bip-ops to run Enshrouded             | enshrouded                        |
| `BIPOPS_VALIDATE_SERVER_FILES`   | `true`                    | Validate server files are up to date before launching                 | true, false                       |
| `ENSHROUDED_SERVER_NAME`         | `BipOps Enshrouded Server`| Server display name visible in the server list                        | any string                        |
| `ENSHROUDED_SAVE_DIRECTORY`      | `./savegame`              | Directory (relative to `/game`) where save games are stored           | any path                          |
| `ENSHROUDED_LOG_DIRECTORY`       | `./logs`                  | Directory (relative to `/game`) where logs are stored                 | any path                          |
| `ENSHROUDED_IP`                  | `0.0.0.0`                 | IP address the server listens on                                      | any ipv4 address                  |
| `ENSHROUDED_QUERY_PORT`          | `15637`                   | Game/query UDP port                                                   | integer                           |
| `ENSHROUDED_SLOT_COUNT`          | `16`                      | Maximum number of player slots                                        | integer (1-16)                    |
| `ENSHROUDED_VOICE_CHAT_MODE`     | `Proximity`               | Voice chat mode                                                       | Proximity, Global                 |
| `ENSHROUDED_ENABLE_VOICE_CHAT`   | `false`                   | Enable in-game voice chat                                             | true, false                       |
| `ENSHROUDED_ENABLE_TEXT_CHAT`    | `false`                   | Enable in-game text chat                                              | true, false                       |
| `ENSHROUDED_GAME_SETTINGS_PRESET`| `Default`                 | Difficulty preset (custom `gameSettings` apply when set to `Custom`)  | Default, Relaxed, Hard, Survival, Custom |

### User Groups

Passwords set the credentials players use to join with the matching permission set.

| Environment Variable             | Default                      | Description                              | Accepted Values |
| -------------------------------- | ---------------------------- | ---------------------------------------- | --------------- |
| `ENSHROUDED_ADMIN_PASSWORD`      | `changemeplease`             | Password for the Admin group             | any string      |
| `ENSHROUDED_ADMIN_RESERVED_SLOTS`| `0`                          | Reserved slots for the Admin group       | integer         |
| `ENSHROUDED_FRIEND_PASSWORD`     | `alsochangemeplease`         | Password for the Friend group            | any string      |
| `ENSHROUDED_FRIEND_RESERVED_SLOTS`| `0`                         | Reserved slots for the Friend group      | integer         |
| `ENSHROUDED_GUEST_PASSWORD`      | `youmaywanttochangethistoo`  | Password for the Guest group             | any string      |
| `ENSHROUDED_GUEST_RESERVED_SLOTS`| `0`                          | Reserved slots for the Guest group       | integer         |

### Game Settings

These only take effect when `ENSHROUDED_GAME_SETTINGS_PRESET` is set to `Custom`.
Duration values (`*_DURATION`, `FROM_HUNGER_TO_STARVING`) are expressed in nanoseconds.

| Environment Variable                          | Default                | Description                                        | Accepted Values                    |
| --------------------------------------------- | ---------------------- | -------------------------------------------------- | ---------------------------------- |
| `ENSHROUDED_PLAYER_HEALTH_FACTOR`             | `1`                    | Player health multiplier                           | number                             |
| `ENSHROUDED_PLAYER_MANA_FACTOR`               | `1`                    | Player mana multiplier                             | number                             |
| `ENSHROUDED_PLAYER_STAMINA_FACTOR`            | `1`                    | Player stamina multiplier                          | number                             |
| `ENSHROUDED_PLAYER_BODY_HEAT_FACTOR`          | `1`                    | Player body heat multiplier                        | number                             |
| `ENSHROUDED_PLAYER_DIVING_TIME_FACTOR`        | `1`                    | Player diving/breath time multiplier               | number                             |
| `ENSHROUDED_ENABLE_DURABILITY`                | `true`                 | Enable equipment durability                        | true, false                        |
| `ENSHROUDED_ENABLE_STARVING_DEBUFF`           | `false`                | Enable the starving debuff                         | true, false                        |
| `ENSHROUDED_FOOD_BUFF_DURATION_FACTOR`        | `1`                    | Food buff duration multiplier                      | number                             |
| `ENSHROUDED_FROM_HUNGER_TO_STARVING`          | `600000000000`         | Time from hungry to starving (nanoseconds)         | integer                            |
| `ENSHROUDED_SHROUD_TIME_FACTOR`               | `1`                    | Time allowed inside the shroud multiplier          | number                             |
| `ENSHROUDED_TOMBSTONE_MODE`                   | `AddBackpackMaterials` | What happens to items on death                     | Everything, AddBackpackMaterials, NoTombstone |
| `ENSHROUDED_ENABLE_GLIDER_TURBULENCES`        | `true`                 | Enable glider turbulence                           | true, false                        |
| `ENSHROUDED_WEATHER_FREQUENCY`                | `Normal`               | Weather event frequency                            | Disabled, Rare, Normal, Often      |
| `ENSHROUDED_FISHING_DIFFICULTY`               | `Normal`               | Fishing minigame difficulty                        | Easy, Normal, Hard                 |
| `ENSHROUDED_MINING_DAMAGE_FACTOR`             | `1`                    | Mining damage multiplier                           | number                             |
| `ENSHROUDED_PLANT_GROWTH_SPEED_FACTOR`        | `1`                    | Plant growth speed multiplier                      | number                             |
| `ENSHROUDED_RESOURCE_DROP_STACK_AMOUNT_FACTOR`| `1`                    | Resource drop stack size multiplier                | number                             |
| `ENSHROUDED_FACTORY_PRODUCTION_SPEED_FACTOR`  | `1`                    | Production/crafting speed multiplier               | number                             |
| `ENSHROUDED_PERK_UPGRADE_RECYCLING_FACTOR`    | `0.5`                  | Materials returned when recycling perk upgrades    | number                             |
| `ENSHROUDED_PERK_COST_FACTOR`                 | `1`                    | Perk cost multiplier                               | number                             |
| `ENSHROUDED_EXPERIENCE_COMBAT_FACTOR`         | `1`                    | Combat XP multiplier                               | number                             |
| `ENSHROUDED_EXPERIENCE_MINING_FACTOR`         | `1`                    | Mining XP multiplier                               | number                             |
| `ENSHROUDED_EXPERIENCE_EXPLORATION_QUESTS_FACTOR` | `1`                | Exploration/quest XP multiplier                    | number                             |
| `ENSHROUDED_RANDOM_SPAWNER_AMOUNT`            | `Normal`               | Random enemy spawner density                       | Few, Normal, Many, Extreme         |
| `ENSHROUDED_AGGRO_POOL_AMOUNT`                | `Normal`               | Number of enemies that can attack at once          | Few, Normal, Many, Extreme         |
| `ENSHROUDED_ENEMY_DAMAGE_FACTOR`              | `1`                    | Enemy damage multiplier                            | number                             |
| `ENSHROUDED_ENEMY_HEALTH_FACTOR`              | `1`                    | Enemy health multiplier                            | number                             |
| `ENSHROUDED_ENEMY_STAMINA_FACTOR`             | `1`                    | Enemy stamina multiplier                           | number                             |
| `ENSHROUDED_ENEMY_PERCEPTION_RANGE_FACTOR`    | `1`                    | Enemy perception range multiplier                  | number                             |
| `ENSHROUDED_BOSS_DAMAGE_FACTOR`               | `1`                    | Boss damage multiplier                             | number                             |
| `ENSHROUDED_BOSS_HEALTH_FACTOR`               | `1`                    | Boss health multiplier                             | number                             |
| `ENSHROUDED_THREAT_BONUS`                     | `1`                    | Threat/aggro generation multiplier                 | number                             |
| `ENSHROUDED_PACIFY_ALL_ENEMIES`               | `false`                | Disable all enemy aggression                       | true, false                        |
| `ENSHROUDED_TAMING_STARTLE_REPERCUSSION`      | `LoseSomeProgress`     | Result of startling an animal while taming         | LoseSomeProgress, LoseAllProgress, KeepProgress |
| `ENSHROUDED_DAY_TIME_DURATION`                | `1800000000000`        | Length of daytime (nanoseconds)                    | integer                            |
| `ENSHROUDED_NIGHT_TIME_DURATION`              | `720000000000`         | Length of nighttime (nanoseconds)                  | integer                            |
| `ENSHROUDED_CURSE_MODIFIER`                   | `Normal`               | Curse intensity modifier                           | Disabled, Rare, Normal, Often      |
