# Satisfactory Server

This directory contains the configuration and scripts for running a Satisfactory
dedicated server using BipOps.

Satisfactory ships a native 64-bit Linux dedicated server that SteamCMD downloads
anonymously (server appid `1690800`; the store/library appid is the different
`526870`) and runs fully headless (`-log -unattended`) with no Wine or X display.

Unlike most games, a Satisfactory server has almost no file-based configuration: it
is **claimed and configured in-game** through the Server Manager after you first
connect to it. The only file BipOps renders is `Game.ini` for the player slot count.

## Quickstart

```bash
docker run --rm -it --name bip-ops \
  -e BIPOPS_GAMESERVER=satisfactory \
  -e SATISFACTORY_MAX_PLAYERS=4 \
  -p 7777:7777/udp \
  -p 7777:7777/tcp \
  -p 8888:8888/tcp \
  -v /path/to/gameservers/satisfactory/game:/game \
  -v /path/to/gameservers/satisfactory/backups:/backups \
  justmiles/bipops
```

First boot downloads the server (several GB) via SteamCMD, which can take a few
minutes. The server starts without a loaded session; you claim it and start/create
a session from the in-game Server Manager (see **Server Administration** below).

## Required Ports

| Port | Protocol | Description                                      |
| ---- | -------- | ------------------------------------------------ |
| 7777 | UDP      | Game traffic + Lightweight Query API (`-Port`)   |
| 7777 | TCP      | Server traffic + HTTPS API (`-Port`)             |
| 8888 | TCP      | Reliable messaging (`-ReliablePort`)             |

As of patch 1.1.0.0 the server uses the single `7777` port (UDP **and** TCP) plus
`8888/tcp`. Older guides mentioning separate `ServerQueryPort`/`BeaconPort` refer to
the pre-1.1 query path, which is now off by default.

## Volume Mounts

| Host Path                                 | Container Path | Description            |
| ----------------------------------------- | -------------- | ---------------------- |
| /path/to/gameservers/satisfactory/game    | /game          | Game files directory   |
| /path/to/gameservers/satisfactory/backups | /backups       | Backup files directory |

`start.sh` pins `$HOME` to `/game`, so Satisfactory writes all persistent state --
save games, the `ServerSettings.<port>.sav`, and the `Config/LinuxServer/*.ini`
files -- under `/game/.config/Epic/FactoryGame/Saved/`, which is what BipOps backs
up.

## Environment Variables

| Variable                        | Default | Description                                                            |
| ------------------------------- | ------- | ---------------------------------------------------------------------- |
| SATISFACTORY_MAX_PLAYERS        | 4       | Maximum player slots, written to `Game.ini` (`MaxPlayers`)             |
| SATISFACTORY_PORT               | 7777    | Game/server port, UDP + TCP (`-Port`)                                  |
| SATISFACTORY_RELIABLE_PORT      | 8888    | Reliable messaging port, TCP (`-ReliablePort`)                         |
| SATISFACTORY_SERVER_QUERY_PORT  | ""      | Legacy UDP query port (`-ServerQueryPort`); unset = disabled           |
| SATISFACTORY_BEACON_PORT        | ""      | Legacy UDP beacon port (`-BeaconPort`); unset = disabled               |

The server name, admin/client passwords, auto-pause, autosave interval, and most
gameplay options are **not** env vars -- they are set through the in-game Server
Manager and persisted in `ServerSettings.<port>.sav`.

## Server Administration

1. Launch **Satisfactory** and open **Server Manager** from the main menu.
2. Choose **Add Server** and enter the address `<host>:7777`.
3. Set the **Administrator Password** to claim the server (first connection only).
4. From the Server Manager you can:
   - Name the server and set an optional join password
   - **Create New Game** or **Load Game** to start/resume a session
   - Adjust autosave interval, auto-pause, restart interval, and network quality
   - Upload an existing save

## Notes

- `MaxPlayers` in `Game.ini` is the only file-based setting BipOps manages; the
  Server Manager may rewrite it on some operations, so treat it as the initial slot
  count.
- The server is tuned around 4 players; higher values are possible but not
  officially supported and cost more CPU/RAM.
- Because the server starts with no session loaded, the readiness check should
  confirm the process is **listening on 7777/udp**, not that a game is running.
