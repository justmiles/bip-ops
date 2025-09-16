# Subsistence Server

This directory contains the configuration and scripts for running a Subsistence game server using BipOps.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=subsistence \
  -e SUBSISTENCE_SERVER_NAME="BipOps Subsistence Server" \
  -e SUBSISTENCE_PASSWORD=password \
  -e SUBSISTENCE_HUNTERS_ENABLED=false \
  -p 7777:7777/udp \
  -p 27015:27015/udp \
  -v /path/to/gameservers/subsistence/game:/game \
  -v /path/to/gameservers/subsistence/backups:/backups \
  justmiles/bip-ops
```

## Required Ports

| Port  | Protocol | Description      |
| ----- | -------- | ---------------- |
| 7777  | UDP      | Game server port |
| 27015 | UDP      | Steam query port |

## Volume Mounts

| Host Path                                | Container Path | Description            |
| ---------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/subsistence/game    | /game          | Game files directory   |
| /path/to/gameservers/subsistence/backups | /backups       | Backup files directory |

## Environment Variables

| Variable                                               | Default                   | Description                                                                                       |
| ------------------------------------------------------ | ------------------------- | ------------------------------------------------------------------------------------------------- |
| BIPOPS_GAMESERVER                                      | (required)                | Must be set to "subsistence"                                                                      |
| BIPOPS_VALIDATE_SERVER_FILES                           | true                      | Validate server files are up to date before launching server instance                             |
| SUBSISTENCE_PROFILE_ID                                 | 1                         | Must be a value between 1 to 5. Can be used to store 5 separate saves on a single server instance |
| SUBSISTENCE_HUNTERS_ENABLED                            | true                      | Whether hunters are enabled (true/false)                                                          |
| SUBSISTENCE_HUNTERS_ATTACKS                            | 0                         | Hunter attack behavior: 0 = normal attacks, 1 = only revenge attacks, 2 = no attacks              |
| SUBSISTENCE_DIFFICULTY                                 | normal                    | Game difficulty: easy/normal/hardcore                                                             |
| SUBSISTENCE_DAYS_PER_YEAR                              | 24                        | Number of in-game days per in-game year. Options: 12/24/36/48/60/90/120/200/365                   |
| SUBSISTENCE_MONTH_OVERRIDE                             | -1                        | Start server in a specific month: Jan=0, Feb=1, March=2, etc. (-1 to use save file value)         |
| SUBSISTENCE_PASSWORD                                   | password                  | Password that players must use to join the server. Leave blank to allow anyone to join            |
| SUBSISTENCE_ADMIN_PASSWORD                             | (none)                    | Password that admins should use to login to the server                                            |
| SUBSISTENCE_SERVER_NAME                                | BipOps Subsistence Server | The name that will show in the in-game server list (max 64 characters)                            |
| SUBSISTENCE_SERVER_DESCRIPTION                         | (none)                    | Optional short description of the server (max 256 characters)                                     |
| SUBSISTENCE_HOSTED_BY_NAME                             | BipOps                    | The name that will show as server host in the in-game server list (max 64 characters)             |
| SUBSISTENCE_MAX_PLAYERS                                | 32                        | The maximum player slots on the server (1 to 32)                                                  |
| SUBSISTENCE_NUM_PLAYER_OFFLINE_HOURS_BEFORE_BASE_DECAY | 0                         | Hours before player bases start to decay when offline (0 = no decay)                              |
| SUBSISTENCE_PVP_DAMAGE                                 | true                      | If true, players can damage other players                                                         |
| SUBSISTENCE_PLAYERS_CAN_DAMAGE_PLAYER_BASES            | true                      | If true, players can damage player-placed buildables                                              |
| SUBSISTENCE_OFFLINE_BASE_PROTECTION                    | true                      | If true, player bases are protected from damage while players are offline                         |
| SUBSISTENCE_PLAYERS_CAN_ACCESS_ENEMY_PLAYER_BASE_ITEMS | true                      | If true, players can access enemy player base items                                               |
