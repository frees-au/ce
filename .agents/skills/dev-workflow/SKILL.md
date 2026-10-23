---
name: dev-workflow
description: Prepare, change, verify and save the local CE Drupal site using its Composer workflow, with SQLite integrity and review of generated Git changes.
---

# Overview

The local site uses file-backed active configuration in `config/live` and SQLite
at `database/live.sqlite`. Saved work is represented by committed configuration
in `config/sync` and the site-export recipe in `recipes/site_export`.
Use the Composer entrypoints defined in `composer.json` for loading, saving and
theme builds; inspect their current implementations if their behaviour matters.

## Prepare a session

* Inspect `git status --short` and preserve existing changes.
* For a clean checkout, run `composer install`, then `composer site-load`.
  Loading requires an absent or empty SQLite database; it refuses a database
  containing tables. Do not delete an existing database to bypass that guard
  without authorization to rebuild the site.
* `composer site-load` clears active YAML configuration, removes generated
  oEmbed thumbnails, installs from existing configuration, imports recipe
  content, restores exported aliases against the new entity IDs, reimports
  configuration, sets the front page to `/ce` and rebuilds caches.
* For an existing working site, continue from its current state rather than
  reloading it. Do not assume exported numeric entity IDs survive a reload.

## Start the site

* `./vendor/bin/drush serve`
* `./vendor/bin/drush uli`

The default server port is 8888. Preserve a server the user has already started.
Start or stop it only as authorized by the task; report any server changes.

## Build the theme

Run `composer build-fe`. It installs the theme's pnpm dependencies and runs its
build in `web/themes/custom/fstheme`.

## Make and verify changes

Use repository-local `./vendor/bin/drush` for Drupal configuration and content
changes. Prefer procedural PHP scripts under `drush/agent` for focused entity
updates and debugging. Verify the saved entities and references relevant to the
task.

`./vendor/bin/drush config:status` and related commands will effectively
show the difference between the ./config/live and ./config/sync.

Keep the live SQLite database and its WAL/SHM sidecars together during the
session; do not delete, move or replace them while the site is in use. Verify
SQLite integrity after loading, after substantial data changes and before the
final handoff, using a read-only check such as:

```bash
php -r '$db = new PDO("sqlite:database/live.sqlite", null, null, [PDO::SQLITE_ATTR_OPEN_FLAGS => PDO::SQLITE_OPEN_READONLY]); foreach ($db->query("PRAGMA integrity_check") as $row) { echo $row[0], PHP_EOL; }'
```

The expected result is `ok`. Investigate any other result before continuing with
data changes. Do not run this against a missing database or assume Git status
proves database integrity.

## Save state

Run `composer site-save` after completing the authorized configuration/content
work. It exports configuration to `config/sync`, then overwrites
`recipes/site_export` using `site:export --no-assets`. It removes the recipe's
duplicate `config` directory and exported `content/file` directory. This saves
the capturable configuration and content state, not a SQLite backup or an asset
backup. The script does not compact SQLite or verify its integrity.

## Finish

Review `git status --short` and the final diff, including generated changes in
both `config/sync` and `recipes/site_export`. Include the relevant generated
files, additions and deletions in Git when saving the task's work; do not omit
the recipe or mix in unrelated changes. Commit only when authorized by the task
or user. Report verification results and any export warnings or limitations.
