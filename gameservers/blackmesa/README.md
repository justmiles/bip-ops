# Black Mesa Server

This directory contains the configuration and scripts for running a Black Mesa
Deathmatch dedicated server using BipOps.

Black Mesa ships a native 32-bit Linux Source-engine (SRCDS) dedicated server that
SteamCMD downloads anonymously (Steam appid 346680) and runs fully headless (no Wine
or X display). The BipOps image enables i386 multilib so the 32-bit `srcds_linux`
binary runs.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=blackmesa \
  -e BLACKMESA_HOSTNAME="BipOps Black Mesa Server" \
  -e BLACKMESA_MAP=dm_crossfire \
  -e BLACKMESA_MAXPLAYERS=16 \
  -e BLACKMESA_RCON_PASSWORD=youradminpassword \
  -p 27015:27015/udp \
  -p 27015:27015/tcp \
  -v /path/to/gameservers/blackmesa/game:/game \
  -v /path/to/gameservers/blackmesa/backups:/backups \
  justmiles/bipops
```

First boot downloads the server files via SteamCMD (a few GB), which can take a few
minutes. The server launches via the shipped `./srcds_run -game bms` wrapper, which
auto-selects the 32-bit binary and sets `LD_LIBRARY_PATH`.

## Required Ports

| Port  | Protocol | Description                                   |
| ----- | -------- | --------------------------------------------- |
| 27015 | UDP      | Game traffic + Steam A2S query (`-port`)      |
| 27015 | TCP      | Source RCON (only active when a password set) |

## Volume Mounts

| Container path | Purpose                                             |
| -------------- | --------------------------------------------------- |
| `/game`        | Game installation (SteamCMD installs here)          |
| `/backups`     | rsnapshot backup storage                            |

BipOps backs up `/game/bms/cfg` (the mod's config directory, where `server.cfg`,
`mapcycle.txt`, and related settings live).

## Environment Variables

| Variable                   | Default                     | Description                                                 |
| -------------------------- | --------------------------- | ----------------------------------------------------------- |
| `BLACKMESA_HOSTNAME`       | `BipOps Black Mesa Server`  | Server name shown in the browser                            |
| `BLACKMESA_MAP`            | `dm_crossfire`              | Starting deathmatch map (see map list below)                |
| `BLACKMESA_MAXPLAYERS`     | `16`                        | Maximum player slots                                        |
| `BLACKMESA_PORT`           | `27015`                     | Game + query UDP port (and RCON TCP port)                   |
| `BLACKMESA_PASSWORD`       | _(empty)_                   | Password required to join (empty = public)                  |
| `BLACKMESA_RCON_PASSWORD`  | _(empty)_                   | Remote console admin password (empty disables RCON)         |
| `BLACKMESA_GSLT`           | _(empty)_                   | Game Server Login Token for app 346680 (public listing)     |
| `BLACKMESA_LAN`            | `0`                         | Restrict to LAN only (`1`) or internet-reachable (`0`)      |
| `BLACKMESA_CHEATS`         | `0`                         | Enable `sv_cheats`                                          |
| `BLACKMESA_TIMELIMIT`      | `20`                        | Minutes per map before rotation (`mp_timelimit`)            |
| `BLACKMESA_FRAGLIMIT`      | `0`                         | Frags to end a map (`mp_fraglimit`, 0 = no limit)           |
| `BLACKMESA_FRIENDLYFIRE`   | `0`                         | Enable friendly fire (`mp_friendlyfire`)                    |
| `BLACKMESA_FALLDAMAGE`     | `1`                         | Enable fall damage (`mp_falldamage`)                        |
| `BLACKMESA_FLASHLIGHT`     | `1`                         | Allow the flashlight (`mp_flashlight`)                      |
| `BLACKMESA_FOOTSTEPS`      | `1`                         | Enable audible footsteps (`mp_footsteps`)                   |
| `BLACKMESA_DOWNLOADURL`    | _(empty)_                   | Fast-download URL for custom content (`sv_downloadurl`)     |

## Deathmatch Maps

Official deathmatch maps include: `dm_bounce`, `dm_chopper`, `dm_crossfire`,
`dm_gasworks`, `dm_lambdabunker`, `dm_power`, `dm_stack`, `dm_stalkyard`,
`dm_subtransit`, `dm_undertow`.

Set the starting map with `BLACKMESA_MAP`. The rotation is driven by
`bms/cfg/mapcycle.txt` inside the `/game` volume.

## Admin Notes

- The server auto-executes `server.cfg` on map load (BipOps also passes `+exec server.cfg`).
- Set `BLACKMESA_RCON_PASSWORD` to administer the server remotely with any Source RCON
  client; RCON listens on the same port as the game (TCP).
- To list the server on the public Steam browser, supply a Game Server Login Token
  (GSLT) for app 346680 from https://steamcommunity.com/dev/managegameservers via
  `BLACKMESA_GSLT`. Anonymous servers still run for direct/LAN connects.
