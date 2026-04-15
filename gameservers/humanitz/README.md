# HumanitZ Server

This directory contains the configuration and scripts for running a HumanitZ dedicated game server using BipOps.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=humanitz \
  -e HUMANITZ_SERVER_NAME="My HumanitZ Server" \
  -e HUMANITZ_ADMIN_PASS=youradminpassword \
  -e HUMANITZ_RCON_ENABLED=true \
  -e HUMANITZ_RCON_PASS=yourrconpassword \
  -p 7777:7777/udp \
  -p 27015:27015/udp \
  -p 8888:8888/tcp \
  -v /path/to/game:/game \
  -v /path/to/backups:/backups \
  justmiles/bip-ops
```

## Required Ports

| Port  | Protocol | Description       |
| ----- | -------- | ----------------- |
| 7777  | UDP      | Game connection   |
| 27015 | UDP      | Steam query port  |
| 8888  | TCP      | RCON              |

> **Note:** RCON must be enabled (`HUMANITZ_RCON_ENABLED=true`) for server ping to display correctly in the server browser.

## Volume Mounts

| Host Path              | Container Path | Description            |
| ---------------------- | -------------- | ---------------------- |
| /path/to/game          | /game          | Game files directory   |
| /path/to/backups       | /backups       | Backup files directory |

## Environment Variables

### Host Settings

| Variable | Default | Description |
| --- | --- | --- |
| HUMANITZ_SERVER_NAME | `HumanitZ [BipOps]` | Server name. Avoid using "Official" or the server may not start |
| HUMANITZ_PASSWORD | `""` | Server password (empty = no password) |
| HUMANITZ_SAVE_NAME | `DedicatedSaveMP` | Save file name |
| HUMANITZ_SEARCH_ID | `HumanitZ_Dedicated` | Server browser bucket ID. Changing this hides the server from the default list |
| HUMANITZ_ADMIN_PASS | `""` | Password for in-game admin access via `/adminaccess <password>` |
| HUMANITZ_MAX_PLAYERS | `16` | Maximum number of players |
| HUMANITZ_RESERVE_SLOTS | `0` | Reserved player slots (add NetIDs to `F_ReservedSlots.txt`) |
| HUMANITZ_RCON_ENABLED | `true` | Enable RCON (recommended, needed for ping display) |
| HUMANITZ_RCON_PORT | `8888` | RCON TCP port |
| HUMANITZ_RCON_PASS | `""` | RCON password |
| HUMANITZ_NO_DEATH_FEEDBACK | `true` | Hide death notifications from non-admins |
| HUMANITZ_NO_JOIN_FEEDBACK | `true` | Hide join/leave notifications from non-admins |
| HUMANITZ_LIMITED_SPAWNS | `false` | Limit spawns to coast/spawn points only |
| HUMANITZ_USE_GLOBAL_BAN_LIST | `true` | Reject players on the official ban list |

### World Settings

| Variable | Default | Description |
| --- | --- | --- |
| HUMANITZ_XP_MULTIPLIER | `1` | Experience multiplier (2 = double XP, 0.5 = half) |
| HUMANITZ_SAVE_INTERVAL | `300` | Auto-save interval in seconds (0 = disable) |
| HUMANITZ_PERMA_DEATH | `false` | Lose character on death |
| HUMANITZ_ON_DEATH | `2` | Death penalty: 0=Nothing, 1=Backpack+weapon, 2=+pockets, 3=+equipment |
| HUMANITZ_RESPAWN_TIMER | `15` | Seconds before respawn after death |
| HUMANITZ_PVP | `true` | Enable PVP and player item interaction |
| HUMANITZ_LOGOUT_TIMER | `30` | Seconds before logout allowed in PVP (0 = disable) |
| HUMANITZ_AIR_DROP | `true` | Enable air drops |
| HUMANITZ_AIR_DROP_INTERVAL | `1` | Game days between air drops |
| HUMANITZ_WEAPON_BREAK | `true` | Weapons break at 0% durability |
| HUMANITZ_MAX_OWNED_CARS | `2` | Max cars a player can own |
| HUMANITZ_MULTIPLAYER_SLEEP | `false` | Allow time-skip when all players sleep |
| HUMANITZ_LOOT_RESPAWN | `true` | Enable loot respawning |
| HUMANITZ_LOOT_RESPAWN_TIMER | `60` | Loot container respawn time in minutes |
| HUMANITZ_PICKUP_RESPAWN_TIMER | `90` | Pickup item respawn time in minutes |

### Loot Rarity Settings

Rarity values: 0=Scarce, 1=Low, 2=Default, 3=Plentiful, 4=Abundant

| Variable | Default | Description |
| --- | --- | --- |
| HUMANITZ_RARITY_FOOD | `2` | Food spawn rarity |
| HUMANITZ_RARITY_DRINK | `2` | Drink spawn rarity |
| HUMANITZ_RARITY_MELEE | `2` | Melee weapon spawn rarity |
| HUMANITZ_RARITY_RANGED | `2` | Ranged weapon spawn rarity |
| HUMANITZ_RARITY_AMMO | `2` | Ammunition spawn rarity |
| HUMANITZ_RARITY_ARMOR | `2` | Armor spawn rarity |
| HUMANITZ_RARITY_RESOURCES | `2` | Resource spawn rarity |
| HUMANITZ_RARITY_OTHER | `2` | Other items spawn rarity |

### Enemy Settings

Difficulty values: 0=Very Easy, 1=Easy, 2=Default, 3=Hard, 4=Very Hard, 5=Nightmare

| Variable | Default | Description |
| --- | --- | --- |
| HUMANITZ_ZOMBIE_DIFF_HEALTH | `1` | Zombie health difficulty |
| HUMANITZ_ZOMBIE_DIFF_SPEED | `2` | Zombie speed difficulty |
| HUMANITZ_ZOMBIE_DIFF_DAMAGE | `3` | Zombie damage difficulty |
| HUMANITZ_ZOMBIE_AMOUNT_MULTI | `1` | Zombie count multiplier |
| HUMANITZ_ZOMBIE_DOG_MULTI | `1` | Zombie dog count multiplier |
| HUMANITZ_ZOMBIE_RESPAWN_TIMER | `90` | Zombie respawn time in minutes (0 = disable) |
| HUMANITZ_HUMAN_AMOUNT_MULTI | `1` | Human bandit count multiplier |
| HUMANITZ_HUMAN_RESPAWN_TIMER | `90` | Human bandit respawn time in minutes (0 = disable) |
| HUMANITZ_HUMAN_HEALTH | `2` | Human bandit health difficulty |
| HUMANITZ_HUMAN_SPEED | `2` | Human bandit speed difficulty |
| HUMANITZ_HUMAN_DAMAGE | `2` | Human bandit damage difficulty |
| HUMANITZ_ANIMAL_MULTI | `1` | Animal spawn multiplier |
| HUMANITZ_ANIMAL_RESPAWN_TIMER | `90` | Animal respawn time in minutes (0 = disable) |
| HUMANITZ_AI_EVENT | `2` | AI raid frequency: 0=Disabled, 1=Low, 2=Default, 3=High, 4=Insane |

### Time & Season Settings

Season values: 0=Summer, 1=Autumn, 2=Winter, 3=Spring

| Variable | Default | Description |
| --- | --- | --- |
| HUMANITZ_STARTING_SEASON | `1` | Starting season |
| HUMANITZ_DAYS_PER_SEASON | `5` | Game days per season |
| HUMANITZ_DAY_DURATION | `40` | Day duration in minutes |
| HUMANITZ_NIGHT_DURATION | `20` | Night duration in minutes |
| HUMANITZ_VITAL_DRAIN | `1` | Vital drain speed: 0=Slow, 1=Normal, 2=Fast |
| HUMANITZ_FREEZE_TIME | `true` | Freeze time when server is empty |

### Dog Companion Settings

| Variable | Default | Description |
| --- | --- | --- |
| HUMANITZ_DOG_ENABLED | `true` | Enable dog companions in the world |
| HUMANITZ_RECRUIT_DOG | `true` | Allow players to recruit dogs |
| HUMANITZ_DOG_NUM | `8` | Max dog companions in the world |
| HUMANITZ_COMPANION_HEALTH | `1` | Dog companion health: 0=Low, 1=Default, 2=High |
| HUMANITZ_COMPANION_DMG | `1` | Dog companion damage: 0=Low, 1=Default, 2=High |

### Building Settings

| Variable | Default | Description |
| --- | --- | --- |
| HUMANITZ_BUILDING_HEALTH | `1` | Building health multiplier |
| HUMANITZ_ALLOW_DISMANTLE | `true` | Allow dismantling own buildings |
| HUMANITZ_ALLOW_HOUSE_DISMANTLE | `true` | Allow dismantling house props |
| HUMANITZ_TERRITORY | `true` | Prevent building in others' spawn area |
| HUMANITZ_FREE_BUILD | `true` | Skip foundation requirement (experimental) |
| HUMANITZ_NO_BUILD_ZONE | `true` | Enforce no-build zones |
| HUMANITZ_DECAY | `7` | Real days for spawn point to decay from 100% to gone |
| HUMANITZ_BUILDING_DECAY | `7` | Real days for unprotected buildings to fully decay (0 = disable) |
| HUMANITZ_PICKUP_CLEANUP | `6` | Game days before dropped items are cleaned up (0 = disable) |
| HUMANITZ_FAKE_BUILDING_CLEANUP | `3000` | Minutes before blueprint buildings are cleaned up (0 = disable) |
| HUMANITZ_FOOD_DECAY | `1` | Food decay multiplier (0 = disable, 0.5 = half speed) |
| HUMANITZ_GEN_FUEL | `1` | Generator fuel consumption multiplier |
| HUMANITZ_RECYCLE_CAR | `14` | Real days before claimed cars are recycled (0 = disable) |
| HUMANITZ_SLEEP | `true` | Enable sleep deprivation effects |

### Map & Performance Settings

| Variable | Default | Description |
| --- | --- | --- |
| HUMANITZ_MAP_SEG0 | `12` | Map grid segmentation for houses/major objects |
| HUMANITZ_MAP_SEG1 | `20` | Map grid segmentation for cars/secondary objects |
| HUMANITZ_MAP_SEG2 | `60` | Map grid segmentation for minor objects |
| HUMANITZ_VOIP | `true` | Enable voice chat |

### Weather Settings

Odds multiplier for each weather type. Season still dictates which types can spawn.

| Variable | Default | Description |
| --- | --- | --- |
| HUMANITZ_WEATHER_CLEAR_SKY | `1` | Clear sky odds |
| HUMANITZ_WEATHER_CLOUDY | `1` | Cloudy odds |
| HUMANITZ_WEATHER_FOGGY | `1` | Foggy odds |
| HUMANITZ_WEATHER_LIGHT_RAIN | `1` | Light rain odds |
| HUMANITZ_WEATHER_RAIN | `1` | Rain odds |
| HUMANITZ_WEATHER_THUNDERSTORM | `1` | Thunderstorm odds |
| HUMANITZ_WEATHER_LIGHT_SNOW | `1` | Light snow odds |
| HUMANITZ_WEATHER_SNOW | `1` | Snow odds |
| HUMANITZ_WEATHER_BLIZZARD | `1` | Blizzard odds |

## Server Administration

### In-Game Admin Commands

Use `/adminaccess <password>` in-game to gain admin privileges (using the `HUMANITZ_ADMIN_PASS` value).

Common admin commands:
- `/Shutdown <seconds>` — Shut down server with countdown
- `/SuperAdmin` — Toggle fly/invisible mode
- `/Spawn item_<Name>` — Spawn items
- `/SaveGame` — Force save
- `/god` — Toggle god mode
- `/adminw` — Admin utility UI
- `/weather <type>` — Change weather
- `/season <type>` — Change season

### RCON Commands

Connect to the RCON port (default: 8888/TCP) using any Valve-compatible RCON client.

- `info` — Get current world info
- `Players` — List connected players
- `kick <SteamID>` — Kick a player
- `ban <SteamID>` — Ban a player
- `unban <SteamID>` — Unban a player
- `QuickRestart` — Restart in 1 minute
- `RestartNow` — Restart immediately
- `CancelRestart` — Cancel pending restart
- `restart <minutes>` — Restart in X minutes
- `shutdown` — Shut down server
- `admin <message>` — Send admin chat message
- `season <name>` — Change season (spring/summer/autumn/winter)
- `weather <type>` — Change weather (clear/partly_cloudy/overcast/foggy/light_rain/rain/thunder/light_snow/snow/blizzard)

For more information, see the [HumanitZ Wiki](https://humanitz.wiki.gg/wiki/Private_Server_Hosting_Setup).
