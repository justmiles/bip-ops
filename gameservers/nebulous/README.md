# NEBULOUS: Fleet Command Server

This directory contains the configuration and scripts for running a
NEBULOUS: Fleet Command dedicated server using BipOps.

NEBULOUS ships a native 64-bit Linux Unity dedicated server that SteamCMD
downloads anonymously (Steam appid 2353090) and runs fully headless
(`-nographics -batchmode`) with no Wine or X display. The game identity is
resolved against the store appid 887570 (exported as `SteamAppId`).

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=nebulous \
  -e NEBULOUS_SERVER_NAME="BipOps NEBULOUS Server" \
  -e NEBULOUS_MAX_PLAYERS=10 \
  -e NEBULOUS_SCENARIO=Control \
  -p 7777:7777/tcp \
  -p 27016:27016/udp \
  -v /path/to/gameservers/nebulous/game:/game \
  -v /path/to/gameservers/nebulous/backups:/backups \
  justmiles/bipops
```

First boot downloads the server via SteamCMD, which can take a few minutes.

## Required Ports

| Port  | Protocol | Description                                                |
| ----- | -------- | ---------------------------------------------------------- |
| 7777  | TCP      | Game traffic (`GamePort`) - all gameplay flows over this   |
| 27016 | UDP      | Steam A2S server-browser query (`QueryPort`)               |

Note: unlike most Steam titles, NEBULOUS sends all gameplay traffic over **TCP**
on the game port; only the Steam query port is UDP.

## Volume Mounts

| Host Path                             | Container Path | Description            |
| ------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/nebulous/game    | /game          | Game files directory   |
| /path/to/gameservers/nebulous/backups | /backups       | Backup files directory |

The server config (`DedicatedServerConfig.xml`) is rendered to `/game` and the
Unity persistent data (logs, state) lives under `/game/Saved`, which is what
BipOps backs up.

## Environment Variables

| Variable                      | Default                    | Description                                                        |
| ----------------------------- | -------------------------- | ------------------------------------------------------------------ |
| NEBULOUS_SERVER_NAME          | "BipOps NEBULOUS Server"   | Server name shown in the server browser (`ServerName`)             |
| NEBULOUS_PASSWORD             | ""                         | Password to join; empty means open (`Password`)                    |
| NEBULOUS_MAX_PLAYERS          | 10                         | Maximum player slots (`MaxPlayers`)                                |
| NEBULOUS_SCENARIO             | Control                    | Game scenario / mode (`Scenario`)                                  |
| NEBULOUS_MAP_ROTATION         | Sequential                 | Map rotation order: `Sequential` or `Random` (`MapRotation`)       |
| NEBULOUS_MAPS                 | Pillars                    | Comma-separated map rotation list (`Maps`)                         |
| NEBULOUS_TEAM_SIZE_TO_START   | 2                          | Players required per team before a match starts (`TeamSizeToStart`)|
| NEBULOUS_TIME_LIMIT           | 0                          | Match time limit in minutes; 0 = unlimited (`TimeLimit`)           |
| NEBULOUS_ALLOW_MAP_VOTING     | true                       | Allow players to vote on maps/scenarios (`AllowMapVoting`)         |
| NEBULOUS_REQUIRE_UNIFORM_TEAMS| true                       | Enforce equal team sizes (`RequireUniformTeams`)                   |
| NEBULOUS_ALLOW_MODDED_FLEETS  | false                      | Permit Workshop-modded fleets (`AllowModdedFleets`)                |
| NEBULOUS_MOTD                 | (welcome text)             | Message of the day shown to joining players (`MOTD`)               |
| NEBULOUS_ADMIN_STEAM_IDS      | ""                         | Comma-separated SteamID64s registered as admins (`Admins`)         |
| NEBULOUS_GAME_PORT            | 7777                       | TCP game port (`GamePort`)                                         |
| NEBULOUS_QUERY_PORT           | 27016                      | UDP Steam query port (`QueryPort`)                                 |
| NEBULOUS_STEAM_APP_ID         | 887570                     | Store appid exported as `SteamAppId` for Steamworks identity       |

## Server Administration

SteamID64s listed in `NEBULOUS_ADMIN_STEAM_IDS` are registered as server admins
and can run `!` commands in the lobby (such as `!help`) without a vote, and show
a Host badge next to their name.

Available scenarios depend on the installed game version; `Control` is the
standard objective mode and is the default. Set `NEBULOUS_MAPS` to a
comma-separated list to control the rotation (for example `Pillars,Crossing`).

## Notes

- The dedicated server config parser requires **CRLF (Windows) line endings** and
  crashes on a plain LF file. `start.sh` converts the gomplate-rendered
  `DedicatedServerConfig.xml` to CRLF before launch, so no manual step is needed.
- NEBULOUS currently ships a Linux-only dedicated server build; it runs natively
  with no Wine layer.
- Workshop mods are only usable when `NEBULOUS_ALLOW_MODDED_FLEETS=true`, and any
  modded maps must also be referenced in `NEBULOUS_MAPS`.
