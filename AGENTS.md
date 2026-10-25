# AGENTS.md

Operating instructions for AI coding agents working in this repository
(frees-au/ce — the site that powers [frees.au](https://frees.au)).

## Skills

Global skills relative to this repo:
* ../ce-skills/skills/drupal-content-modeling
* ../ce-skills/skills/tailwind-theming

## Local skills

For adding a YouTube video article, use the repo-local
[`publish-video` skill](.agents/skills/publish-video/SKILL.md). It contains the
focused publishing workflow for this checkout.

For starting and stopping each piece of work
[`dev-session` skill](.agents/skills/dev-workflow/SKILL.md) explains config
git and database management and the context in which work will be done.

## Layout cheatsheet

```
web/                    Drupal docroot — never edit code here directly
web/core/               Drupal core (scaffolded, ignored by git)
web/sites/default/      settings.php, files/, *.settings.php
config/sync             Committed config
config/live             Active config used by Drupal directly (bypassing database).
database/live.sqlite    The live database — single SQLite file, committed-friendly.
drush/                  Drush config (self.site.yml)
drush/agent             A place to dump and run custom scripts `drush ev drush/agent/foo.php`
scripts/                Hermes-managed helper scripts (see scripts/README.md)
html/*                  Static site generation using ./scripts/site-generate-static.sh www.frees.au
```

## Proving work and debugging

Prefer to add procedural php scripts into drush/agent to bootstrap Drupal
and debug problems.
