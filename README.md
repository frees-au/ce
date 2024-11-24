# Free Sauce website

This code runs the https://frees.au/ce website. This site is a very simple
blog site, and used to support the creation of training videos which you can
find on the [Free Sauce youtube channel](https://www.youtube.com/@FreeTheSauce).

This code is licensed GPL-2.0-or-later. This code is provided for you to
examine and mock (in all senses of the term).

The Free Sauce logo, brand and assets which ship in this repository are Copyright
Free Sauce 2024. (Copy the theme if you want, but replace the logo and
company name please!).

## Backend

```
ddev start
ddev composer install
ddev load
```

When you're done.

```
# Tome build.
ddev tome

# Captures the database.
ddev save
```

## Frontend

This is a very simple and somewhat unfinished Tailwind theme with no base theme
dependencies. It's intended for learning and copying rather than being something
we expect you to use as a base theme. Please don't ask for support if you do 😬.

Install the css with the following command, just to get you started.

```
ddev frontend
```

## Testing

Static tests run easily in the container.

```
ddev test-static   # PHPStan and PHPCS.
ddev test-cypress  # Currently hangs locally, working in Github Actions.
```

Note that for Cypress E2E testing, the `ddev cypress` command works for us on
OSX, but note these are optimised for our local cypress experience and if we
can't predict if it will run for you on your machine. Read the code here
 `./ddev/commands/host/cypress`.

# Contrib

You can work on contrib modules in this repo. For example if you check out a
contrib module repo, you could run tests on the module.

```
ddev composer run-script phpcs -- ./web/modules/contrib/foo_module
ddev composer run-script phpcbf -- ./web/modules/contrib/foo_module
ddev composer run-script phpstan -- ./web/modules/contrib/foo_module
# phpunit tba
```
