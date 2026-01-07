---
description: Add a new game server to BipOps
---

1. Create new gameserver directory
   - Create a directory for the new game server at `gameservers/<NEWGAMESERVER>/`.

2. Create .bip-ops.yaml
   - Create `gameservers/<NEWGAMESERVER>/.bip-ops.yaml` with the necessary game configuration details:
     - **game**: The display name of the game server
     - **usewine**: Boolean flag indicating whether to use Wine for Windows games on Linux (`true`/`false`)
     - **usex**: Boolean flag indicating whether to use X11 display server for games requiring GUI (`true`/`false`)
     - **steamid**: The Steam Application ID for the game (used by SteamCMD for downloads)
     - **backupdir**: Directory path within the container where game saves and data are stored
     - **configs**: Key/value mapping of configuration template files to their rendered locations within the container

3. Create start.sh
   - Create `gameservers/<NEWGAMESERVER>/start.sh` - the launch command for the game server.

4. Create configuration templates (if applicable)
   - If the game server has configuration files, create the go template for the files in `gameservers/<NEWGAMESERVER>/config/<TEMPLATE>`.
   - Ensure all variables are sourced from environment using the `(getenv "<GAMESERVER>_<VAR>" "<DEFAULT>")` idiom.

5. Create README.md
   - Create `gameservers/<NEWGAMESERVER>/README.md` - documentation for the game server including all available environment variables.
   - Readme should contain a quickstart example for how to run the gameserver using `docker`

6. Review examples
   - Review existing `gameservers/` for examples.

7. Update README.md to include <NEWGAMESERVER> under Supported Games.