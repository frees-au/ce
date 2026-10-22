---
name: dev-workflow
description: Whenever working on this repo, this guides git and config management.
---

# Overview

This site has a unique development workflow. It is not running anywhere else and the state is all local. When runnin, the site uses config and database on the files system.

## Reset state, site at reset

* No php server running (default 8888)
* database/live.sqlite is not edited (git status)
* Clean the config `rm config/live/*.yml && cp config/sync/*.yml config/live/`

## Start the site

* `./vendor/bin/drush serve`
* `./vendor/bin/drush uli`

## Build the theme

* `pnpm --dir web/themes/custom/fstheme install`
* `pnpm --dir web/themes/custom/fstheme run build`

## Config diff

`./vendor/bin/drush config:status` and related commands will effectively
show the difference between the ./config/live and ./config/sync.

## Save state

(Codex: the first time you read this make a script in scripts/save-state.sh and replace
these instructions)

* Config export (verify changes in ./config/live)
* Verify dirty state of database/live.sqlite

Before committing changes to config and database
* Truncate tables `config_export` and `config_import`
* VACUUM database/live.sqlite 
* Validate the integrity of the database
* If the database is over 10MB warn the user.
* Commit db and config.

## Finish

Stop the php server, tell the user.
