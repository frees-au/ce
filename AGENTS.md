# AGENTS.md

Operating instructions for AI coding agents working in this repository
(frees-au/ce — the site that powers [frees.au](https://frees.au)).

> This is the in-repo cheatsheet. The full procedural guide — including
> the definition-of-done pipeline, environment caveats, and Drush helper
> patterns — lives in the Hermes skill at
> [`projects/frees-au-ce`](https://github.com/frees-au/hermes-config/blob/main/skills/projects/frees-au-ce/SKILL.md).
> Load it before doing any non-trivial work.

## What this repo is

A Drupal 10 site (Tome-compatible) on a single SQLite database, themed with
`fstheme` (Tailwind, no base theme). Originally built to host training videos
from the Free Sauce YouTube channel. No commerce, no users beyond uid 1 in
practice.

## Layout cheatsheet

```
web/                    Drupal docroot — never edit code here directly
web/core/               Drupal core (scaffolded, ignored by git)
web/sites/default/      settings.php, files/, tome.settings.php
config/                 Exported config (committed). Drupal's config:sync dir.
database/live.sqlite    The live database — single SQLite file, committed-friendly.
drush/                  Drush config (self.site.yml) + custom Commands/fs/
scripts/                Hermes-managed helper scripts (see scripts/README.md)
scripts/includes/       PHP helpers — start with ContentHelpers.php
```

## Day-to-day commands

All commands run from the **repo root**.

```bash
./vendor/bin/drush status                    # confirm DB is reachable
./vendor/bin/drush config:export              # write config/ changes
./vendor/bin/drush config:import              # apply config/ to the DB
./scripts/fs-done.sh "Short message"         # full "done" pipeline
./vendor/bin/drush fs:doctor                 # confirm ContentHelpers loads
./vendor/bin/drush fs:create-node article "Title"
```

Browser-based QA happens on `www-edit.frees.au`, not on this host.

## Hard rules

1. **The host has no working webserver.** Do not curl `http://localhost:*`
   expecting the site to respond. Edit → `drush` → confirm with Si on
   `www-edit.frees.au`.
2. **There is no DDEV.** Use Drush directly. The README's `ddev …` snippets
   are aspirational and do not run on this host.
3. **Drush must be run from the repo root**, not from `web/`. The DB path
   in settings.php is relative.
4. **One branch: `nash-local`.** Commit and push there. Don't create feature
   branches unless Si asks. (Exception: feature branches for PR review
   on the local Forgejo — see `forgejo` skill.)
5. **Remote layout** (changed 2026-08-15; switched to SSH 2026-08-15):
   - `origin` → `ssh://git@git-local.frees.au/frees-au/ce.git` (internal Forgejo, canonical)
   - `forgejo` → `ssh://git@git-local.frees.au/frees-au/ce.git` (duplicate of origin; kept for branch-name compat with earlier conventions)
   - `github` → `git@github.com:frees-au/ce.git` (mirror, manual push only)
   - Never force-push. `git pull --rebase` for reconciliation.
   - Note: `.git/config` may still hold a stale `[credential] helper = store --file=…` entry from the prior HTTPS layout — harmless under SSH but can be removed if Si prefers a tidy config.
6. **Don't edit `web/core/`, `web/modules/contrib/`, `web/themes/contrib/`**
   — they are scaffolded and ignored. Use Composer for contrib updates.
7. **Definition of done** for any change that touches the live site:
   - Si has eyeballed the change on `www-edit.frees.au`
   - `./vendor/bin/drush config:export` ran clean
   - Committed and pushed to `nash-local`
   - DB + `web/sites/default/files` snapshot in
     `~/backups/frees-au-ce/YYYY-MM-DD--HH-MM/`
   - The `./scripts/fs-done.sh` helper does steps 2–4 in one shot.
8. **Drush subcommands that touch the DB must declare a FULL bootstrap.**
   The custom `fs:*` commands use
   `#[BootstrapAttr(level: DrupalBootLevels::FULL)]` at the class level.
   Any new command file in `drush/Commands/` must do the same or it will
   blow up with `\Drupal::$container is not initialized yet`.

## When in doubt

Prefer adding a Drush helper (`drush/Commands/fs/`) + a method on
`ContentHelpers` over one-off shell scripts. They survive across sessions
and are testable.