# BipOps - Agent Context

## Project Overview

BipOps is a **Docker-based game server management platform**. A single Docker image (`justmiles/bipops`) runs any supported game server, selected at runtime via the `BIPOPS_GAMESERVER` environment variable. It provides:

- **SteamCMD** for automatic game installation/updates
- **Wine + X11** for Windows-only game servers on Linux
- **s6-overlay** for process supervision and init ordering
- **rsnapshot** (via **ofelia** scheduler) for rotating backups
- **gomplate** for rendering config templates from environment variables

## Architecture

```
Container startup flow (via s6-overlay):
  /init (s6 entrypoint)
    ├── update-user       (oneshot) - Set UID/GID, create dirs, chown
    ├── update-steamcmd   (oneshot) - Update SteamCMD itself
    ├── update-game       (oneshot) - Install/update game via SteamCMD (depends on update-user, update-steamcmd)
    ├── configure-game    (oneshot) - Render gomplate config templates + rsnapshot.conf (depends on update-game)
    ├── svc-x11           (longrun) - Xvfb or Xpra for games needing a display (depends on configure-game)
    ├── svc-ofelia         (longrun) - Cron-like scheduler for rsnapshot backups (depends on configure-game)
    └── /usr/bin/bip-ops  (CMD)     - Launches /gameservers/$BIPOPS_GAMESERVER/start.sh as `bipops` user
```

### Key Paths Inside the Container

| Path | Purpose |
|------|---------|
| `/gameservers/<name>/` | Game server definitions (copied from repo at build) |
| `/game/` | Game installation directory (SteamCMD installs here) |
| `/backups/` | Backup root; rsnapshot writes to `/backups/snapshots/` |
| `/etc/s6-overlay/s6-rc.d/` | s6 service definitions (copied from repo at build) |
| `/usr/bin/bip-ops` | Main entrypoint script |
| `/usr/lib/steamcmd/` | SteamCMD installation |

### Key Files in the Repo

| File | Purpose |
|------|---------|
| `Dockerfile` | Single-stage Ubuntu Noble image with Wine, SteamCMD, s6-overlay, gomplate, ofelia, Xpra |
| `bip-ops.sh` | Container CMD — validates `BIPOPS_GAMESERVER`, waits for X11 if needed, runs `start.sh` as `bipops` user via `s6-setuidgid` |
| `bip.sh` | Developer scratch file with example `docker run` invocations (not shipped in image) |
| `s6-overlay/` | s6-rc service definitions for init ordering and long-running services |
| `gameservers/` | Per-game configurations, scripts, and templates |

## When Adding New Game Servers to BipOps

### Required Files

Create the following in `gameservers/<NEWGAMESERVER>/`:

1. **`.bip-ops.yaml`** — game metadata:
   - **game**: Display name of the game server
   - **usewine**: `true` if the game is a Windows binary run via Wine, `false` for native Linux
   - **usex**: `true` if the game requires an X11 display (GUI), `false` for headless
   - **steamid**: Steam Application ID (used by SteamCMD `+app_update`)
   - **backupdir**: Absolute path inside the container where game saves/data live (rsnapshot backs this up)
   - **configs**: Key/value map of template source → rendered destination path

2. **`start.sh`** — launch script for the game server. Conventions:
   - Shebang: `#!/bin/bash` with `set -e`
   - `cd /game` first
   - For Wine games: `export WINEPREFIX="/game/.wine"` and set `SteamAppId`
   - Launch the game binary (native or via `wine`)
   - This script runs as the `bipops` user (not root) — `bip-ops.sh` handles the `s6-setuidgid`
   - Command-line flags and conditional logic can be driven by environment variables

3. **`config/<TEMPLATE>`** — gomplate template files for game configuration. Conventions:
   - Use `{{getenv "GAMESERVER_VAR" "default"}}` for all configurable values
   - Environment variable names follow the pattern `<GAMESERVER>_<SETTING>` (e.g., `PALWORLD_MAX_PLAYERS`, `ASKA_PASSWORD`)
   - For string values that need quoting in the output, use `{{printf "\"%s\"" (getenv "VAR" "default")}}`
   - For comma-separated lists that need to expand into repeated keys, use `strings.Split` (see `gameservers/vein/config/Game.ini` for an example)
   - Templates are rendered by `configure-game.sh` using: `gomplate --file <template> --out <destination>`

4. **`README.md`** — documentation for the game server including:
   - All available environment variables with descriptions and defaults
   - Docker run example
   - Port mappings
   - Any game-specific notes

5. **`shutdown.sh`** (optional) — graceful shutdown script. If present, `bip-ops.sh` calls it on container stop via a trap handler. Currently no game servers implement this, but the hook exists.

### Reference Examples

| Game | Wine | X11 | Type | Good example for |
|------|------|-----|------|-----------------|
| `palworld` | ✗ | ✗ | Native Linux | Complex gomplate template using `dict` + `range` for INI-style single-line config |
| `vein` | ✗ | ✗ | Native Linux | Multi-section INI config, comma-separated list expansion, steamclient.so symlinking |
| `aska` | ✓ | ✓ | Wine + GUI | Auto-detection of save IDs, properties-style config, `SteamAppId` export |
| `sonsoftheforest` | ✓ | ✓ | Wine + GUI | Simple JSON-style `.cfg` config, multiple config files |
| `subsistence` | ✓ | ✓ | Wine + GUI | Log file monitoring in background, minimal config |
| `theforest` | ✓ | ✓ | Wine + GUI | Simplest example, single config file |

### Checklist

- [ ] Create `gameservers/<name>/.bip-ops.yaml`
- [ ] Create `gameservers/<name>/start.sh` (make executable)
- [ ] Create `gameservers/<name>/config/<templates>` (if the game has configurable settings)
- [ ] Create `gameservers/<name>/README.md`
- [ ] Update `README.md` supported games list with link to new game's README
- [ ] Test by building the Docker image and running: `docker run -e BIPOPS_GAMESERVER=<name> ...`

## s6-overlay Service Definitions

Services live under `s6-overlay/s6-rc.d/`. Each service directory contains:

- `type` — either `oneshot` or `longrun`
- `run` — the run script (for longrun services, this runs as PID 1 of the service)
- `up` — the command to execute (for oneshot services)
- `scripts/` — actual script logic (called by `run`/`up`)
- `dependencies.d/` — empty files named after services this depends on
- `conf.d/` — configuration file templates

The dependency chain is: `update-user` → `update-steamcmd` → `update-game` → `configure-game` → `svc-x11`, `svc-ofelia`

The `user` bundle in `s6-overlay/s6-rc.d/user/contents.d/` lists all services that should start.

### Adding a New s6 Service

1. Create directory `s6-overlay/s6-rc.d/svc-<name>/`
2. Add `type` file (`longrun` or `oneshot`)
3. Add `run` script
4. Add dependency files in `dependencies.d/`
5. Add an empty file `s6-overlay/s6-rc.d/user/contents.d/svc-<name>` to register it

## Backup System

- **Scheduler**: ofelia (cron-like, runs as a longrun s6 service)
- **Backup tool**: rsnapshot (rotating incremental backups via rsync)
- **Schedule**: every 10min (`latest`), hourly, daily, weekly
- **Retention**: configurable via `BIPOPS_BACKUP_RETENTION_HOURLY`, `BIPOPS_BACKUP_RETENTION_DAILY`, `BIPOPS_BACKUP_RETENTION_WEEKLY` env vars (default: 3 each)
- **Backup source**: `backupdir` from `.bip-ops.yaml`
- **Backup destination**: `/backups/snapshots/`
- **On shutdown**: ofelia's `finish` script triggers one final `rsnapshot latest` backup

## Environment Variables (Global)

| Variable | Default | Description |
|----------|---------|-------------|
| `BIPOPS_GAMESERVER` | `NONE` | **Required**. Name of the game server directory to run |
| `BIPOPS_UID` | `1000` | UID for the `bipops` user |
| `BIPOPS_GID` | `1000` | GID for the `bipops` group |
| `BIPOPS_VALIDATE_SERVER_FILES` | `true` | Pass `validate` flag to SteamCMD `+app_update` |
| `BIPOPS_XSERVER` | `xvfb` | X server type: `xvfb` (headless) or `xpra` (remote desktop on port 7756) |
| `STEAM_USER` | _(empty)_ | Steam username for authenticated downloads |
| `STEAM_PASSWORD` | _(empty)_ | Steam password for authenticated downloads |
| `BIPOPS_BACKUP_RETENTION_HOURLY` | `3` | Number of hourly rsnapshot backups to retain |
| `BIPOPS_BACKUP_RETENTION_DAILY` | `3` | Number of daily rsnapshot backups to retain |
| `BIPOPS_BACKUP_RETENTION_WEEKLY` | `3` | Number of weekly rsnapshot backups to retain |

## Docker Image Details

- **Base**: `ubuntu:noble`
- **User**: `bipops` (non-root, configurable UID/GID)
- **Exposed port**: `7756` (Xpra web UI, only relevant when `BIPOPS_XSERVER=xpra`)
- **Volumes**: Mount `/game` (game files) and `/backups` (backup storage)
- **Entrypoint**: `/init` (s6-overlay)
- **CMD**: `/usr/bin/bip-ops`

## Conventions & Patterns

- **Shell scripts**: Use `#!/command/with-contenv bash` for s6-overlay scripts (access to container env), `#!/bin/bash` for game-specific scripts
- **Process user**: All game processes and scheduled tasks run as the `bipops` user via `s6-setuidgid bipops`
- **Logging**: Pipe output through `s6-log -bp n3 <prefix> 1 /var/log/<name>` for structured logging
- **Config templating**: gomplate with `getenv` — always provide defaults
- **YAML parsing**: Use `yq` to read `.bip-ops.yaml` fields
- **Wine games**: Set `WINEPREFIX="/game/.wine"` and export `SteamAppId` in `start.sh`

## When Viewing External Sites or Documentation

Run the command `reader --image-mode none <url>` to view the contents of the webpage in stdout.
