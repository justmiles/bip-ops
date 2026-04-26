# Starbound

This directory contains the configuration and scripts for running a Starbound dedicated server using BipOps.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=starbound \
  -e STEAM_USER=yourusername \
  -e STEAM_PASSWORD=yourpassword \
  -e STARBOUND_SERVER_NAME="My Starbound Server" \
  -p 21025:21025 \
  -p 21026:21026 \
  -v /path/to/game:/game \
  -v /path/to/backups:/backups \
  justmiles/bipops
```

> **Note:** Starbound requires a Steam account that owns the game to download the dedicated server files. Set `STEAM_USER` and `STEAM_PASSWORD` accordingly.

## Required Ports

| Port  | Protocol | Description          |
| ----- | -------- | -------------------- |
| 21025 | TCP      | Game / query traffic |
| 21026 | TCP      | RCON                 |

## Volume Mounts

| Host Path          | Container Path | Description            |
| ------------------ | -------------- | ---------------------- |
| /path/to/game      | /game          | Game files directory   |
| /path/to/backups   | /backups       | Backup files directory |

## Environment Variables

### Required Variables

| Variable         | Description                                              |
| ---------------- | -------------------------------------------------------- |
| `STEAM_USER`     | Steam username required to download/update the server.   |
| `STEAM_PASSWORD` | Steam password required to download/update the server.   |

### Server Settings

| Variable                                       | Default                    | Description                                        |
| ---------------------------------------------- | -------------------------- | -------------------------------------------------- |
| `STARBOUND_SERVER_NAME`                        | `BipOps Starbound Server`  | Name of the server.                                |
| `STARBOUND_MAX_PLAYERS`                        | `8`                        | Maximum number of players allowed.                 |
| `STARBOUND_MAX_TEAM_SIZE`                      | `8`                        | Maximum number of players in a team.               |

### Network Settings

| Variable                | Default | Description                  |
| ----------------------- | ------- | ---------------------------- |
| `STARBOUND_GAME_PORT`   | `21025` | Port for game traffic.       |
| `STARBOUND_QUERY_PORT`  | `21025` | Port for server queries.     |
| `STARBOUND_RCON_PORT`   | `21026` | Port for RCON connections.   |
| `STARBOUND_RCON_PASSWORD` | _(empty)_ | Password for RCON.        |

### Security & Access

| Variable                                          | Default | Description                                      |
| ------------------------------------------------- | ------- | ------------------------------------------------ |
| `STARBOUND_ALLOW_ADMIN_COMMANDS`                  | `true`  | Allow admin commands.                            |
| `STARBOUND_ALLOW_ADMIN_COMMANDS_FROM_ANYONE`      | `false` | Allow anyone to use admin commands.              |
| `STARBOUND_ALLOW_ANONYMOUS_CONNECTIONS`            | `true`  | Allow users to connect without a password.       |
| `STARBOUND_ANONYMOUS_CONNECTIONS_ARE_ADMIN`        | `false` | Anonymous connections get admin rights.          |
| `STARBOUND_ALLOW_ASSETS_MISMATCH`                 | `true`  | Allow clients with mismatched assets to connect. |
| `STARBOUND_CHECK_ASSETS_DIGEST`                   | `false` | Check assets digest on client connect.           |
| `STARBOUND_SERVER_ADMIN_PASSWORD`                 | _(empty)_ | Password for the admin server user.            |
| `STARBOUND_SERVER_PLAYER_PASSWORD`                | _(empty)_ | Password for the player server user.           |
