# VEIN Server

This directory contains the configuration and scripts for running a VEIN game server using BipOps.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=vein \
  -e VEIN_SERVER_NAME="BipOps VEIN Server" \
  -e VEIN_SERVER_DESCRIPTION="BipOps VEIN Server" \
  -e VEIN_PASSWORD=yourpassword \
  -p 7777:7777/udp \
  -p 27015:27015/udp \
  -v /path/to/gameservers/vein/game:/game \
  -v /path/to/gameservers/vein/backups:/backups \
  justmiles/bip-ops
```

## Required Ports

| Port  | Protocol | Description      |
| ----- | -------- | ---------------- |
| 7777  | UDP      | Game connection  |
| 27015 | UDP      | Steam query port |

## Volume Mounts

| Host Path                         | Container Path | Description            |
| --------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/vein/game    | /game          | Game files directory   |
| /path/to/gameservers/vein/backups | /backups       | Backup files directory |

## Environment Variables

Below is a comprehensive list of all available configuration options for the VEIN server:

### Game Session Settings

| Variable                | Default                    | Description                                                 |
| ----------------------- | -------------------------- | ----------------------------------------------------------- |
| VEIN_MAX_PLAYERS        | 16                         | Maximum number of players that can join the server          |
| VEIN_PUBLIC             | True                       | Whether the server is publicly listed in the server browser |
| VEIN_SERVER_NAME        | Vein Server                | Server name displayed in the server browser                 |
| VEIN_SERVER_DESCRIPTION | A server. You can join it. | Server description displayed in the server browser          |
| VEIN_BIND_ADDR          | 0.0.0.0                    | IP address the server binds to                              |
| VEIN_PASSWORD           | secret                     | Password required to join the server (leave empty for none) |
| VEIN_HEARTBEAT_INTERVAL | 5.0                        | Heartbeat interval in seconds                               |

### Admin Settings

| Variable                   | Default | Description                                                      |
| -------------------------- | ------- | ---------------------------------------------------------------- |
| VEIN_SUPER_ADMIN_STEAM_IDS |         | Steam ID64s of super admins (can grant/revoke admin privileges)  |
| VEIN_ADMIN_STEAM_IDS       |         | Steam ID64s of regular admins                                    |
| VEIN_WHITELISTED_PLAYERS   |         | Steam ID64s of whitelisted players (if set, only these can join) |

**Note:** For multiple Steam IDs, use the format: `steamid1,steamid2,steamid3`

You can find your Steam ID64 at [steamid.io](https://steamid.io/).

### Network Settings

| Variable         | Default | Description                                          |
| ---------------- | ------- | ---------------------------------------------------- |
| VEIN_PORT        | 7777    | Main game port                                       |
| VEIN_QUERY_PORT  | 27015   | Steam query port for server browser                  |
| VEIN_VAC_ENABLED | 0       | Enable/disable Steam VAC (1 = enabled, 0 = disabled) |

### Gameplay Settings

| Variable                | Default | Description                         |
| ----------------------- | ------- | ----------------------------------- |
| VEIN_PVP                | True    | Enable/disable PvP combat           |
| VEIN_AI_SPAWNER_ENABLED | True    | Enable/disable AI enemy spawning    |
| VEIN_TIME_MULTIPLIER    | 16      | Time multiplier for day/night cycle |

### AI and Zombie Settings

| Variable                                    | Default      | Description                                                |
| ------------------------------------------- | ------------ | ---------------------------------------------------------- |
| VEIN_AI_ASYNC_SENSING                       | 1.000000     | Compute sight from AI asynchronously                       |
| VEIN_AI_SPAWNER_ENABLE_VIRTUALIZATION       | 1.000000     | Enable/disable AI virtualization                           |
| VEIN_AI_SPAWNER_FIELD_OF_VIEW_DOT           | 0.000000     | Player's field of view dot product (-1 to 1)               |
| VEIN_AI_SPAWNER_HORDE_MODE                  | 0.000000     | Enable/disable horde mode                                  |
| VEIN_AI_SPAWNER_HORDES_CHANCE_PER_MINUTE    | 0.050000     | Number of hordes spawned per minute                        |
| VEIN_AI_SPAWNER_HORDES_DURATION             | 120.000000   | Duration of a horde event in seconds                       |
| VEIN_AI_SPAWNER_HORDE_ENABLED               | 1.000000     | Enable/disable horde spawning                              |
| VEIN_AI_SPAWNER_HORDES_MAX_DISTANCE         | 25000.000000 | Maximum distance before horde event ends                   |
| VEIN_AI_SPAWNER_HORDES_NOISE_EFFECT         | 0.100000     | Likelihood of hordes from noise (higher = more likely)     |
| VEIN_AI_SPAWNER_HORDES_SCENT_EFFECT         | 0.500000     | Likelihood of hordes from bad smells                       |
| VEIN_AI_SPAWNER_SPAWN_CAP_MULTIPLIER        | 1.000000     | Spawn cap multiplier for all AI                            |
| VEIN_AI_SPAWNER_SPAWN_CAP_MULTIPLIER_ZOMBIE | 1.000000     | Spawn cap multiplier specifically for zombies              |
| VEIN_AI_SPAWNER_ZOMBIE_CRAWLER_PERCENTAGE   | 0.100000     | Fraction of zombies that are crawlers                      |
| VEIN_AI_SPAWNER_ZOMBIE_LAYER_PERCENTAGE     | 0.100000     | Fraction of zombies that start asleep                      |
| VEIN_AI_SPAWNER_ZOMBIE_WALKER_PERCENTAGE    | 0.700000     | Fraction of zombies that are walkers                       |
| VEIN_ALWAYS_BECOME_ZOMBIE                   | 0.000000     | Characters become zombies on death regardless of infection |
| VEIN_ZOMBIE_INFECTION_CHANCE                | 0.010000     | Probability of infection from zombie attacks               |
| VEIN_ZOMBIES_ANIMATE_YELL                   | 0.000000     | Zombies' mouths open when they yell                        |
| VEIN_ZOMBIES_CAN_CLIMB                      | 1.000000     | Enable/disable zombie climbing ability                     |
| VEIN_ZOMBIES_DAMAGE_MULTIPLIER              | 1.000000     | Multiplier for zombie damage                               |
| VEIN_ZOMBIES_ENABLE_TICK_OPTIMIZATION       | 0.000000     | Slow-update distant zombies                                |
| VEIN_ZOMBIES_HEADSHOT_ONLY                  | 0.000000     | Zombies only take damage from headshots                    |
| VEIN_ZOMBIES_HEALTH                         | 40.000000    | Base health for zombies                                    |
| VEIN_ZOMBIES_HEARING_MULTIPLIER             | 1.000000     | Multiplier for zombie hearing ability                      |
| VEIN_ZOMBIES_LAYING_DOWN_DISTANCE           | 500.000000   | Distance for zombies to "wake up"                          |
| VEIN_ZOMBIES_NAV_WALK                       | 1.000000     | Use nav walking for zombies                                |
| VEIN_ZOMBIES_SIGHT_MULTIPLIER               | 1.000000     | Multiplier for zombie sight ability                        |
| VEIN_ZOMBIES_SPEED_MULTIPLIER               | 1.000000     | Multiplier for zombie movement speed                       |

### World Settings

| Variable                                   | Default      | Description                                                      |
| ------------------------------------------ | ------------ | ---------------------------------------------------------------- |
| VEIN_CALENDAR_ELECTRICAL_SHUTOFF_TIME_DAYS | 46.000000    | Days until electricity is shut off                               |
| VEIN_CALENDAR_WATER_SHUTOFF_TIME_DAYS      | 30.000000    | Days until water is shut off                                     |
| VEIN_TIME_CONTINUE_WITH_NO_PLAYERS         | 0.000000     | Time continues when no players are on server                     |
| VEIN_TIME_NIGHT_TIME_MULTIPLIER            | 3.000000     | How much faster nighttime runs compared to daytime               |
| VEIN_TIME_NIGHT_TIME_MULTIPLIER_END        | 6.000000     | Hour (24h) when night multiplier ends                            |
| VEIN_TIME_NIGHT_TIME_MULTIPLIER_START      | 20.000000    | Hour (24h) when night multiplier starts                          |
| VEIN_TIME_START_OFFSET_DAYS                | 0.000000     | Days to offset at game start                                     |
| VEIN_SCARCITY_DIFFICULTY                   | 2.000000     | Loot scarcity (0=None, 1=More, 2=Standard, 3=Less, 4=Impossible) |
| VEIN_CONTAINERS_RESPAWN_ENABLED            | 1.000000     | Empty containers respawn items                                   |
| VEIN_CONTAINERS_RESPAWN_INTERVAL           | 10800.000000 | Seconds between container respawns                               |
| VEIN_ITEM_ACTOR_SPAWNER_RESPAWN_INTERVAL   | 3600.000000  | Item actor spawner respawn interval                              |
| VEIN_ITEM_ACTOR_SPAWNER_RESPAWNS           | 1.000000     | Enable item actor spawner respawns                               |

### Player Settings

| Variable                                     | Default    | Description                                |
| -------------------------------------------- | ---------- | ------------------------------------------ |
| VEIN_CHARACTERS_MAX                          | 100.000000 | Maximum characters per player              |
| VEIN_HEADSHOT_DAMAGE_MULTIPLIER              | 1.000000   | Damage multiplier for headshots            |
| VEIN_PERMADEATH                              | 0.000000   | Players cannot respawn if enabled          |
| VEIN_NO_SAVES                                | 0.000000   | Disable player saving                      |
| VEIN_STATS_XP_MULTIPLIER                     | 1.000000   | XP gain multiplier                         |
| VEIN_CLOTHING_HIDEABLE                       | 0.000000   | Allow players to hide clothes for roleplay |
| VEIN_PERSISTENT_CORPSES                      | 1.000000   | Enable persistent corpses                  |
| VEIN_PERSISTENT_CORPSES_CORPSE_REMOVAL_DELAY | 120.000000 | Seconds before corpse removal              |

### Base Building Settings

| Variable                                    | Default     | Description                                   |
| ------------------------------------------- | ----------- | --------------------------------------------- |
| VEIN_BASE_DAMAGE                            | 1.000000    | Enable base damage                            |
| VEIN_BUILD_OBJECT_DECAY                     | 1.000000    | Enable build object decay                     |
| VEIN_BUILD_OBJECT_PVP                       | 1.000000    | Allow players to damage other players' bases  |
| VEIN_CONSTRUCTION_CONTINUE_BUILDING         | 1.000000    | Continue building without holding shift       |
| VEIN_PLACEMENT_MAX_PLACEMENT_ATTACH_PARENTS | 5.000000    | Maximum attachment chain when placing objects |
| VEIN_RESPAWNABLE_DESTRUCTION_ENABLED        | 1.000000    | Enable furniture respawning                   |
| VEIN_FURNITURE_PHYSICAL_FALL                | 1.000000    | Furniture physically falls to ground          |
| VEIN_FURNITURE_RESPAWN_RATE                 | 3000.000000 | Seconds to respawn furniture                  |

### Vehicle Settings

| Variable                                         | Default      | Description                                     |
| ------------------------------------------------ | ------------ | ----------------------------------------------- |
| VEIN_VEHICLES_BASE_WHEEL_FRICTION                | 6.000000     | Base wheel friction for vehicles                |
| VEIN_VEHICLES_BASE_WHEEL_FRICTION_HANDBRAKE      | 1.500000     | Wheel friction multiplier when handbrake active |
| VEIN_VEHICLES_BASE_WHEEL_MAX_BRAKE_TORQUE        | 15000.000000 | Brake torque                                    |
| VEIN_VEHICLES_BASE_WHEEL_MAX_HAND_BRAKE_TORQUE   | 1.300000     | Brake torque handbrake multiplier               |
| VEIN_VEHICLES_FLAT_TIRE_WOBBLE_AMPLITUDE         | 0.100000     | Wobble amplitude with flat tire                 |
| VEIN_VEHICLES_NEARBY_KEY_SPAWN_CHANCE            | 0.800000     | Chance of keys spawning near locked cars        |
| VEIN_VEHICLES_ZOMBIE_KEY_SPAWN_CHANCE            | 0.100000     | Chance of keys spawning on zombies              |
| VEIN_VEHICLES_OPTIMIZATIONS_ANIMATION            | 1.000000     | Enable vehicle animation optimization           |
| VEIN_VEHICLES_OPTIMIZATIONS_PHYSICS              | 1.000000     | Enable vehicle physics optimization             |
| VEIN_VEHICLES_OPTIMIZATIONS_PHYSICS_MAX_VELOCITY | 50.000000    | Velocity threshold for physics freezing         |
| VEIN_VEHICLES_OPTIMIZATIONS_TICK                 | 1.000000     | Enable vehicle tick optimization                |
| VEIN_VEHICLES_OUTGOING_PLAYER_DAMAGE             | 1.000000     | Vehicles damage players on collision            |

### Server Display Settings

| Variable                    | Default | Description                                          |
| --------------------------- | ------- | ---------------------------------------------------- |
| VEIN_SHOW_SCOREBOARD_BADGES | 1       | Show admin badges on scoreboard (1 = show, 0 = hide) |

### Integration Settings

| Variable                 | Example                                              | Description                                                                                                                                |
| ------------------------ | ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| VEIN_DISCORD_WEBHOOK_URL | https://discord.com/api/webhooks/url-that-you-copied | Discord webhook URL for chat integration. See [docs](https://ramjet.notion.site/Discord-Chat-Integration-279f9ec29f178075bca4f55f13eb3128) |

## Server Administration

### Adding Admins

To add administrators to your server, you need their Steam ID64:

1. Go to [steamid.io](https://steamid.io/)
2. Enter their Steam profile URL or Steam username
3. Copy their Steam ID64 (the long number)
4. Add it to either `VEIN_ADMIN_STEAM_IDS` or `VEIN_SUPER_ADMIN_STEAM_IDS`

**Super Admins** have the additional ability to grant/revoke admin privileges in-game, while **Regular Admins** have standard administrative powers.

### Whitelisting Players

To create a private server with only specific players allowed:

1. Set `VEIN_WHITELISTED_PLAYERS` to the Steam ID64s of allowed players
2. Use the format: `steamid1+steamid2+steamid3` for multiple players
3. If this variable has any entries, only whitelisted players can join

## Steam Integration

The server integrates with Steam for:

- Server browser listing (when `VEIN_PUBLIC=True`)
- Player validation and authentication
- VAC anti-cheat (when `VEIN_VAC_ENABLED=1`)
- Steam ID-based admin/whitelist system

Make sure the Steam query port (default: 27015) is properly forwarded for server browser visibility.

## Discord Integration

To integrate with Discord:

1. Create a Discord webhook in your server channel
2. Copy the webhook URL
3. Set `VEIN_DISCORD_WEBHOOK_URL` to your webhook URL
4. The server will send chat messages and events to your Discord channel

For more information about VEIN dedicated servers, visit the [official documentation](https://ramjet.notion.site/dedicated-servers).
