# SCUM

Dedicated server for [SCUM](https://store.steampowered.com/app/513710/SCUM/).

SCUM ships only a Windows dedicated-server binary, so bip-ops runs it under distro
Wine (`usewine: true`). The server is a headless UE4 console, so it needs no X11
display (`usex: false`).

| | |
|---|---|
| Steam App ID (dedicated server) | `3792580` |
| Runtime | Wine (distro), headless |
| Server binary | `SCUM/Binaries/Win64/SCUMServer.exe` |
| Save / backup dir | `/game/SCUM/Saved` |
| Settings file | `SCUM/Saved/Config/WindowsServer/ServerSettings.ini` |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SCUM_PORT` | `7777` | Game port. SCUM also binds `PORT+1` and `PORT+2`; clients connect to `PORT+2`. |
| `SCUM_MAX_PLAYERS` | `64` | Maximum players (passed as `-MaxPlayers` and mirrored into `scum.MaxPlayers`). |
| `SCUM_SERVER_NAME` | _(game default)_ | Server browser name (`scum.ServerName`). |
| `SCUM_SERVER_DESCRIPTION` | _(game default)_ | Server description (`scum.ServerDescription`). |
| `SCUM_SERVER_PASSWORD` | _(empty)_ | Join password (`scum.ServerPassword`). |
| `SCUM_MAX_PING` | _(game default)_ | Max allowed ping in ms (`scum.MaxPing`). |
| `SCUM_WELCOME_MESSAGE` | _(game default)_ | Message shown on join (`scum.WelcomeMessage`). |
| `SCUM_EXTRA_ARGS` | _(empty)_ | Extra raw flags appended to the launch command. |

### How settings are applied

`ServerSettings.ini` holds ~437 keys across six sections and is generated and owned
by the game on first boot. bip-ops does **not** template or overwrite the whole file.
Instead `start.sh` upserts only the headline keys you set via the env vars above,
preserving every other key and any manual edits. Keys you leave unset are backfilled
by the game with its own defaults.

To tune the hundreds of advanced settings not exposed as env vars, let the server
boot once, stop it, edit `SCUM/Saved/Config/WindowsServer/ServerSettings.ini`
directly, and start it again. Those edits survive restarts (only the env-managed
keys are rewritten). `SCUM/Saved` is included in rsnapshot backups.

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 7777 | UDP | Game port (`SCUM_PORT`) |
| 7778 | UDP | `PORT+1` |
| 7779 | UDP | `PORT+2` -- Steam query / client connection port |

Forward the whole `7777-7779/udp` range.

## Docker Run Example

```bash
docker run -d --name scum \
  -e BIPOPS_GAMESERVER=scum \
  -e SCUM_SERVER_NAME="My SCUM Server" \
  -e SCUM_MAX_PLAYERS=64 \
  -p 7777-7779:7777-7779/udp \
  -v /path/to/game:/game \
  -v /path/to/backups:/backups \
  justmiles/bipops
```

## Notes

- First launch downloads the server and generates the initial `ServerSettings.ini`;
  give it extra time before the server appears in the browser.
- SCUM uses BattlEye anti-cheat. If BattlEye causes problems under Wine, pass a
  disable flag via `SCUM_EXTRA_ARGS` or turn it off in `ServerSettings.ini`.
