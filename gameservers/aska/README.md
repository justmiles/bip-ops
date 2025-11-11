# Aska Server

This directory contains the configuration and scripts for running an Aska game server using BipOps.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=aska \
  -e ASKA_SERVER_NAME="BipOps Aska Server" \
  -e ASKA_AUTH_TOKEN=your_steam_auth_token \
  -e ASKA_PASSWORD=yourpassword \
  -e ASKA_STEAM_GAME_PORT=27015 \
  -e ASKA_STEAM_QUERY_PORT=27016 \
  -p 27015:27015/udp \
  -p 27015:27015/tcp \
  -p 27016:27016/udp \
  -v /path/to/gameservers/aska/game:/game \
  -v /path/to/gameservers/aska/backups:/backups \
  justmiles/bip-ops
```

## Required Ports

| Port  | Protocol | Description      |
| ----- | -------- | ---------------- |
| 27015 | UDP/TCP  | Steam game port  |
| 27016 | UDP      | Steam query port |

## Volume Mounts

| Host Path                         | Container Path | Description            |
| --------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/aska/game    | /game          | Game files directory   |
| /path/to/gameservers/aska/backups | /backups       | Backup files directory |

## Environment Variables

Below is a comprehensive list of all available configuration options for the Aska server:

### Core Server Settings

| Variable              | Default           | Description                                                                                                                                                                             |
| --------------------- | ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ASKA_AUTH_TOKEN       | ""                | **Required** Steam authentication token from https://steamcommunity.com/dev/managegameservers                                                                                           |
| ASKA_SERVER_NAME      | "My Aska Server"  | Name that shows in the server browser                                                                                                                                                   |
| ASKA_DISPLAY_NAME     | "Default Session" | Session name displayed in the session list                                                                                                                                              |
| ASKA_PASSWORD         | ""                | Password required for server login (optional)                                                                                                                                           |
| ASKA_STEAM_GAME_PORT  | 27015             | Steam game port number                                                                                                                                                                  |
| ASKA_STEAM_QUERY_PORT | 27016             | Steam query port number                                                                                                                                                                 |
| ASKA_REGION           | "default"         | Server region (default, asia, japan, europe, south america, south korea, usa east, usa west, australia, canada east, hong kong, india, turkey, united arab emirates, usa south central) |
| ASKA_SAVE_ID          | ""                | Load specific save file (comes after "savegame\_")                                                                                                                                      |
| ASKA_SEED             | ""                | World generation seed                                                                                                                                                                   |

### Server Behavior Settings

| Variable              | Default         | Description                                                                                                     |
| --------------------- | --------------- | --------------------------------------------------------------------------------------------------------------- |
| ASKA_KEEP_WORLD_ALIVE | "false"         | Keep world updating even without players (true/false)                                                           |
| ASKA_AUTOSAVE_STYLE   | "every morning" | Save frequency (every morning, disabled, every 5 minutes, every 10 minutes, every 15 minutes, every 20 minutes) |
| ASKA_MODE             | "normal"        | Game mode (normal/custom) - custom enables advanced settings                                                    |

### Custom Mode Settings (Only works when ASKA_MODE="custom")

| Variable                  | Default   | Description                                                  |
| ------------------------- | --------- | ------------------------------------------------------------ |
| ASKA_TERRAIN_ASPECT       | "normal"  | Terrain smoothness (smooth, normal, rocky)                   |
| ASKA_TERRAIN_HEIGHT       | "normal"  | Terrain height variation (flat, normal, varied)              |
| ASKA_STARTING_SEASON      | "spring"  | Starting season (spring, summer, autumn, winter)             |
| ASKA_YEAR_LENGTH          | "default" | Year duration (minimum, reduced, default, extended, maximum) |
| ASKA_PRECIPITATION        | "3"       | Weather intensity (0=sunny to 6=soggy)                       |
| ASKA_DAY_LENGTH           | "default" | Day duration (minimum, reduced, default, extended, maximum)  |
| ASKA_STRUCTURE_DECAY      | "medium"  | Building decay rate (low, medium, high)                      |
| ASKA_CLOTHING_DECAY       | "medium"  | Clothing decay rate (low, medium, high)                      |
| ASKA_INVASION_DIFFICULTY  | "normal"  | Invasion challenge level (off, easy, normal, hard)           |
| ASKA_MONSTER_DENSITY      | "medium"  | Monster spawn density (off, low, medium, high)               |
| ASKA_MONSTER_POPULATION   | "medium"  | Monster population level (low, medium, high)                 |
| ASKA_WULFAR_POPULATION    | "medium"  | Wulfar population level (low, medium, high)                  |
| ASKA_HERBIVORE_POPULATION | "medium"  | Herbivore population level (low, medium, high)               |
| ASKA_BEAR_POPULATION      | "medium"  | Bear population level (low, medium, high)                    |

### Additional Settings

| Variable             | Default | Description                                      |
| -------------------- | ------- | ------------------------------------------------ |
| ASKA_ADDITIONAL_ARGS | ""      | Additional command line arguments for the server |

## Server Administration

### Steam Authentication Token

**Important**: You must obtain a Steam authentication token before running the server:

1. Visit https://steamcommunity.com/dev/managegameservers
2. Create a new game server account
3. Use App ID: **1898300** (for Aska base game)
4. Copy the generated token and set it as `ASKA_AUTH_TOKEN`

Without this token, your server will not be able to authenticate with Steam and players won't be able to connect.
