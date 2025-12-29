# Starbound

## Configuration

The server is configured using environment variables.

### Required Variables
| Variable | Description |
| -------- | ----------- |
| `STEAM_USER` | Steam username required to download/update the server. |
| `STEAM_PASSWORD` | Steam password required to download/update the server. |

### Configuration Variables
| Variable | Default | Description |
| -------- | ------- | ----------- |
| `STARBOUND_SERVER_NAME` | `BipOps Starbound Server` | Name of the server. |
| `STARBOUND_MAX_PLAYERS` | `8` | Maximum number of players allowed. |
| `STARBOUND_MAX_TEAM_SIZE` | `8` | Maximum number of players in a team. |
| `STARBOUND_GAME_PORT` | `21025` | Port for game traffic. |
| `STARBOUND_QUERY_PORT` | `21025` | Port for server queries. |
| `STARBOUND_RCON_PORT` | `21026` | Port for RCON connections. |
| `STARBOUND_RCON_PASSWORD` | `` | Password for RCON. |
| `STARBOUND_ALLOW_ADMIN_COMMANDS` | `true` | Allow admin commands. |
| `STARBOUND_ALLOW_ADMIN_COMMANDS_FROM_ANYONE` | `false` | Allow anyone to use admin commands. |
| `STARBOUND_ALLOW_ANONYMOUS_CONNECTIONS` | `true` | Allow users to connect without a password. |
| `STARBOUND_ANONYMOUS_CONNECTIONS_ARE_ADMIN` | `false` | Anonymous connections get admin rights. |

