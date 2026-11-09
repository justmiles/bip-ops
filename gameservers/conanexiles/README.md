# Conan Exiles Server

This directory contains the configuration and scripts for running a Conan Exiles
(Enhanced) dedicated server using BipOps.

Conan Exiles ships a native 64-bit Linux dedicated server that SteamCMD downloads
anonymously (Steam appid 443030) and runs fully headless with no Wine or X display.
The launch binary is `ConanSandbox/Binaries/Linux/ConanSandboxServer-Linux-Shipping`,
invoked with the `ConanSandbox` project name as its first argument (the same thing the
bundled `ConanSandboxServer.sh` wrapper does).

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=conanexiles \
  -e CONANEXILES_SERVER_NAME="BipOps Conan Exiles Server" \
  -e CONANEXILES_ADMIN_PASSWORD=youradminpassword \
  -e CONANEXILES_MAX_PLAYERS=40 \
  -e CONANEXILES_PVP_ENABLED=True \
  -p 7777:7777/udp \
  -p 7778:7778/udp \
  -p 27015:27015/udp \
  -v /path/to/gameservers/conanexiles/game:/game \
  -v /path/to/gameservers/conanexiles/backups:/backups \
  justmiles/bipops
```

First boot downloads a large install (tens of GB) and initializes the world and SQLite
database under `ConanSandbox/Saved/`, which is slow and memory-hungry. Allow a generous
startup timeout (several minutes or more) and at least ~16 GB RAM for a smooth server.

## Required Ports

| Port  | Protocol | Description                                      |
| ----- | -------- | ------------------------------------------------ |
| 7777  | UDP      | Game traffic (`-Port`)                           |
| 7778  | UDP      | Raw UDP socket (game port + 1, implicit)         |
| 27015 | UDP      | Steam A2S query (`-QueryPort`)                   |

## Volume Mounts

| Host Path                                | Container Path | Description            |
| ---------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/conanexiles/game    | /game          | Game files directory   |
| /path/to/gameservers/conanexiles/backups | /backups       | Backup files directory |

Save data, the world database, and config live under `/game/ConanSandbox/Saved/`,
which is what BipOps backs up.

## Environment Variables

| Variable                             | Default                        | Description                                                        |
| ------------------------------------ | ------------------------------ | ------------------------------------------------------------------ |
| CONANEXILES_SERVER_NAME              | "BipOps Conan Exiles Server"   | Server name shown in the browser (`ServerName`)                    |
| CONANEXILES_SERVER_PASSWORD          | ""                             | Password to join (empty = none) (`ServerPassword`)                 |
| CONANEXILES_ADMIN_PASSWORD           | ""                             | In-game admin password (`AdminPassword`)                           |
| CONANEXILES_MAX_PLAYERS              | 40                             | Maximum player slots (`-MaxPlayers` / `MaxPlayers`)                |
| CONANEXILES_GAME_PORT                | 7777                           | UDP game port (`-Port`)                                            |
| CONANEXILES_QUERY_PORT               | 27015                          | UDP Steam query port (`-QueryPort`)                               |
| CONANEXILES_PVP_ENABLED              | True                           | Enable player-vs-player combat (`PVPEnabled`)                      |
| CONANEXILES_MAX_NUDITY               | 2                              | Nudity level: 0=None, 1=Partial, 2=Full (`MaxNudity`)             |
| CONANEXILES_SERVER_REGION            | 0                              | Server region designation (`serverRegion`)                        |
| CONANEXILES_SERVER_COMMUNITY         | 0                              | Community type: 0=Purist, 1=Relaxed, 2=Hardcore, 3=Roleplaying... |
| CONANEXILES_BATTLEYE_ENABLED         | False                          | Enable BattlEye anti-cheat (`IsBattlEyeEnabled`)                   |
| CONANEXILES_LOGOUT_CHARACTERS_REMAIN | False                          | Characters stay in world after logout (`LogoutCharactersRemain...`)|
| CONANEXILES_PLAYER_DAMAGE_MULTIPLIER | 1.000000                       | Player damage dealt multiplier (`PlayerDamageMultiplier`)         |
| CONANEXILES_NPC_DAMAGE_MULTIPLIER    | 1.000000                       | NPC damage dealt multiplier (`NPCDamageMultiplier`)               |
| CONANEXILES_XP_RATE_MULTIPLIER       | 1.000000                       | Player XP gain multiplier (`PlayerXPRateMultiplier`)              |
| CONANEXILES_HARVEST_AMOUNT_MULTIPLIER| 1.000000                       | Resource harvest multiplier (`HarvestAmountMultiplier`)           |
| CONANEXILES_DAY_CYCLE_SPEED          | 1.000000                       | Day/night cycle speed scale (`DayCycleSpeedScale`)                |
| CONANEXILES_NO_OWNERSHIP             | False                          | Disable building ownership checks (`NoOwnership`)                  |
| CONANEXILES_ENABLE_PURGE             | True                           | Enable purge events (`EnablePurgeEvents`)                          |
| CONANEXILES_NET_SERVER_MAX_TICK_RATE | 30                             | Server network tick rate (`NetServerMaxTickRate`)                 |

## Server Administration

Set `CONANEXILES_ADMIN_PASSWORD` to enable in-game admin. In the game, open the admin
panel, enter the admin password, and make a character an admin to access spawn, teleport,
and moderation tools. There is no built-in RCON for Conan Exiles; administration is done
in-game via the admin panel.

## Notes

- The server is memory-hungry: budget ~16 GB RAM. An idle server uses roughly 6 GB.
- First boot is slow because the world and SQLite game database must be initialized
  under `/game/ConanSandbox/Saved/`. Give the readiness gate a generous timeout.
- Gameplay settings are rendered into
  `/game/ConanSandbox/Saved/Config/LinuxServer/ServerSettings.ini` and `Engine.ini`
  from the environment variables above.
- The raw UDP port (game port + 1, default 7778) must be open in addition to the game
  and query ports or clients may fail to connect.
