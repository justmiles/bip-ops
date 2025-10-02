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

- **Palworld** - [quickstart here](./gameservers/palworld/README.md)
- **Sons of the Forest** - [quickstart here](./gameservers/sonsoftheforest/README.md)
- **Subsistence** - [quickstart here](./gameservers/subsistence/README.md)

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
- `BIPOPS_BACKUP_INTERVAL`: (Optional) Backup interval in seconds (default: 3600)
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

## Directory Structure

```
bipops/
├── Dockerfile            # Container definition
├── bip-ops.sh            # Main entry script
├── gameservers/          # Game-specific configurations and scripts
│   ├── palworld/         # Palworld server
│   │   ├── .bip-ops.yaml # Configuration
│   │   ├── start.sh      # Server start script
│   │   ├── README.md     # Game-specific documentation
│   │   └── config/       # Configuration templates
│   ├── sonsoftheforest/  # Sons of the Forest server
│   │   ├── .bip-ops.yaml # Configuration
│   │   ├── start.sh      # Server start script
│   │   ├── README.md     # Game-specific documentation
│   │   └── config/       # Configuration templates
│   └── subsistence/      # Subsistence server
│       ├── .bip-ops.yaml # Configuration
│       ├── start.sh      # Server start script
│       ├── README.md     # Game-specific documentation
│       └── config/       # Configuration templates
└── s6-overlay/           # s6-overlay service definitions
    └── s6-rc.d/          # Service configurations
        ├── backup-game/  # Backup service
        ├── configure-game/ # Configuration service
        ├── update-game/  # Game update service
        ├── update-steamcmd/ # SteamCMD update service
        └── xpra/         # Xpra service
```

## Adding New Game Servers

To add support for a new game server:

1. Create a new directory under `gameservers/` with the game's name
2. Create a `.bip-ops.yaml` file with the game's configuration
3. Create the necessary scripts:
   - `start.sh`: Script to start the game server

## Ports

The ports used depend on the game server being run:

### Palworld

- **8211/udp**: Game connection port
- **8212/tcp**: REST API port
- **25575/tcp**: RCON port

### Sons of the Forest

- **8766/udp**: Game connection port
- **9700/udp**: Blob sync port
- **27016/udp**: Steam query port

### Subsistence

- **7777/udp**: Game server port
- **27015/udp**: Steam query port

### Common

- **7756/tcp**: Xpra web access port (if enabled)

## Troubleshooting

### Common Issues

**Server won't start:**

- Ensure `BIPOPS_GAMESERVER` is set to a supported game (palworld, subsistence, sonsoftheforest)
- Check that required ports are not already in use
- Verify volume mounts are properly configured

**Game files not updating:**

- Set `BIPOPS_VALIDATE_SERVER_FILES=true` to force validation
- Provide Steam credentials if the game requires authentication

**X11 display issues:**

- For games requiring X11 (usex: true), ensure `BIPOPS_XSERVER` is set appropriately
- Check that the Xpra service is running if using xpra mode

**Backup issues:**

- Verify backup directory has proper permissions
- Check `BIPOPS_BACKUP_INTERVAL` setting (default: 3600 seconds)

### Logs

View container logs:

```bash
docker logs bipops-palworld
```

View game server logs:

```bash
docker exec bipops-palworld tail -f /var/log/gameserver/current
```

## Features

- **Multi-game Support**: Currently supports Palworld, Sons of the Forest, and Subsistence
- **Automated Backups**: Configurable backup intervals with rsnapshot
- **Steam Integration**: Automatic game updates via SteamCMD
- **Wine Support**: Run Windows games on Linux containers
- **X11 Display Support**: Virtual display support for games requiring GUI
- **Service Management**: Robust process management with s6-overlay
- **Configuration Management**: Environment-based configuration with template support
- **RCON Support**: Remote administration for supported games

## ROADMAP

### Completed ✅

- ✅ Include `BIPOPS_XSERVER` environment variable with options `xpra`, or `xvfb` (default `xvfb`)
- ✅ Set backup interval as environment variable (`BIPOPS_BACKUP_INTERVAL`)
- ✅ Add `bipops` user and limit root usage
- ✅ Add Palworld support

### In Progress 🚧

- 🚧 Add CI/CD pipeline
- 🚧 Add additional Steam games
- 🚧 Add non-Steam games

### Planned 📋

- 📋 Add support for manual config files via environment variable `BIPOPS_MANUAL_CONFIG=true`
- 📋 CLI: create a `bip-ops` cli to handle admin tasks:
  - backups: list available backups
  - restore: restore from a backup

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Adding New Game Support

To add support for a new game:

1. Create a new directory under `gameservers/` with the game's name
2. Create a `.bip-ops.yaml` configuration file
3. Create a `start.sh` script to launch the game server
4. Create a `README.md` with game-specific documentation
5. Add configuration templates in the `config/` directory
6. Test thoroughly and update this README

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
