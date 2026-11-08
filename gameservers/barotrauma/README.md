# Barotrauma Server

This directory contains the configuration and scripts for running a Barotrauma
dedicated server using BipOps.

Barotrauma ships a native 64-bit Linux dedicated server that SteamCMD downloads
anonymously (Steam appid 1026340) and runs fully headless (no Wine, no X display).
The launcher `./DedicatedServer` sets up the runtime and execs the native server
binary. Steamworks init requires `steamclient.so`, which `start.sh` symlinks into
`~/.steam/sdk64/`.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=barotrauma \
  -e BAROTRAUMA_SERVER_NAME="BipOps Barotrauma Server" \
  -e BAROTRAUMA_MAX_PLAYERS=10 \
  -e BAROTRAUMA_PASSWORD=youradminpassword \
  -e BAROTRAUMA_GAME_MODE=sandbox \
  -p 27015:27015/udp \
  -p 27016:27016/udp \
  -v /path/to/gameservers/barotrauma/game:/game \
  -v /path/to/gameservers/barotrauma/backups:/backups \
  justmiles/bipops
```

First boot downloads the dedicated server via SteamCMD, which can take a few minutes.

## Required Ports

| Port  | Protocol | Description                                   |
| ----- | -------- | --------------------------------------------- |
| 27015 | UDP      | Game traffic (`port` in serversettings.xml)   |
| 27016 | UDP      | Steam A2S query / discovery (`queryport`)     |

## Volume Mounts

| Host Path                              | Container Path | Description            |
| -------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/barotrauma/game   | /game          | Game files directory   |
| /path/to/gameservers/barotrauma/backups| /backups       | Backup files directory |

`start.sh` pins `HOME=/game`, so Barotrauma's config and saves live under
`/game/.local/share/Daedalic Entertainment GmbH/Barotrauma/`, which is what
BipOps backs up. The rendered `serversettings.xml` and the `Multiplayer/`
campaign saves are both there.

## Environment Variables

| Variable                        | Default                     | Description                                                      |
| ------------------------------- | --------------------------- | ---------------------------------------------------------------- |
| BAROTRAUMA_SERVER_NAME          | "BipOps Barotrauma Server"  | Server name shown in the browser (`name`)                        |
| BAROTRAUMA_SERVER_MESSAGE       | "Hosted by BipOps"          | Welcome message / server message (`ServerMessage`)               |
| BAROTRAUMA_PUBLIC               | true                        | List the server publicly in the server browser (`public`)        |
| BAROTRAUMA_PORT                 | 27015                       | UDP game port (`port`)                                           |
| BAROTRAUMA_QUERY_PORT           | 27016                       | UDP Steam query port (`queryport`)                              |
| BAROTRAUMA_MAX_PLAYERS          | 10                          | Maximum player slots (`maxplayers`)                             |
| BAROTRAUMA_PASSWORD             | ""                          | Join password (empty = none) (`password`)                       |
| BAROTRAUMA_ENABLE_UPNP          | false                       | Attempt UPnP port forwarding (`enableupnp`)                     |
| BAROTRAUMA_GAME_MODE            | sandbox                     | Game mode id: sandbox, mission, pvp, devsandbox (`gamemodeidentifier`) |
| BAROTRAUMA_MISSION_TYPE         | Random                      | Mission type when in mission mode (`missiontype`)               |
| BAROTRAUMA_PLAY_STYLE           | Casual                      | Server playstyle tag: Serious, Casual, Roleplay (`playstyle`)   |
| BAROTRAUMA_LEVEL_DIFFICULTY     | 20                          | Level difficulty 0-100 (`LevelDifficulty`)                      |
| BAROTRAUMA_TICKRATE             | 20                          | Server tick rate (`tickrate`)                                   |
| BAROTRAUMA_AUTO_RESTART         | false                       | Auto-restart round after it ends (`autorestart`)               |
| BAROTRAUMA_ALLOW_RESPAWN        | True                        | Allow respawning via respawn shuttle (`allowrespawn`)          |
| BAROTRAUMA_RESPAWN_INTERVAL     | 300                         | Seconds between respawn waves (`respawninterval`)              |
| BAROTRAUMA_START_WHEN_READY     | False                       | Auto-start round when enough clients are ready (`startwhenclientsready`) |
| BAROTRAUMA_ALLOW_SPECTATING     | True                        | Allow players to spectate (`allowspectating`)                 |
| BAROTRAUMA_VOIP_ENABLED         | True                        | Enable in-game voice chat (`voipenabled`/`voicechatenabled`)   |
| BAROTRAUMA_ALLOW_VOTE_KICK      | True                        | Allow players to vote-kick (`allowvotekick`)                  |
| BAROTRAUMA_BOT_COUNT            | 0                           | Number of bots to spawn (`botcount`)                          |
| BAROTRAUMA_MAX_BOT_COUNT        | 16                          | Maximum bots allowed (`maxbotcount`)                          |
| BAROTRAUMA_TRAITORS_ENABLED     | No                          | Traitor events: No, Maybe, Yes (`TraitorsEnabled`)           |
| BAROTRAUMA_KARMA_ENABLED        | False                       | Enable the karma system (`karmaenabled`)                     |

## Server Administration

Barotrauma's server behaviour is driven almost entirely by `serversettings.xml`,
which BipOps renders from the `BAROTRAUMA_*` env vars above on each boot. In-game
admin/moderation (giving a client permissions, kicking, banning, changing the sub
or game mode) is done from the server console or by a connected client granted
permissions.

Important: Barotrauma **rewrites `serversettings.xml` on shutdown**. The
BipOps-rendered file is authoritative on the first boot of a run; changes made
through the in-game admin UI while the server is running are persisted back to
that file. Setting a BAROTRAUMA_* env var and restarting re-applies the template
value on the next boot.

## Notes

- Native Linux build; no Wine or X display required.
- `steamclient.so` is symlinked into `~/.steam/sdk64/` so Steamworks player
  authentication and public listing work. Without it the server fails with
  `Exception: InitGameServer returned false`.
- Multiplayer campaign saves live under
  `/game/.local/share/Daedalic Entertainment GmbH/Barotrauma/Multiplayer/`.
