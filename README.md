# Free Sauce website.

This code runs the https://frees.au/ce website. This site is a very simple
blog site, and used to support the creation of training videos which you can
find on the [Free Sauce youtube channel](https://www.youtube.com/@FreeTheSauce).

This code is licensed GPL-2.0-or-later. This code is provided for you to
examine and mock (in all senses of the term).

The Free Sauce logo, brand and assets which ship in this repository are Copyright
Free Sauce 2024-2026. (Copy the theme if you want, but replace the logo and
company name please!).

## Backend

Setup uses SQLite only. The database is stored in `database/live.sqlite`;

## Static Site generation (@todo fix)

```
# Tome build.
ddev tome

# Deploy to S3 (Skips repushing stockart).
aws s3 cp static-site s3://frees-au-static/ --recursive --exclude "themes/custom/fstheme/stockart/*"

# Captures config and trims transient SQLite table data.
ddev save
```

## Frontend (@todo fix)

This is a very simple and somewhat unfinished Tailwind theme with no base theme
dependencies. It's intended for learning and copying rather than being something
we expect you to use as a base theme. Please don't ask for support if you do 😬.

Normally you'd just work out of the theme directory, but these commands will run
build and watch from the repo root.

The theme uses [pnpm](https://pnpm.io/) for frontend dependencies. Install it
once (e.g. via [corepack](https://nodejs.org/api/corepack.html): `corepack enable`)
then run the build.

```
pnpm --dir web/themes/custom/fstheme install
pnpm --dir web/themes/custom/fstheme run build
pnpm --dir web/themes/custom/fstheme run watch
```

## Testing (@todo fix)

Static tests run easily in the container.

```
ddev test-static   # PHPStan and PHPCS.
ddev test-cypress  # Currently hangs locally, working in Github Actions.
```

Note that for Cypress E2E testing, the `ddev cypress` command works for us on
OSX, but note these are optimised for our local cypress experience and if we
can't predict if it will run for you on your machine. Read the code here
 `./ddev/commands/host/cypress`.

# Contrib (@todo fix)

You can work on contrib modules in this repo. For example if you check out a
contrib module repo, you could run tests on the module.

```
ddev composer run-script phpcs -- ./web/modules/contrib/foo_module
ddev composer run-script phpcbf -- ./web/modules/contrib/foo_module
ddev composer run-script phpstan -- ./web/modules/contrib/foo_module
# phpunit tba
```
