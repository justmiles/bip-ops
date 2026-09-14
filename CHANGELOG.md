# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]


## [0.6.3] - 2026-09-07

### Added

- Run Enshrouded game server under GE-Proton
- Enshrouded game server support
- Minecraft game server support
- Necesse game server support
- Humanitz game server support
- VEIN game server
- Starbound game server with improved config
- The Forest game server
- Enhanced game server backup and configuration management
- Ofelia integration for script execution and logging
- GPL v3 LICENSE

### Changed

- Improved game update process
- Refactored Dockerfile and scripts for Ofelia integration
- Refactored script execution and logging across multiple files
- Improved startup script directory handling
- Improved Palworld documentation
- Refined README content and expanded project roadmap

### Removed

- Unused backup and restore scripts

### Fixed

- Enshrouded wine proton execution to run directly instead of through proton run
- Docker image publication to correct justmiles/bipops image name
- VEIN game cert mismatch
- Vein ability to run without password
- Aska startup slot

## [0.6.2] - 2026-09-06

### Changed

- Enshrouded now runs under GE-Proton instead of Wine


## [0.6.1] - 2026-09-02

### Added

- Support for enshrouded

### Fixed

- Publish to correct justmiles/bipops image name


## [0.6.0] - 2026-04-26

### Added

- Support for Minecraft and Necesse


## [0.5.1] - 2026-04-15

### Added

- Support for Starbound game server
- Support for VEIN game server
- Support for Aska game server
- Support for The Forest game server
- Game server backup and configuration management
- Humanitz integration

### Changed

- Improved Starbound configuration with missing server config items
- Enhanced game update process
- Improved Palworld documentation
- Refactored Dockerfile and scripts for Ofelia integration
- Reorganized game data storage and backup functionality
- Refactored file permissions and user management

### Removed

- Unused backup and restore scripts

### Fixed

- VEIN game certificate mismatch
- Aska startup slot issue
- Allow Vein to run without password


## [0.5.0] - 2026-04-15

### Added

- Add humanize functionality


## [0.4.0] - 2026-01-08

### Added

- Initial Starrupture support

### Changed

- Build process improvements


## [0.3.0] - 2025-12-30

### Added

- Starbound server support
- Starbound server configuration items

### Changed

- Starbound configuration handling


## [0.2.2] - 2025-11-25

### Fixed

- Allow vein to run without password


## [0.2.1] - 2025-11-21

### Fixed

- VEIN game cert mismatch


## [0.2.0] - 2025-11-21

### Added

- New game server VEIN

### Changed

- Improved game update process


## [0.1.0] - 2025-11-11

### Fixed

- Fixed Aska startup slot issue


## [0.0.6] - 2025-11-11

### Added

- Initial Aska gameserver support

### Changed

- Refined README content and expanded project roadmap


## [0.0.5] - 2025-10-14

### Added

- Support for The Forest game

### Removed

- Unused backup references


## [0.0.4] - 2025-10-02

_No user-facing changes were detected in the commits for this release._


## [0.0.3] - 2025-10-02

### Added

- Game server backup and configuration management enhancements

### Changed

- Script execution and logging refactored across multiple files
- Dockerfile and scripts refactored for Ofelia integration

### Removed

- Unused backup and restore scripts


## [0.0.2] - 2025-09-18

### Added

- File permission and user management system for bip-ops user
- Support for Palworld game configuration and management
- Support for Sons of the Forest game with launch functionality
- Unified .bip-ops.yaml configuration file replacing .gomplate
- Timestamp handling and enhanced backup strategy
- Standardized directory paths for volume mounts
- Game data storage and backup functionality

### Changed

- File paths and settings across scripts
- Project configuration and settings structure
- Dockerfile and configuration paths for consistency
- File interactions for increased efficiency
- Game start and backup processes

### Removed

- .gomplate configuration in favor of unified .bip-ops.yaml

### Fixed

- Sons of the Forest launch functionality
- Game startup and backup operations

