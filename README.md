# BipOps

Spend more tip Bip'n and less time managing your game servers.

## Overview

BipOps provides a standardized Docker-based environment for running various game servers. It's designed to simplify the deployment and management of game servers, with built-in support for:

- Windows games (via Wine)
- Automated backups
- Game updates via SteamCMD
- Service management via s6-overlay

## Supported Games

Currently, BipOps supports the following games:

- [**Palworld**](./gameservers/palworld/README.md)
- [**The Forest**](./gameservers/theforest/README.md)
- [**Sons of the Forest**](./gameservers/sonsoftheforest/README.md)
- [**Subsistence**](./gameservers/subsistence/README.md)

Each game has its own configuration and management scripts.

## Getting Started

### Using Pre-built Images

You can use the pre-built Docker image from Docker Hub:

```bash
docker pull justmiles/bipops
```

### Building from Source

1. Build the Docker image:

   ```bash
   docker build -t bipops .
   ```

### Basic Usage

2. Run a game server container:
   ```bash
   docker run -d \
     -e BIPOPS_GAMESERVER=palworld \
     -p 8211:8211/udp \
     -p 8212:8212/tcp \
     -p 25575:25575/tcp \
     -v /path/to/backups:/backups \
     -v /path/to/game:/game \
     --name bipops-palworld \
     justmiles/bipops
   ```

### Environment Variables

- `BIPOPS_GAMESERVER`: (Required) The game server to run (e.g., "palworld", "subsistence", "sonsoftheforest")
- `STEAM_USER`: (Optional) Steam username for non-anonymous downloads
- `STEAM_PASSWORD`: (Optional) Steam password
- `BIPOPS_VALIDATE_SERVER_FILES`: (Optional) Set to "true" to validate game files at launch
- `BIPOPS_XSERVER`: (Optional) X server type for games requiring display (default: "xvfb")

## Game Server Configuration

Each game server is configured via a `.bip-ops.yaml` file in its respective directory under `gameservers/`. The configuration includes:

```yaml
game: Game Name # Display name of the game
usewine: true/false # Whether the game requires Wine
usex: true/false # Whether the game requires X11 display
steamid: 123456 # Steam App ID for the game
backupdir: /path/to/backup # Directory to backup for this game
configs: # Configuration file mappings
  "config/file.ini": "/game/path/to/file.ini"
```

## Adding New Game Servers

To add support for a new game server:

1. Create a new directory under `gameservers/` with the game's name
2. Create a `.bip-ops.yaml` file with the game's configuration
3. Create the necessary scripts:
   - `start.sh`: Script to start the game server

```
bipops/
└── gameservers/             # Server-specific configurations and scripts
    └── newgameserver/
        ├── .bip-ops.yaml    # BipOps configuration file
        ├── start.sh         # Server-specific startup script
        ├── README.md        # Server-specific documentation
        └── config/          # Server-specific configuration templates
```

### BipOps Configuration File

The `.bip-ops.yaml` file defines the configuration for each game server. This file must be placed in each game server's directory and contains essential settings for proper server operation.

- **game**: The display name of the game server
- **usewine**: Boolean flag indicating whether to use Wine for Windows games on Linux (`true`/`false`)
- **usex**: Boolean flag indicating whether to use X11 display server for games requiring GUI (`true`/`false`)
- **steamid**: The Steam Application ID for the game (used by SteamCMD for downloads)
- **backupdir**: Directory path within the container where game saves and data are stored
- **configs**: Key/value mapping of configuration template files to their rendered locations within the container

#### Configuration Templates

The `configs` section maps template files from your game server's configs to their destination paths inside the running container.

**Template mapping format:**

```yaml
configs:
  "local/template/path": "/container/destination/path"
```

#### Examples

**Linux Native Game (Palworld):**

```yaml
game: Palworld
usewine: false
usex: false
steamid: 2394010
backupdir: /game/Pal/Saved/
configs:
  "config/PalWorldSettings.ini": "/game/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini"
  "config/Engine.ini": "/game/Pal/Saved/Config/LinuxServer/Engine.ini"
```

**Windows Game with GUI (Sons of The Forest):**

```yaml
game: Sons of The Forest
usewine: true
usex: true
steamid: 2465200
backupdir: /backups/current/Saves/
configs:
  "config/dedicatedserver.cfg": "/backups/current/dedicatedserver.cfg"
  "config/ownerswhitelist.txt": "/backups/current/ownerswhitelist.txt"
```

**Windows Game without GUI (Subsistence):**

```yaml
game: Subsistence
usewine: true
usex: false
steamid: 1362640
backupdir: /game/UDKGame/SaveData
configs:
  "config/UDKDedServerSettings.ini": "/game/UDKGame/Config/DefaultDedServerSettings.ini"
```

## ROADMAP

- Add CI/CD pipeline
- Add non-Steam games
- Add support for manual config files via environment variable `BIPOPS_MANUAL_CONFIG=true`
- CLI: create a `bip-ops` cli to handle admin tasks:
  - backups: list available backups
  - restore: restore from a backup
- Add prometheus exporter to S6 with bipops config for exporter type
  - a2s: https://github.com/armsnyder/a2s-exporter (theforest, sonsoftheforest, aska? subsistence?)
  - https://github.com/palworldlol/palworld-exporter (palworld)
- Add healthiness check (aska disconnects without exiting) or event hooks to restart the server
- rename "game" to "server" to avoid confusion with game clients.

## License

This project is licensed under the GNU General Public License v3.0 (GPL v3) - see the [LICENSE](LICENSE) file for details.

This is a copyleft license that ensures:

- **Freedom to Use**: You can use BipOps for any purpose, including commercial use
- **Freedom to Modify**: You can modify the source code to suit your needs
- **Freedom to Distribute**: You can share BipOps with others
- **Freedom to Share Changes**: Any modifications you make must also be released under GPL v3

**Important**: If you modify BipOps or create derivative works, you must release them under the same GPL v3 license and make the source code available to users.

For more information about GPL v3, visit: https://www.gnu.org/licenses/gpl-3.0.html

## Support

For support, please open an issue on GitHub or check the individual game server documentation in the `gameservers/` directory.
