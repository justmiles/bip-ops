# BipOps

Spend more tip Bip'n and less time managing your game servers.

## Overview

BipOps provides a standardized Docker-based environment for running various game servers. It's designed to simplify the deployment and management of game servers, with built-in support for:

- Windows games (via Wine)
- Automated backups
- Game updates via SteamCMD
- Service management via s6-overlay

## Supported Games

Currently, BIP-OPS supports the following games:

- Subsistence - [quickstart here](./gameservers/subsistence/README.md)
- Sons of the Forest - ([quickstart here](./gameservers/sonsoftheforest/README.md)

Each game has its own configuration and management scripts.

## Getting Started

### Basic Usage

1. Build the Docker image:

   ```bash
   docker build -t bipops .
   ```

2. Run a game server container:
   ```bash
   docker run -d \
     -e BIPOPS_GAMESERVER=subsistence \
     -p 7777:7777/udp \
     -p 7756:7756 \
     -v /path/to/backups:/backups \
     -v /path/to/game:/game \
     --name bipops-subsistence \
     bipops
   ```

### Environment Variables

- `BIPOPS_GAMESERVER`: (Required) The game server to run (e.g., "subsistence", "sonsoftheforest")
- `STEAM_USER`: (Optional) Steam username for non-anonymous downloads
- `STEAM_PASSWORD`: (Optional) Steam password
- `BIPOPS_VALIDATE_SERVER_FILES`: (Optional) Set to "true" to validate game files at launch

## Game Server Configuration

Each game server is configured via a `.bip-ops.yaml` file in its respective directory under `gameservers/`. The configuration includes:

```yaml
game: Game Name # Display name of the game
usewine: true/false # Whether the game requires Wine
usex: true/false # Whether the game requires X11 display
steamid: 123456 # Steam App ID for the game
```

## Directory Structure

```
bipops/
├── Dockerfile            # Container definition
├── bip-ops.sh            # Main entry script
├── healthcheck.sh        # Container health check
├── gameservers/          # Game-specific configurations and scripts
│   ├── sonsoftheforest/  # Sons of the Forest server
│   │   ├── .bip-ops.yaml # Configuration
│   │   ├── start.sh      # Server start script
│   │   ├── backup.sh     # Backup script
│   │   └── restore.sh    # Restore script
│   └── subsistence/      # Subsistence server
│       ├── .bip-ops.yaml # Configuration
│       ├── start.sh      # Server start script
│       ├── backup.sh     # Backup script
│       └── restore.sh    # Restore script
└── s6-rc.d/              # s6-overlay service definitions
    ├── backup-game/      # Backup service
    ├── configure-game/   # Configuration service
    ├── update-game/      # Game update service
    ├── update-steamcmd/  # SteamCMD update service
    └── xpra/             # Xpra service
```

## Adding New Game Servers

To add support for a new game server:

1. Create a new directory under `gameservers/` with the game's name
2. Create a `.bip-ops.yaml` file with the game's configuration
3. Create the necessary scripts:
   - `start.sh`: Script to start the game server
   - `backup.sh`: (Optional) Script to backup game data
   - `restore.sh`: (Optional) Script to restore game data
   - `configure.sh`: (Optional) Script to configure the game server

## Ports

- **7777/udp**: Default game server port
- **7756/tcp**: Xpra web access port (if enabled)

## ROADMAP

- include `XSERVER` environment variable with options `xpra`, or `xvfb` (default `xvfb`) for when the gameserver requires an XDISPLAY as defined in `.bip-ops.yaml`
- set backup interval as environment variable
- add `bip-ops` user and limit root usage
- add CI/CD
- add additional steam games
- add non-steam games
- add support for manual config files via environment variable `BIPOPS_MANUAL_CONFIG=true`; eg, do not run `configure-game.sh` and instead let the user hand-roll their config files.
- Subsistence:
  - figure out why Subsistence is overwriting configs on boot (this is mitigated as we are just editing the "default" config and letting it overwrite existing settings with our modified defaults)
- SOFT:
  - backups
- CLI: create a `bip-ops` cli to handle some admin tasks.
  - backups: list available backups
  - restore: restore from a backup
