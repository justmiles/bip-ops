---
description: Publish BipOps container image
argument-hint: [TAG]
allowed-tools: Bash(make publish:*), Bash(git tag:*), Bash(git describe:*)
---

Tag the built image to the registry and publish it.

Determine the tag to publish:

1. If `$ARGUMENTS` was provided, use it verbatim as the tag.
2. Otherwise, derive the next tag from the latest git tag:

   ```bash
   git tag --sort=-v:refname | head -1
   ```

   The repo uses `vMAJOR.MINOR.PATCH` semver (e.g. `v0.6.1`). Bump from the latest tag:
   - **Patch bump (default):** for a change to an existing game server, a bug fix, or any
     other change. Increment PATCH (e.g. `v0.6.1` -> `v0.6.2`).
   - **Minor bump:** only when adding a brand-new game server. Increment MINOR and reset
     PATCH to 0 (e.g. `v0.6.1` -> `v0.7.0`).
   - **Major bump:** never do this automatically. Major version bumps are done by a human;
     if a major bump seems warranted, stop and ask.

Then publish with the resolved tag:

```bash
make publish TAG=<resolved-tag>
```
