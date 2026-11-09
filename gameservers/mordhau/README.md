# Mordhau Server

This directory contains the configuration and scripts for running a Mordhau dedicated
server using BipOps. Mordhau ships a free, native Linux dedicated server (Steam app
`629800`) downloaded anonymously via SteamCMD.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=mordhau \
  -e MORDHAU_SERVER_NAME="BipOps Mordhau Server" \
  -e MORDHAU_ADMIN_PASSWORD=changeme \
  -e MORDHAU_MAX_SLOTS=48 \
  -p 7777:7777/udp \
  -p 27015:27015/udp \
  -p 15000:15000/udp \
  -v /path/to/gameservers/mordhau/game:/game \
  -v /path/to/gameservers/mordhau/backups:/backups \
  justmiles/bipops
```

## Required Ports

| Port  | Protocol | Description                                  |
| ----- | -------- | -------------------------------------------- |
| 7777  | UDP      | Game traffic (`-Port`)                       |
| 27015 | UDP      | Steam query port (`-QueryPort`)              |
| 15000 | UDP      | Beacon / server-browser discovery (`-BeaconPort`) |

All three ports are UDP. 15000 must be reachable for the server to appear in the
in-game server browser.

## Volume Mounts

| Host Path                            | Container Path | Description            |
| ------------------------------------ | -------------- | ---------------------- |
| /path/to/gameservers/mordhau/game    | /game          | Game files directory   |
| /path/to/gameservers/mordhau/backups | /backups       | Backup files directory |

Save data and config live under `/game/Mordhau/Saved` (backed up by BipOps). The
rendered `Game.ini` is written to `/game/Mordhau/Saved/Config/LinuxServer/Game.ini`.

## Environment Variables

### Launch / Network Settings

These drive command-line flags in `start.sh`.

| Variable              | Default     | Description                                               |
| --------------------- | ----------- | --------------------------------------------------------- |
| MORDHAU_PORT          | 7777        | Game traffic port (UDP)                                   |
| MORDHAU_QUERY_PORT    | 27015       | Steam query port (UDP)                                    |
| MORDHAU_BEACON_PORT   | 15000       | Beacon / discovery port for the server browser (UDP)     |
| MORDHAU_MULTIHOME     | 0.0.0.0     | Bind address passed as `-MultiHome`                       |
| MORDHAU_START_MAP     | FFA_ThePit  | Map/game-mode loaded on boot before the rotation kicks in |

### Server Session Settings (`Game.ini`)

Section `[/Script/Mordhau.MordhauGameSession]`.

| Variable                  | Default                             | Description                                                     |
| ------------------------- | ----------------------------------- | --------------------------------------------------------------- |
| MORDHAU_SERVER_NAME       | BipOps Mordhau Server               | Server name shown in the server browser                         |
| MORDHAU_SERVER_PASSWORD   | _(empty)_                           | Password required to join (empty = public)                      |
| MORDHAU_ADMIN_PASSWORD    | _(empty)_                           | Admin password; use `adminlogin <password>` in console in-game  |
| MORDHAU_MAX_SLOTS         | 16                                  | Maximum number of player slots                                  |
| MORDHAU_MOTD              | Welcome to a BipOps Mordhau Server! | Message of the day shown on join                                |
| MORDHAU_BANNER_URL        | _(empty)_                           | URL of a banner image shown in the server browser               |
| MORDHAU_ADMINS            | _(empty)_                           | Comma-separated PlayFab IDs granted admin (`Admins=` lines)     |

### Game Mode Settings (`Game.ini`)

Section `[/Script/Mordhau.MordhauGameMode]`.

| Variable                      | Default      | Description                                                 |
| ----------------------------- | ------------ | ----------------------------------------------------------- |
| MORDHAU_MAP_ROTATION          | FFA_ThePit,FFA_Grad,FFA_Camp,FFA_Mountainpeak,FFA_Contraband | Comma-separated list of maps; one `MapRotation=` line each |
| MORDHAU_PLAYER_RESPAWN_TIME   | 5.000000     | Seconds before a player respawns                            |
| MORDHAU_TEAM_DAMAGE_FACTOR    | 0.500000     | Friendly-fire damage multiplier (0 = off, 1 = full)         |
| MORDHAU_MATCH_LENGTH_FACTOR   | 1.000000     | Match length multiplier                                     |
| MORDHAU_ENABLE_VOTE_KICKS     | True         | Allow players to initiate vote-kicks                        |
| MORDHAU_ALLOW_DUELS           | True         | Allow friendly duels                                        |

## Server Administration

### Admin Access

1. Set `MORDHAU_ADMIN_PASSWORD` to a strong value.
2. Join the server, open the console, and run `adminlogin <password>` to gain admin
   rights for the session. Admin commands (kick, ban, change map, etc.) then become
   available.
3. To grant persistent admin, add the player's PlayFab ID to `MORDHAU_ADMINS`
   (comma-separated for multiple). PlayFab IDs are visible in the server log when a
   player connects.

### Map Rotation

Set `MORDHAU_MAP_ROTATION` to a comma-separated list of map codes (for example
`FFA_ThePit,TDM_ThePit,SKM_Grad`). Each entry is rendered as its own
`MapRotation=` line. Game-mode prefixes: `FFA_` (free-for-all), `TDM_` (team
deathmatch), `SKM_` (skirmish), `HRD_` (horde), `BTL_` (battle royale).

## Notes

- The Linux dedicated-server binary is launched through the SteamCMD-shipped
  `MordhauServer.sh` wrapper at the install root, which sets the engine library
  path before exec'ing `Mordhau/Binaries/Linux/MordhauServer-Linux-Shipping`.
- `steamclient.so` is symlinked into both `~/.steam/sdk32` and `~/.steam/sdk64` so
  Steamworks query/registration succeeds headless.

For more information see the
[Mordhau dedicated server documentation](https://mordhau.fandom.com/wiki/Dedicated_Server_Setup).
