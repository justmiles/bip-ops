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

| Variable                     | Default  | Description                                             |
| ---------------------------- | -------- | ------------------------------------------------------- |
| MINECRAFTBEDROCK_VERSION     | `latest` | Server version to install (e.g., `1.21.50.26` or `latest`) |

### Server Configuration (server.properties)

| Variable                                   | Default                      | Description                                              |
| ------------------------------------------ | ---------------------------- | -------------------------------------------------------- |
| MINECRAFTBEDROCK_SERVER_NAME               | `A BipOps Bedrock Server`    | Server name shown in server list                         |
| MINECRAFTBEDROCK_GAMEMODE                  | `survival`                   | Default game mode (survival/creative/adventure/spectator)|
| MINECRAFTBEDROCK_FORCE_GAMEMODE            | `false`                      | Force players into the default game mode on join         |
| MINECRAFTBEDROCK_DIFFICULTY                | `easy`                       | Game difficulty (peaceful/easy/normal/hard)              |
| MINECRAFTBEDROCK_ALLOW_CHEATS              | `false`                      | Allow cheats/commands                                    |
| MINECRAFTBEDROCK_MAX_PLAYERS               | `10`                         | Maximum concurrent players                               |
| MINECRAFTBEDROCK_ONLINE_MODE               | `true`                       | Require Xbox Live authentication                         |
| MINECRAFTBEDROCK_ALLOW_LIST                | `false`                      | Enable allowlist (whitelist)                             |
| MINECRAFTBEDROCK_SERVER_PORT               | `19132`                      | IPv4 game port (UDP+TCP)                                 |
| MINECRAFTBEDROCK_SERVER_PORT_V6            | `19133`                      | IPv6 game port (UDP+TCP)                                 |
| MINECRAFTBEDROCK_LAN_VISIBILITY            | `true`                       | Announce server on LAN                                   |
| MINECRAFTBEDROCK_VIEW_DISTANCE             | `32`                         | View distance in chunks                                  |
| MINECRAFTBEDROCK_TICK_DISTANCE             | `4`                          | Simulation/tick distance in chunks (4-12)                |
| MINECRAFTBEDROCK_PLAYER_IDLE_TIMEOUT       | `30`                         | Kick idle players after N minutes (0=disabled)           |
| MINECRAFTBEDROCK_MAX_THREADS               | `8`                          | Maximum worker threads (0=auto)                          |
| MINECRAFTBEDROCK_LEVEL_NAME                | `Bedrock level`              | World folder name under worlds/                          |
| MINECRAFTBEDROCK_LEVEL_SEED                | _(empty)_                    | World generation seed                                    |
| MINECRAFTBEDROCK_DEFAULT_PERMISSION        | `member`                     | Default player permission (visitor/member/operator)      |
| MINECRAFTBEDROCK_TEXTUREPACK_REQUIRED      | `false`                      | Require clients to use server texture packs              |
| MINECRAFTBEDROCK_MOVEMENT_MODE             | `server-auth`                | Server movement authority (server-auth/client-auth)      |
| MINECRAFTBEDROCK_AUTH_BLOCK_BREAKING       | `false`                      | Server-authoritative block breaking                      |
| MINECRAFTBEDROCK_CHAT_RESTRICTION          | `None`                       | Chat restriction level (None/Dropped/Disabled)           |
| MINECRAFTBEDROCK_COMPRESSION_ALGORITHM     | `zlib`                       | Network compression algorithm (zlib/snappy)              |
| MINECRAFTBEDROCK_TELEMETRY                 | `false`                      | Emit server telemetry to Microsoft                       |

## Notes

- World data is stored at `/game/worlds/<MINECRAFTBEDROCK_LEVEL_NAME>` inside the container.
- Player allowlist is managed via `/game/allowlist.json` in the game volume.
- Operator permissions are managed via `/game/permissions.json` in the game volume.
- Bedrock Edition uses UDP for gameplay - ensure your firewall allows UDP on port 19132.
- Bedrock and Java Edition clients are not cross-compatible.
