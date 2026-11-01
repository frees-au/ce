# Free Sauce website

This code runs the https://www.frees.au/ce website. This site is a very simple
business site. I also use it as a scratch pad for videos on the [Free Sauce youtube channel](https://www.youtube.com/@FreeTheSauce).

The Free Sauce logo, brand and assets which ship in this repository are Copyright
Free Sauce 2024-2026. (Copy the theme if you want, but replace the logo and
company name please!).

## 🚨 Heads up 🚨

You can install a complete website on your personal computer. This repo has
*everything* needed to duplicate frees.au/ce website.

Would you use this for publicly hosted Drupal website? No! It would fall over.

Can you hack it up and use it for your own *static* website? Yep.

## Philosophy

Aside from, you know, running our business website, this project tries to
answer the questions:

* How "small" can Drupal be? (Pretty tight.)
* Is static site good? (Yep.)
* Is Drupal fast with just PHP and SQLite? (Yes!)
* Is "always on" PHP hosting dead? (Well...) 
* What will the agent do with it? (No mistakes?)

## Requirements

It's out of scope of this README to help you run these:

* PHP 8.3+ ჻ `php --version`
* PHP Composer 2+ ჻ `composer --version`
* SQLite 3 ჻ `sqlite3 --version`
* node 22+ ჻ `node -v`
* pnpm ჻ `pnpm -v` 
* [concurrently](https://www.npmjs.com/package/concurrently) ჻ `conc -v`

Also recommended:

* PHP Opcache `$ php -i | grep opcache.enable_cli`

And for hosting:

It's just HTML so anywhere you can host HTML works. There are references
in the code to Google Cloud static bucket hosting but almost every hosting
service can handle HTML.

## Development and Editing

### Building

Assuming the dependencies are installed

```sh
git clone git@github.com:frees-au/ce.git && cd ce
composer install

# Build the tailwind/CSS stuff.
composer build-frontend
```

Next step will install Drupal, and then import all of the configuration
and content. It does this with a Drupal [site recipe](https://www.drupal.org/docs/extending-drupal/drupal-recipes)
which lives in /recipes.

```sh
composer build-drupal
```

### Editing

If you are only editing the content, then you can run the Drupal website
using php's built-in server. And then visit https://127.0.0.1:8888. 

```sh
composer editing-drupal
# By running this you acknowledge you are running this on your own secure PC.
./vendor/bin/drush en devel
```

When you [visit the site](https://127.0.0.1:8888) it will log you automatically
as the superuser user/1.

### Designing

If you want to design the site by editing the theme, or if you use using an LLM
to develop the site, you should be "watching", ie generating, the CSS. The theme
uses Tailwind which needs to be compiled, so this command keeps compiling on the
fly.

```sh
composer editing-theme
```

### Saving progress

As you edit the content and configuration of the website (so anytime you save 
something in Drupal), you should "export" the recipe. This puts it all into
the code so you can push to Git (or just make a backup).

```sh
composer export-drupal
git add . && git commit # etc
```

## Topics (wip)

### Theme

This is an intentionally simple Tailwind theme with limited dependencies. The
theme uses [pnpm](https://pnpm.io/) for frontend dependencies.

### Testing

@todo - cypress.

```sh
composer run-script phpcs
composer run-script phpcbf
composer run-script phpstan
```
