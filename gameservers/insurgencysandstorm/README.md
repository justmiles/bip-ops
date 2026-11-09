# Insurgency: Sandstorm Server

This directory contains the configuration and scripts for running an
Insurgency: Sandstorm dedicated server using BipOps.

Insurgency: Sandstorm ships a native 64-bit Linux dedicated server that SteamCMD
downloads anonymously (Steam **server** appid `581330`) and runs fully headless
with no Wine or X display. It is a UE4 tactical FPS supporting competitive
multiplayer and Co-op (Checkpoint vs AI) scenarios.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=insurgencysandstorm \
  -e INSURGENCYSANDSTORM_SERVER_NAME="BipOps Insurgency Server" \
  -e INSURGENCYSANDSTORM_MAP=Oilfield \
  -e INSURGENCYSANDSTORM_SCENARIO=Scenario_Refinery_Checkpoint_Security \
  -e INSURGENCYSANDSTORM_MAX_PLAYERS=8 \
  -p 27102:27102/udp \
  -p 27131:27131/udp \
  -p 27015:27015/tcp \
  -v /path/to/gameservers/insurgencysandstorm/game:/game \
  -v /path/to/gameservers/insurgencysandstorm/backups:/backups \
  justmiles/bipops
```

First boot downloads the server (several GB) via SteamCMD, which can take a few
minutes.

## Required Ports

| Port  | Protocol | Description                                    |
| ----- | -------- | ---------------------------------------------- |
| 27102 | UDP      | Game traffic (`-Port`)                         |
| 27131 | UDP      | Steam A2S query (`-QueryPort`)                 |
| 27015 | TCP      | RCON remote admin (`[Rcon]` in Game.ini)       |

RCON only listens when `INSURGENCYSANDSTORM_RCON_ENABLED=True` and a password is
set.

## Volume Mounts

| Host Path                                       | Container Path | Description            |
| ----------------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/insurgencysandstorm/game   | /game          | Game files directory   |
| /path/to/gameservers/insurgencysandstorm/backups| /backups       | Backup files directory |

Save data and config live under `/game/Insurgency/Saved/` (the rendered
`Config/LinuxServer/Game.ini` plus any Admins/Mapcycle files), which is what
BipOps backs up.

## Environment Variables

| Variable                                   | Default                                  | Description                                                      |
| ------------------------------------------ | ---------------------------------------- | ---------------------------------------------------------------- |
| INSURGENCYSANDSTORM_SERVER_NAME            | "BipOps Insurgency Server"               | Server name shown in the browser (`-hostname`)                   |
| INSURGENCYSANDSTORM_MAP                    | Oilfield                                 | Starting map (UE travel URL first segment)                       |
| INSURGENCYSANDSTORM_SCENARIO               | Scenario_Refinery_Checkpoint_Security    | Scenario/game mode for the starting map                          |
| INSURGENCYSANDSTORM_MAX_PLAYERS            | 8                                        | Maximum player slots                                             |
| INSURGENCYSANDSTORM_PORT                   | 27102                                    | UDP game port (`-Port`)                                          |
| INSURGENCYSANDSTORM_QUERY_PORT             | 27131                                    | UDP Steam query port (`-QueryPort`)                             |
| INSURGENCYSANDSTORM_GSLT                   | ""                                       | Game Server Login Token (store appid 581320) for public listing |
| INSURGENCYSANDSTORM_GAMESTATS_TOKEN        | ""                                       | GameStats token to enable player XP/progression                 |
| INSURGENCYSANDSTORM_MUTATORS               | ""                                       | Comma-separated mutator list (e.g. "Frenzy,Vampirism")          |
| INSURGENCYSANDSTORM_FRIENDLY_FIRE          | True                                     | Allow friendly fire                                             |
| INSURGENCYSANDSTORM_FRIENDLY_FIRE_MODIFIER | 1.0                                      | Friendly fire damage modifier                                   |
| INSURGENCYSANDSTORM_KILL_FEED              | True                                     | Show the kill feed                                             |
| INSURGENCYSANDSTORM_USE_VOTE               | True                                     | Enable in-game voting                                          |
| INSURGENCYSANDSTORM_VOTE_KICK              | True                                     | Enable vote-kick                                               |
| INSURGENCYSANDSTORM_RCON_ENABLED           | False                                    | Enable the RCON listener                                       |
| INSURGENCYSANDSTORM_RCON_PORT              | 27015                                    | TCP RCON listen port (`[Rcon] ListenPort`)                     |
| INSURGENCYSANDSTORM_RCON_PASSWORD          | ""                                       | RCON admin password (required for RCON to accept connections)   |
| INSURGENCYSANDSTORM_RCON_LOG_EVENTS        | False                                    | Log gameplay events to RCON                                    |

## Server Administration

Enable RCON by setting `INSURGENCYSANDSTORM_RCON_ENABLED=True` plus a strong
`INSURGENCYSANDSTORM_RCON_PASSWORD`, then connect with any Source-style RCON
client to TCP `27015`. Common commands include `listplayers`, `kick`, `ban`,
`say`, `travel <map>?Scenario=<scenario>`, and `restartround`.

Admin SteamID64s and mapcycle entries can be managed by editing
`Insurgency/Saved/Config/LinuxServer/Admins.txt` and `Mapcycle.txt` under the
mounted `/game` volume.

## Notes

- Scenario names are case-sensitive and map-specific (e.g.
  `Scenario_Refinery_Checkpoint_Security`, `Scenario_Crossing_Push_Security`).
  Pick a scenario that matches the configured map.
- A GSLT (generated for store appid `581320`) is only needed to appear in the
  public Steam server browser; the server still runs for direct/LAN connects
  without one.
- Networking options (`-Port`, `-QueryPort`, `-hostname`, map/scenario) are
  passed on the command line in `start.sh`; gameplay and RCON settings are
  rendered into `Game.ini`.
