# scripts/

Local build helpers for the Free Sauce / frees.au Drupal site.

## Layout

```
scripts/
├── fs-done.sh             # "Definition of done" pipeline (config export + commit + backup)
├── README.md              # You are here
└── includes/
    ├── ContentHelpers.php       # Reusable entity/config helpers (BlockCreationTrait style)
    └── ContentHelpersTrait.php  # Trait wrapper so Drush commands can `use` it
```

## Drush commands

The Drush command class lives at `drush/Commands/fs/FsCommands.php` (Drush 13+
auto-discovers anything under `drush/Commands/`). It uses `ContentHelpersTrait`
so every command has a `$this->helpers()` accessor.

Available:

- `drush fs:doctor` — sanity-check bootstrap
- `drush fs:create-node <bundle> <title>`
- `drush fs:place-block <plugin_id> [--region=...] [--theme=...]`
- `drush fs:set-config <name> <key> <value>`

## Conventions

- New helpers go in `includes/ContentHelpers.php` (or a new class in the same
  namespace) following the pattern of `BlockCreationTrait`: merge defaults
  with `+=`, read config from the live container, return entity objects.
- New one-off scripts get their own file under `scripts/`, prefixed with the
  Drush command name they implement (e.g. `fs-*.sh`).
- Always run `./vendor/bin/drush` from the repo root — never from `web/`.