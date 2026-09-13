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
