---
description: Add a game server to the bipops-ui catalog (sibling repo)
argument-hint: <gameserver-name>
---

Add the game server `$ARGUMENTS` to the **bipops-ui** catalog so it appears in the UI.

bipops-ui does **not yet** auto-discover game servers from this repo's `gameservers/`
directory. It has **two** hand-authored catalog surfaces, and a game must be added
to **both**:

1. **Backend HCL catalog** — `../bipops-ui/backend/game_configs/*.hcl`. On backend
   startup, `SyncGameConfigs` reads every `*.hcl` in that directory (files ending
   in `.disabled` are skipped) and upserts them into the `game_configs` table.
   This drives provisioning (sizes, ports, env-var form fields).
2. **Frontend landing-page catalog** — `../bipops-ui/site/src/data/games.ts` plus
   a matching image asset in `../bipops-ui/site/src/assets/games/`. This drives the
   marketing/catalog cards. It is separate from the HCL, so a game can exist in one
   and be missing from the other (a common miss).

Prerequisite: the game server already exists in this repo (`/add-gameserver`) and
its image has been published (`/publish-gameserver`), so you know the env vars and
the Docker image tag to reference.

Follow these steps:

1. Review the source of truth
   - Read `gameservers/<GAMESERVER>/.bip-ops.yaml`, `start.sh`, `config/*`, and
     `README.md` to collect the game's `ENV` variables, ports, and display name.
   - Review existing `../bipops-ui/backend/game_configs/*.hcl` for examples
     (`theforest.hcl` is a good Wine/Steam example; `starrupture.hcl` is minimal).
   - Confirm the schema in
     `../bipops-ui/backend/bipopsd/database/game_config_hcl.go` (structs +
     `validateGame`) hasn't changed.

2. Create `../bipops-ui/backend/game_configs/<GAMESERVER>.hcl`
   - Single `game "<GAMESERVER>" { ... }` block. Keep blocks in the order the
     linter enforces (see `../bipops-ui/scripts/lint-game-configs.sh`):
     1. `display_name`
     2. `source_server_name` (optional) — the env var holding the server name
     3. `source_max_players` (optional) — the env var holding the slot/player count
     4. `readme` (heredoc `<<-MD ... MD`) — "How to Connect" + "Getting Started".
        May reference `{{.IP}}`, `{{.Port}}`, and `{{index .EnvVars "VAR"}}`.
     5. `size` blocks — one or more tiers with `label`, `vcpu`, `memory_gb`,
        `storage_gb`, `price_per_hour` (**minimum 5**, in cents/hr), `max_players`.
     6. `port` blocks — `internal`, `protocol` (`udp`/`tcp`), optional `env`
        (the env var that sets the port). **Exactly one** port must have
        `primary = true`.
     7. `system_env_var` blocks (not user-visible):
        - `DOCKER_IMAGE` → the published image + tag (match the tag other configs
          pin, e.g. the one from the latest `/publish-gameserver`).
        - `BIPOPS_GAMESERVER` → `<GAMESERVER>`.
        - the slot/players var (referenced by `source_max_players`) → `"0"`
          (the size tier overrides it at provision time).
     8. `env_var` blocks — a curated subset of the game's `<GAMESERVER>_*`
        variables as UI form fields: `label`, `type` (`string` | `number` |
        `select`), `options` (for `select`), `default`, `doc`.

3. Add to the frontend landing-page catalog
   - Edit `../bipops-ui/site/src/data/games.ts`:
     - Add an image import at the top: `import <name>Img from '@/assets/games/<GAMESERVER>.png'`.
     - Append a `GameProfile` object to the `games` array (`id`, `name`,
       `tagline`, `description`, `image`, `genre`, `players`, `startingPrice`).
       Keep `players` and `startingPrice` consistent with the HCL `size` tiers
       (widest player range; cheapest tier's `price_per_hour`, in cents/hr).
   - Install the image asset `../bipops-ui/site/src/assets/games/<GAMESERVER>.png`:
     - **Install a proper image whose bytes match its extension.** A `.png` file
       must be real PNG data (magic `89 50 4e 47`). Do **not** rename a JPEG to
       `.png`. Note: some existing assets are historically JPEGs mislabeled `.png`
       — do not copy that mistake; honor the actual file type.
     - Source real key art (do not ship a placeholder): the Steam library capsule
       is a good square-croppable source —
       `https://cdn.cloudflare.steamstatic.com/steam/apps/<STEAM_APPID>/library_600x900_2x.jpg`
       (find the store app id, distinct from the dedicated-server `steamid` in
       `.bip-ops.yaml`). Center-crop to a square and resize to **1024x1024** to
       match the other assets. The import is a Vite asset — if the file is missing,
       the site build fails.
     - Do image work in Go (std `image`/`image/png` + `golang.org/x/image/draw`
       for high-quality scaling); `identify`/ImageMagick/`file` are not installed.
       Verify the result visually and confirm PNG magic bytes before installing.

4. Validate before committing
   - `cd ../bipops-ui`
   - `bash scripts/lint-game-configs.sh` — enforces block ordering.
   - Confirm the file parses and passes `validateGame` (exactly one primary port,
     every `price_per_hour` >= 5, required fields present). Prefer
     `go test ./backend/bipopsd/database/ -run TestParseRealGameConfigs`; if the
     package can't build here (it needs cgo/sqlite), decode the file with the
     `hcl/v2` `hclsimple` library against a copy of the structs instead.

5. Commit and deploy (only when asked)
   - Commit **only** this game's files — the new `<GAMESERVER>.hcl`, the
     `games.ts` edit, and the new `assets/games/<GAMESERVER>.png` (don't sweep in
     unrelated working-tree changes in bipops-ui).
   - `git fetch` and confirm the branch is current (rebase, don't merge, if it
     moved) before pushing `main`.
   - Pushing `main` triggers `.gitea/workflows/ci.yml`, which builds/tests and
     pushes the bipops-ui image. The new game appears in the UI after the backend
     restarts and re-runs `SyncGameConfigs`.
