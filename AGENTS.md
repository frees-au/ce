# AGENTS.md

Operating instructions for AI coding agents working in this repository
(frees-au/ce — the site that powers [frees.au](https://frees.au)).

> This is the in-repo cheatsheet. The full procedural guide — including
> the definition-of-done pipeline, environment caveats, and Drush helper
> patterns — lives in the Hermes skill at
> [`projects/frees-au-ce`](https://github.com/frees-au/hermes-config/blob/main/skills/projects/frees-au-ce/SKILL.md).
> Load it before doing any non-trivial work.

For adding a YouTube video article, use the repo-local
[`publish-video` skill](.agents/skills/publish-video/SKILL.md). It contains the
focused publishing workflow for this checkout and supersedes the external
guide's video-publishing and host-specific instructions.

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
.html                   Static site generation.
```

## Day-to-day commands

All commands run from the **repo root**.

```bash
./vendor/bin/drush status                    # confirm DB is reachable
./vendor/bin/drush fs:doctor                 # confirm ContentHelpers loads
./vendor/bin/drush fs:create-node article "Title"
```

Browser-based QA happens on `http://127.0.0.1:8888` (this host, port might change).

## Hard rules

1. **The host has a webserver on `http://127.0.0.1:8888`.** Edit →
   `drush` → confirm with Si on the same host.
2. **There is no DDEV.** Use Drush directly. The README's `ddev …` snippets
   are aspirational and do not run on this host.
3. **Drush must be run from the repo root**, not from `web/`. The DB path
   in settings.php is relative.
4. **One branch: `nash-local`.** Commit and push there. Don't create feature
   branches unless Si asks. (Exception: feature branches for PR review
   on the local Forgejo — see `forgejo` skill.)
5. **Don't edit `web/core/`, `web/modules/contrib/`, `web/themes/contrib/`**
   — they are scaffolded and ignored. Use Composer for contrib updates.
7. **Drush subcommands that touch the DB must declare a FULL bootstrap.**
   The custom `fs:*` commands use
   `#[BootstrapAttr(level: DrupalBootLevels::FULL)]` at the class level.
   Any new command file in `drush/Commands/` must do the same or it will
   blow up with `\Drupal::$container is not initialized yet`.

## Proving work and debugging

Prefer to add procedural php scripts into drush/agent to bootstrap Drupal
and debug problems.
