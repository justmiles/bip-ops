# StarRupture

## Quick Start

```bash
docker run -d \
  -e BIPOPS_GAMESERVER=starrupture \
  -e STARRUPTURE_SERVER_NAME="BipOps StarRupture Server" \
  -p 7777:7777/tcp \
  -p 7777:7777/udp \
  -v /path/to/backups:/game/Saved \
  --name starrupture \
  justmiles/bip-ops
```

1. Port Forwarding

   - Forward port 7777 to your server's IP address.
   - Identify your public IP address (you can find it using whatsmyip.org or a similar site).
   - NOTE: When joining the game, you will need to use the public IP address. You can manage the server using either private or public IP address, but for joining the game, you will need to use the public IP address.

2. Initial Setup

   - After launching your server, open the game on the machine where you'll be playing.
   - Go to Manage Server.
   - Enter the server IP address
   - If this is the first time you're setting up the server, you'll be prompted to set a password.

3. Create a New Game

   - Set a server password if desired (this is different from the password you set in Manage Server)
   - Click New Game, enter a server name, and then click Start.
   - KNOWN ISSUE: There is no UI indiciation that the server has started. You will see activity in the server logs, but nothing in the Game Manager UI.
   - Press Escape to return to the main menu.

4. Connect to the Server

   - Navigate to Join Game → Dedicated.
   - Enter your **public** IP address and the server password (if you set one).
   - You should now be able to connect to your server.

5. Restarting the Server

   - Each time the server restarts, you'll need to repeat the Manage Server setup.
   - Instead of choosing New Game, click Load Game.
   - Select your previously created server name, then click Start (or Launch, depending on the version).

## Environment Variables

| Variable                  | Default                     | Description                          |
| ------------------------- | --------------------------- | ------------------------------------ |
| `STARRUPTURE_SERVER_NAME` | `BipOps StarRupture Server` | Name of the server                   |
| `STARRUPTURE_IP`          | `0.0.0.0`                   | IP to bind to                        |
| `STARRUPTURE_GAME_PORT`   | `7777`                      | Game port (UDP)                      |
| `STARRUPTURE_MAX_PLAYERS` |                             | Maximum number of players (optional) |

## Ports

- `7777/udp` - Game
- `7777/tcp` - Game
