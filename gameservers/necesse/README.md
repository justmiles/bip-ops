# Necesse Server

This directory contains the configuration and scripts for running a Necesse dedicated game server using BipOps.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=necesse \
  -e NECESSE_WORLD=myworld \
  -e NECESSE_SLOTS=10 \
  -p 14159:14159/udp \
  -v /path/to/game:/game \
  -v /path/to/backups:/backups \
  justmiles/bipops
```

## Required Ports

| Port  | Protocol | Description     |
| ----- | -------- | --------------- |
| 14159 | UDP      | Game connection |

## Volume Mounts

| Host Path          | Container Path | Description            |
| ------------------ | -------------- | ---------------------- |
| /path/to/game      | /game          | Game files directory   |
| /path/to/backups   | /backups       | Backup files directory |

## Environment Variables

Below is a comprehensive list of all available configuration options for the Necesse server:

### Server Launch Options

These are passed as command-line arguments to the server:

| Variable            | Default     | Description                                                    |
| ------------------- | ----------- | -------------------------------------------------------------- |
| NECESSE_WORLD       | `default`   | World/save name to load or create                              |
| NECESSE_PORT        | `14159`     | UDP port for the game server                                   |
| NECESSE_SLOTS       | `10`        | Maximum number of concurrent player slots                      |
| NECESSE_OWNER       | _(empty)_   | Player name to grant owner permissions on first join           |

### Server Configuration (server.cfg)

These are rendered into the `server.cfg` configuration file:

| Variable                    | Default   | Description                                                                                  |
| --------------------------- | --------- | -------------------------------------------------------------------------------------------- |
| NECESSE_PASSWORD            | _(empty)_ | Server password (leave empty for public server)                                              |
| NECESSE_PAUSE_WHEN_EMPTY    | `true`    | Pause the world when no players are connected                                                |
| NECESSE_GIVE_CLIENTS_POWER  | `true`    | Anti-cheat setting; `true` gives clients more authority (smoother but less secure)            |
| NECESSE_MAX_LATENCY         | `500`     | Maximum allowable latency (ms) before a player is auto-kicked                                |
| NECESSE_MOTD                | _(empty)_ | Message of the Day displayed to players upon joining                                         |

## Notes

- Necesse is a Java-based game server. The dedicated server installation from Steam includes a bundled JRE, so no additional Java installation is required.
- Save data is stored at `/home/bipops/.config/Necesse/saves/` inside the container. This is backed up automatically by rsnapshot.
- World settings (difficulty, death penalty, raids, etc.) are configured in-game or via the world's `worldSettings.cfg` file inside the save archive.
