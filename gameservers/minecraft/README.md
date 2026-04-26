# Minecraft Server

This directory contains the configuration and scripts for running a Minecraft Java Edition dedicated server using BipOps.

> **Note:** Minecraft is a non-Steam game. The server JAR is downloaded directly from Mojang's version manifest API during the update-game phase. Java 21 is provided via devbox.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=minecraft \
  -e MINECRAFT_EULA=true \
  --memory=4g \
  -p 25565:25565/tcp \
  -v /path/to/game:/game \
  -v /path/to/backups:/backups \
  justmiles/bipops
```

## Required Ports

| Port  | Protocol | Description           |
| ----- | -------- | --------------------- |
| 25565 | TCP      | Game connection       |
| 25575 | TCP      | RCON (if enabled)     |
| 25565 | UDP      | Query (if enabled)    |

## Volume Mounts

| Host Path        | Container Path | Description            |
| ---------------- | -------------- | ---------------------- |
| /path/to/game    | /game          | Game files directory   |
| /path/to/backups | /backups       | Backup files directory |

## Environment Variables

### Server Version & Runtime

| Variable              | Default                           | Description                                                                 |
| --------------------- | --------------------------------- | --------------------------------------------------------------------------- |
| MINECRAFT_VERSION     | `latest`                          | Server version to install (e.g., `1.21.4` or `latest`)                     |
| MINECRAFT_EULA        | `true`                            | Accept the Minecraft EULA                                                   |
| MINECRAFT_JAVA_ARGS   | _(container-aware G1GC defaults)_ | JVM arguments (overrides all defaults including memory flags)               |

### Memory Management

Memory is managed automatically using container-aware JVM flags:

- `-XX:+UseContainerSupport` — JVM reads cgroup memory limits (default in JDK 17+)
- `-XX:MaxRAMPercentage=75.0` — Uses 75% of container memory limit for max heap
- `-XX:InitialRAMPercentage=50.0` — Uses 50% of container memory limit for initial heap

Control memory by setting Docker's `--memory` flag:

```bash
docker run --memory=4g ...  # JVM gets ~3GB heap
docker run --memory=8g ...  # JVM gets ~6GB heap
```

To override, set `MINECRAFT_JAVA_ARGS` with custom `-Xms`/`-Xmx` flags.

### Server Configuration (server.properties)

| Variable                                | Default                       | Description                                    |
| --------------------------------------- | ----------------------------- | ---------------------------------------------- |
| MINECRAFT_SERVER_PORT                   | `25565`                       | Game port                                      |
| MINECRAFT_MAX_PLAYERS                   | `20`                          | Max concurrent players                         |
| MINECRAFT_MOTD                          | `A BipOps Minecraft Server`   | Message of the day                             |
| MINECRAFT_DIFFICULTY                    | `easy`                        | Game difficulty (peaceful/easy/normal/hard)     |
| MINECRAFT_GAMEMODE                      | `survival`                    | Default game mode (survival/creative/adventure) |
| MINECRAFT_LEVEL_SEED                    | _(empty)_                     | World seed                                     |
| MINECRAFT_LEVEL_NAME                    | `world`                       | World folder name                              |
| MINECRAFT_LEVEL_TYPE                    | `minecraft:normal`            | World type                                     |
| MINECRAFT_VIEW_DISTANCE                 | `10`                          | View distance in chunks                        |
| MINECRAFT_SIMULATION_DISTANCE           | `10`                          | Simulation distance in chunks                  |
| MINECRAFT_ONLINE_MODE                   | `true`                        | Mojang authentication enforcement              |
| MINECRAFT_PVP                           | `true`                        | PvP enabled                                    |
| MINECRAFT_SPAWN_PROTECTION              | `16`                          | Spawn area protection radius                   |
| MINECRAFT_WHITE_LIST                    | `false`                       | Whitelist enforcement                          |
| MINECRAFT_ENFORCE_WHITELIST             | `false`                       | Kick non-whitelisted players on reload         |
| MINECRAFT_ALLOW_FLIGHT                  | `false`                       | Allow flight                                   |
| MINECRAFT_SPAWN_ANIMALS                 | `true`                        | Spawn animals                                  |
| MINECRAFT_SPAWN_MONSTERS                | `true`                        | Spawn monsters                                 |
| MINECRAFT_SPAWN_NPCS                    | `true`                        | Spawn NPCs (villagers)                         |
| MINECRAFT_GENERATE_STRUCTURES           | `true`                        | Generate structures (villages, etc.)           |
| MINECRAFT_ALLOW_NETHER                  | `true`                        | Allow Nether dimension                         |
| MINECRAFT_MAX_WORLD_SIZE                | `29999984`                    | Maximum world radius in blocks                 |
| MINECRAFT_ENABLE_COMMAND_BLOCK          | `false`                       | Enable command blocks                          |
| MINECRAFT_HARDCORE                      | `false`                       | Hardcore mode                                  |
| MINECRAFT_NETWORK_COMPRESSION_THRESHOLD | `256`                         | Network compression threshold (bytes)          |
| MINECRAFT_MAX_TICK_TIME                 | `60000`                       | Max tick time before watchdog kills server (ms)|
| MINECRAFT_OP_PERMISSION_LEVEL           | `4`                           | Default op permission level                    |
| MINECRAFT_PLAYER_IDLE_TIMEOUT           | `0`                           | Kick idle players after N minutes (0=disabled) |
| MINECRAFT_RATE_LIMIT                    | `0`                           | Max packets per second (0=disabled)            |
| MINECRAFT_SERVER_IP                     | _(empty)_                     | Bind to specific IP (empty=all interfaces)     |

### RCON & Query

| Variable                | Default   | Description                     |
| ----------------------- | --------- | ------------------------------- |
| MINECRAFT_RCON_ENABLED  | `false`   | Enable RCON remote console      |
| MINECRAFT_RCON_PASSWORD | _(empty)_ | RCON password                   |
| MINECRAFT_RCON_PORT     | `25575`   | RCON port                       |
| MINECRAFT_ENABLE_QUERY  | `false`   | Enable GameSpy4 query protocol  |
| MINECRAFT_QUERY_PORT    | `25565`   | Query port                      |
| MINECRAFT_ENABLE_STATUS | `true`    | Enable server list status       |

## Notes

- Minecraft Java Edition requires Java 21. This is provided via devbox (`devbox.json` declares `jdk@21`).
- World data is stored at `/game/world` inside the container
- To pin a specific Minecraft version, set `MINECRAFT_VERSION=1.21.4` (or any valid release version).
- Operator and whitelist management is done in-game or by editing `ops.json`/`whitelist.json` in the `/game` volume.
