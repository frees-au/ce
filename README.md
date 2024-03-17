# Free Sauce website

This code runs the https://frees.au/ce website. This site is a very simple
blog site, and used to support the creation of training videos which you can
find on the [Free Sauce youtube channel](https://www.youtube.com/@FreeTheSauce).

This code is licensed GPL-2.0-or-later. This code is provided for you to
examine and mock (in all senses of the term).

The Free Sauce logo, brand and assets which ship in this repository are Copyright
Free Sauce 2024. (Copy the theme if you want, but replace the logo and
company name please!).

## Philosophy

The goal of this project is to build Drupal as simple and elegantly as possible while
also being an actual production codebase. There is a mix of best practice, personal
preference and practicality.

There is zero intention to package this up as a product or distribution. This is because
Drupal moves fast, and we want this project to keep up with it.

Please feel free to [discuss](https://github.com/frees-au/ce/discussions) anything you
like. You can be critical too. If you like a conversational approach to reviewing this
code, check out the video below.

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/qUJpx5w0avM/0.jpg)](https://www.youtube.com/watch?v=qUJpx5w0avM)

## Backend

Everything is ready to run locally on [DDEV](https://drupal.org/project/default_content).
We intend to add Lando added (see docker.settings.php) and will duplicate the
DDEV utility commands for Lando.

But for now if you have DDEV you can build the site without a copy of the database.

```
ddev start
ddev composer install
ddev scratch    # Build the site with content captured in fs_test module.
ddev drush uli
```

If you are an employee with access to the hosting environment you can do
`ddev refresh`. And @see .ddev/commands/host for more.

## Frontend

This is a very simple and somewhat unfinished Tailwind theme with no base theme
dependencies. It's intended for learning and copying rather than being something
we expect you to use as a base theme. Please don't ask for support if you do 😬.

```
cd web/themes/custom/fstheme
npm ci
npm run watch
```

## Testing

Static tests run easily in the container.

```
ddev static   # PHPStan and PHPCS.
ddev cypress  # Currently hangs locally, working in Github Actions.
```

Note that for Cypress E2E testing, the `ddev cypress` command works for us on
OSX, but note these are optimised for our local cypress experience and if we
can't predict if it will run for you on your machine. Read the code here
 `./ddev/commands/host/cypress`.

## Building from scratch

This site is open source but our production database isn't, so we provide the
ability to build it from scratch using `ddev scratch`. This installs a minmal
Drupal site, imports the config, and adds some baseline content that is captured
in the `fs_test` module to create a fully functioning site.

This type of build is great for e2e integration testing since it doesn't need
access to production database sync or database stubs. It is supported by the
excellent [Default Content](https://drupal.org/project/default_content) module.
