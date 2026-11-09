# Soulmask Server

This directory contains the configuration and scripts for running a [Soulmask](https://store.steampowered.com/app/2646460/Soulmask/)
dedicated server using BipOps.

Soulmask ships a native 64-bit Linux dedicated server (SteamCMD appid `3017300`) launched
via the shipped `WSServer.sh` wrapper. All server settings are driven by launch flags from
`SOULMASK_*` environment variables. The server refuses to run as root; BipOps already runs
`start.sh` as the non-root `bipops` user, so this is satisfied.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=soulmask \
  -e SOULMASK_SERVER_NAME="BipOps Soulmask Server" \
  -e SOULMASK_MAX_PLAYERS=20 \
  -e SOULMASK_ADMIN_PASSWORD=changeme \
  -p 8777:8777/udp \
  -p 27015:27015/udp \
  -v /path/to/gameservers/soulmask/game:/game \
  -v /path/to/gameservers/soulmask/backups:/backups \
  justmiles/bipops
```

## Required Ports

| Port  | Protocol | Description                                         |
| ----- | -------- | --------------------------------------------------- |
| 8777  | UDP      | Game connection (primary)                           |
| 27015 | UDP      | Steam query port (server-browser visibility)        |
| 18888 | TCP      | Echo / telnet maintenance console (bound locally)   |
| 19000 | TCP      | RCON remote console (only when a password is set)   |

## Volume Mounts

| Host Path                             | Container Path | Description            |
| ------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/soulmask/game    | /game          | Game files directory   |
| /path/to/gameservers/soulmask/backups | /backups       | Backup files directory |

World and save data live at `/game/WS/Saved` (backed up by rsnapshot). The world database
for the default level is at `/game/WS/Saved/Worlds/Dedicated/Level01_Main/world.db`.

## Environment Variables

| Variable                 | Default                 | Description                                                             |
| ------------------------ | ----------------------- | --------------------------------------------------------------------- |
| SOULMASK_SERVER_NAME     | BipOps Soulmask Server  | Server name shown in the in-game server list                           |
| SOULMASK_MAX_PLAYERS     | 20                      | Maximum number of players                                              |
| SOULMASK_LEVEL           | Level01_Main            | Level/map and save-folder name                                         |
| SOULMASK_PASSWORD        | _(empty)_               | Join password (empty = public, no password)                            |
| SOULMASK_ADMIN_PASSWORD  | _(empty)_               | Admin/GM password used to grant in-game admin rights                   |
| SOULMASK_PVP             | false                   | `true` = PvP server, `false` = PvE server                              |
| SOULMASK_PORT            | 8777                    | Main game port (UDP)                                                   |
| SOULMASK_QUERY_PORT      | 27015                   | Steam query port (UDP)                                                 |
| SOULMASK_ECHO_PORT       | 18888                   | Echo/telnet maintenance console port (TCP)                            |
| SOULMASK_MULTIHOME       | 0.0.0.0                 | IP address the server binds to                                         |
| SOULMASK_SAVE_INTERVAL   | 600                     | Seconds between writing the world database to disk (`-saving`)         |
| SOULMASK_BACKUP_INTERVAL | 1800                    | Seconds between in-game world backups (`-backup`)                      |
| SOULMASK_RCON_PASSWORD   | _(empty)_               | RCON password (empty = RCON disabled)                                  |
| SOULMASK_RCON_PORT       | 19000                   | RCON port (TCP), only used when a password is set                      |

## Server Administration

### Admins

Set `SOULMASK_ADMIN_PASSWORD`. In-game, open the console and authenticate with that
password to gain GM/admin rights.

### RCON

Set `SOULMASK_RCON_PASSWORD` to enable the RCON remote console on `SOULMASK_RCON_PORT`
(default `19000/tcp`). Without a password RCON stays disabled.

### Gameplay settings (GameXishu.json)

Fine-grained gameplay multipliers (XP, harvest, PvP damage, base protection, and so on)
are stored in `/game/WS/Saved/GameplaySettings/GameXishu.json`, which the game generates
on first run. It contains hundreds of keys (pinyin-named) across three identical sections.
To tune them, stop the server, edit all three sections of that file, then start the server
again - the server overwrites the file while running. BipOps does not template this file;
the launch-flag settings above cover the common server options.

## Notes

- The server needs a substantial amount of RAM (observed well above 8 GB at startup);
  provision accordingly.
- Changing `SOULMASK_LEVEL` starts/loads a different world under
  `/game/WS/Saved/Worlds/Dedicated/<level>/`.
