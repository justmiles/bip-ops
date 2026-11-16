# Minecraft Bedrock Server

This directory contains the configuration and scripts for running a Minecraft Bedrock Edition dedicated server using BipOps.

> **Note:** Minecraft Bedrock is a non-Steam game. The server binary is downloaded directly from Mojang's download page during the update-game phase. By downloading and running this server you accept the [Minecraft End User License Agreement](https://www.minecraft.net/en-us/eula).

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=minecraftbedrock \
  -p 19132:19132/udp \
  -p 19132:19132/tcp \
  -v /path/to/game:/game \
  -v /path/to/backups:/backups \
  justmiles/bipops
```

## Required Ports

| Port  | Protocol | Description              |
| ----- | -------- | ------------------------ |
| 19132 | UDP      | Game connection (IPv4)   |
| 19132 | TCP      | Game connection (IPv4)   |
| 19133 | UDP      | Game connection (IPv6)   |

## Volume Mounts

| Host Path        | Container Path | Description            |
| ---------------- | -------------- | ---------------------- |
| /path/to/game    | /game          | Game files directory   |
| /path/to/backups | /backups       | Backup files directory |

## Environment Variables

### Server Version

| Variable                     | Default  | Description                                                    |
| ---------------------------- | -------- | -------------------------------------------------------------- |
| MINECRAFTBEDROCK_VERSION     | `latest` | Server version (e.g. `1.21.50.26` or `latest`)                |

### Server Identity

| Variable                        | Default                     | Description                           |
| ------------------------------- | --------------------------- | ------------------------------------- |
| MINECRAFTBEDROCK_SERVER_NAME    | `A BipOps Bedrock Server`   | Name shown in the in-game server list |

### Gameplay

| Variable                           | Default    | Description                                               |
| ---------------------------------- | ---------- | --------------------------------------------------------- |
| MINECRAFTBEDROCK_GAMEMODE          | `survival` | Default game mode (survival/creative/adventure/spectator) |
| MINECRAFTBEDROCK_FORCE_GAMEMODE    | `false`    | Override players' stored game mode on join                |
| MINECRAFTBEDROCK_DIFFICULTY        | `easy`     | World difficulty (peaceful/easy/normal/hard)              |
| MINECRAFTBEDROCK_ALLOW_CHEATS      | `false`    | Allow commands/cheats                                     |

### Networking

| Variable                                  | Default  | Description                                        |
| ----------------------------------------- | -------- | -------------------------------------------------- |
| MINECRAFTBEDROCK_SERVER_PORT              | `19132`  | IPv4 UDP+TCP port                                  |
| MINECRAFTBEDROCK_SERVER_PORT_V6           | `19133`  | IPv6 UDP+TCP port                                  |
| MINECRAFTBEDROCK_LAN_VISIBILITY           | `true`   | Announce server on LAN                             |
| MINECRAFTBEDROCK_COMPRESSION_ALGORITHM    | `zlib`   | Network compression algorithm (zlib/snappy)        |
| MINECRAFTBEDROCK_COMPRESSION_THRESHOLD    | `1`      | Min payload bytes before compression (1-65535)     |

### Players

| Variable                                  | Default    | Description                                                   |
| ----------------------------------------- | ---------- | ------------------------------------------------------------- |
| MINECRAFTBEDROCK_MAX_PLAYERS              | `10`       | Maximum concurrent players                                    |
| MINECRAFTBEDROCK_ONLINE_MODE              | `true`     | Require Xbox Live authentication                              |
| MINECRAFTBEDROCK_ALLOWED_PLAYERS          | _(empty)_  | Comma-separated Xbox gamertags to allowlist (e.g. `Alice,Bob`). When set, `allowlist.json` is generated automatically and `allow-list` is forced to `true`. |
| MINECRAFTBEDROCK_ALLOW_LIST               | `false`    | Enable allowlist without managing it via `ALLOWED_PLAYERS` (use when you manage `allowlist.json` manually in the game volume). |
| MINECRAFTBEDROCK_ALLOW_PLAYER_JOINING     | `true`     | Allow new players to join (set false to lock server)          |
| MINECRAFTBEDROCK_PLAYER_IDLE_TIMEOUT      | `30`       | Kick idle players after N minutes (0=disabled)                |
| MINECRAFTBEDROCK_DEFAULT_PERMISSION       | `member`   | Default permission level (visitor/member/operator)            |
| MINECRAFTBEDROCK_CHAT_RESTRICTION         | `None`     | Chat restriction level (None/Dropped/Disabled)                |
| MINECRAFTBEDROCK_DISABLE_PLAYER_INTERACTION | `false`  | Prevent players from interacting with each other              |
| MINECRAFTBEDROCK_DISABLE_CUSTOM_SKINS     | `false`    | Block player-uploaded custom skins                            |
| MINECRAFTBEDROCK_DISABLE_PERSONA          | `false`    | Disable persona skins (internal use)                          |

### World

| Variable                                  | Default         | Description                                        |
| ----------------------------------------- | --------------- | -------------------------------------------------- |
| MINECRAFTBEDROCK_LEVEL_NAME               | `Bedrock level` | World folder name under `worlds/`                  |
| MINECRAFTBEDROCK_LEVEL_SEED               | _(empty)_       | World generation seed                              |
| MINECRAFTBEDROCK_VIEW_DISTANCE            | `32`            | Maximum view distance in chunks (>=5)              |
| MINECRAFTBEDROCK_TICK_DISTANCE            | `4`             | Simulation distance in chunks (4-12)               |
| MINECRAFTBEDROCK_TEXTUREPACK_REQUIRED     | `false`         | Force clients to use server texture packs          |
| MINECRAFTBEDROCK_CLIENT_CHUNK_GEN         | `true`          | Let clients generate visual chunks client-side     |

### Performance

| Variable                                  | Default    | Description                                                   |
| ----------------------------------------- | ---------- | ------------------------------------------------------------- |
| MINECRAFTBEDROCK_MAX_THREADS              | `8`        | Worker thread cap (0=auto)                                    |
| MINECRAFTBEDROCK_BUILD_RADIUS_RATIO       | `Disabled` | Server build radius override (Disabled or 0.0-1.0)           |
| MINECRAFTBEDROCK_BLOCK_NETWORK_IDS_HASHES | `true`     | Use stable hashed block IDs on the network                    |

### Client Graphics

| Variable                                  | Default | Description                                                        |
| ----------------------------------------- | ------- | ------------------------------------------------------------------ |
| MINECRAFTBEDROCK_DISABLE_VIBRANT_VISUALS  | `true`  | Tell clients to use the non-vibrant visuals graphics setting       |

### Server-Authoritative Movement

| Variable                                       | Default       | Description                                                          |
| ---------------------------------------------- | ------------- | -------------------------------------------------------------------- |
| MINECRAFTBEDROCK_MOVEMENT_MODE                 | `server-auth` | Movement authority (client-auth/server-auth/server-auth-with-rewind) |
| MINECRAFTBEDROCK_POSITION_THRESHOLD            | `0.5`         | Tolerance for client/server position discrepancies                   |
| MINECRAFTBEDROCK_MOVEMENT_DIRECTION_THRESHOLD  | `0.85`        | Max angle difference between attack and look direction (0-1)         |
| MINECRAFTBEDROCK_AUTH_BLOCK_BREAKING           | `false`       | Server computes block mining in sync with client                     |
| MINECRAFTBEDROCK_AUTH_DISMOUNT_STRICT          | `false`       | Stricter server authority over player dismount position              |
| MINECRAFTBEDROCK_AUTH_ENTITY_INTERACTIONS      | `false`       | Stricter server authority over entity interactions                   |

### Content Logging

| Variable                                  | Default  | Description                                              |
| ----------------------------------------- | -------- | -------------------------------------------------------- |
| MINECRAFTBEDROCK_CONTENT_LOG_FILE         | `false`  | Log content errors to file                               |
| MINECRAFTBEDROCK_CONTENT_LOG_LEVEL        | `info`   | Minimum log level (error/warning/info/verbose)           |

### Script Watchdog (Addons / Behavior Packs)

| Variable                                  | Default   | Description                                                            |
| ----------------------------------------- | --------- | ---------------------------------------------------------------------- |
| MINECRAFTBEDROCK_WATCHDOG_ENABLE          | `true`    | Enable the script watchdog                                             |
| MINECRAFTBEDROCK_WATCHDOG_EXCEPTIONS      | `true`    | Enable watchdog exception handling via `beforeWatchdogTerminate` event |
| MINECRAFTBEDROCK_WATCHDOG_SHUTDOWN        | `true`    | Shut down server on unhandled watchdog exception                       |
| MINECRAFTBEDROCK_WATCHDOG_HANG_EXCEPTION  | `true`    | Throw exception when a hang is detected                                |
| MINECRAFTBEDROCK_WATCHDOG_HANG_THRESHOLD  | `10000`   | Single-tick hang threshold in ms (3000-20000)                          |
| MINECRAFTBEDROCK_WATCHDOG_SPIKE_THRESHOLD | `100`     | Single-tick spike threshold in ms (50-500)                             |
| MINECRAFTBEDROCK_WATCHDOG_SLOW_THRESHOLD  | `10`      | Slow script threshold in ms (5-50)                                     |
| MINECRAFTBEDROCK_WATCHDOG_MEMORY_LIMIT    | `250`     | Script memory limit in MB before world save + shutdown (0=disabled)    |
| MINECRAFTBEDROCK_WATCHDOG_MEMORY_WARNING  | `100`     | Script memory threshold in MB for a content log warning (0=disabled)   |

## Notes

- World data is stored at `/game/worlds/<MINECRAFTBEDROCK_LEVEL_NAME>` inside the container.
- Player allowlist is managed via `/game/allowlist.json` in the game volume.
- Operator permissions are managed via `/game/permissions.json` in the game volume.
- Bedrock Edition uses UDP for gameplay - ensure your firewall allows UDP on port 19132.
- Bedrock and Java Edition clients are not cross-compatible.
