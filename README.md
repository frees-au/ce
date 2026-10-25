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
* How can we use recipes to remove the need for persistent database?
* How good is static site generation?
* What will the agent do with it?

## Requirements

* SQLite
* PHP 8.3 (with opcache.enable_cli)
* php composer to build app
* node/pnpm to build frontend

## Build backend

Install the backend dependencies, then rebuild the site from committed
configuration and exported content.

You can remove database/live.sqlite first unless its got some that's not exported yet.

```sh
composer install
composer run-script build-site
```

After a successful build, the command offers to start the local site in the
foreground and open it in the default browser.

Start the local site:

```sh
# Run in foreground
./vendor/bin/drush serve /
# Login (switch to different tab)
./vendor/bin/drush uli
```

## Build frontend

This is a very simple Tailwind theme with no Drupal "base theme" dependencies. 

The theme uses [pnpm](https://pnpm.io/) for frontend dependencies. Install it
once (e.g. via [corepack](https://nodejs.org/api/corepack.html): `corepack enable`)
then run the build.

```sh
composer run-script build-fe
```

This installs the theme dependencies, builds the frontend, then watches for
changes and rebuilds automatically. Leave it running while developing; press
Ctrl+C to stop.

## Static Site generation

Generates the static export into `html/` at the repo root (gitignored).

```
# Build the static site into ./html/www.frees.au
composer run-script make-static www.frees.au
```

## Testing

@todo - rewire cypress.

```sh
composer run-script phpcs
composer run-script phpcbf
composer run-script phpstan
```
