# Free Sauce website

This code runs the https://frees.au/ce website. This site is a very simple
blog site, and used to support sharing of training videos which you can
find on the [Free Sauce youtube channel](https://www.youtube.com/@FreeTheSauce)
and business information.

Github is hosted on an internal repo on Forgejo, and the Github repo is a mirror.

This code is licensed GPL-2.0-or-later. This code is provided for you to
examine and mock.

The Free Sauce logo, brand and assets which ship in this repository are Copyright
Free Sauce 2024-2026. (Copy the theme if you want, but replace the logo and
company name please!).

## Requirements

* SQLite only @see `database/live.sqlite`
* PHP 8.3 (suggest opcache.enable_cli)
* pnpm

## Static Site generation

Generates the static export into `.html/` at the repo root (gitignored).

```
# Build the static site.
./scripts/build-static.sh
```

## Frontend (@todo fix)

This is a very simple Tailwind theme with no Drupal "base theme" dependencies. 

The theme uses [pnpm](https://pnpm.io/) for frontend dependencies. Install it
once (e.g. via [corepack](https://nodejs.org/api/corepack.html): `corepack enable`)
then run the build.

```
pnpm --dir web/themes/custom/fstheme install
pnpm --dir web/themes/custom/fstheme run build
pnpm --dir web/themes/custom/fstheme run watch
```

## Testing

@todo - rewire cypress.

ddev composer run-script phpcs -- ./web/modules/contrib/foo_module
ddev composer run-script phpcbf -- ./web/modules/contrib/foo_module
ddev composer run-script phpstan -- ./web/modules/contrib/foo_module
