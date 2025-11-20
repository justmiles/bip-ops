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

### Server Display Settings

| Variable                    | Default | Description                                          |
| --------------------------- | ------- | ---------------------------------------------------- |
| VEIN_SHOW_SCOREBOARD_BADGES | 1       | Show admin badges on scoreboard (1 = show, 0 = hide) |

### Integration Settings

| Variable                 | Example                                              | Description                              |
| ------------------------ | ---------------------------------------------------- | ---------------------------------------- |
| VEIN_DISCORD_WEBHOOK_URL | https://discord.com/api/webhooks/url-that-you-copied | Discord webhook URL for chat integration |

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
