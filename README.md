# Free Sauce website

**Warning** This site is weird. It has experimental stuff.

This code runs the https://www.frees.au/ce website. This site is a very simple
business site. I also use it as a scratch pad for videos on the [Free Sauce youtube channel](https://www.youtube.com/@FreeTheSauce).

The Free Sauce logo, brand and assets which ship in this repository are Copyright
Free Sauce 2024-2026. (Copy the theme if you want, but replace the logo and
company name please!).

## Philosophy

This code base tries to answer the questions:

* How small can Drupal be?
* Is Drupal fast with just PHP and SQLite?
* What if we put the database in git?
* How good is static site generation?
* What will the agent do with it?

## Requirements

* SQLite
* PHP 8.3 (with opcache.enable_cli)
* php composer
* node/pnpm to build frontend

## Build backend

```
# Build drupal
composer up
# Reset config.
rm config/live/*.yml && cp config/sync/*.yml config/live/
# Run in foreground
drush serve
# Login (switch to different tab)
drush uli
```

## Frontend

This is a very simple Tailwind theme with no Drupal "base theme" dependencies. 

The theme uses [pnpm](https://pnpm.io/) for frontend dependencies. Install it
once (e.g. via [corepack](https://nodejs.org/api/corepack.html): `corepack enable`)
then run the build.

```
pnpm --dir web/themes/custom/fstheme install
pnpm --dir web/themes/custom/fstheme run build
pnpm --dir web/themes/custom/fstheme run watch
```

## Static Site generation

Generates the static export into `html/` at the repo root (gitignored).

```
# Build the static site into ./html/www.foo.com
./scripts/build-static.sh www.foo.com
```

## Testing

@todo - rewire cypress.

```sh
composer run-script phpcs
composer run-script phpcbf
composer run-script phpstan
```
