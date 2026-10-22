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

* Run `bash scripts/save-state.sh` to export configuration, empty transient
  config tables when present, compact SQLite, check integrity, and report size.
* Review the config and database changes before committing them.

## Finish

Stop the php server, tell the user.
