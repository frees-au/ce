---
name: publish-video
description: Add a YouTube video as a frees.au Drupal article in this repository, including source metadata, linked media, thumbnail, and local verification.
---

# Publish a video article

Work from the repository root and follow `AGENTS.md`. Use this checkout's
installed schema and settings; older external guides describe a different host.
Adding content locally does not deploy the public static site.

## Inspect and retrieve

1. Check Git status, current branch, and `./vendor/bin/drush status`. Preserve
   existing edits; do not switch branches or start a server to add content.
2. Inspect recent articles and live field definitions for `node:article` and
   `media:stream`. Search existing media URLs for the video ID (short and watch
   URLs), then check referencing articles. Reuse existing media and avoid
   duplicate articles.
3. Fetch the watch page with a browser user agent. Decode the JSON value after
   `ytInitialPlayerResponse =` using a JSON decoder or balanced-brace scan.
   Read `videoDetails.title`, `shortDescription`, `lengthSeconds`, `videoId`,
   and `microformat.playerMicroformatRenderer.publishDate`.
   oEmbed provides title and thumbnail, but no publication date. Report missing
   metadata rather than inventing it.
4. Write a concise lead and optional supporting paragraphs from the description,
   preserving useful source links. Do not invent a transcript, conclusions,
   tags, or playlist membership, or imply the video was watched.

## Create

Use a PHP script with `./vendor/bin/drush php:script <file>` to avoid shell
quoting issues with HTML. Retained procedural scripts belong in `drush/agent/`.
Drush changes PHP's working directory during bootstrap: locate repo files using
`dirname(DRUPAL_ROOT)`, not `getcwd()`.

Explicitly require `scripts/includes/ContentHelpers.php` and use
`FreeSauce\Ce\Scripts\ContentHelpers`.

Current field shapes (verify before writing):

| Entity or field | Value |
| --- | --- |
| `media:stream.media_oembed_video` | Canonical `https://www.youtube.com/watch?v=<id>` |
| Media `name` | Source title |
| Article `title` | Source title |
| Article `lead` (required) | Text with format `basic` |
| Article `markup` (optional) | Supporting HTML with format `safe_html` |
| Article `youtube` | Reference to the stream media ID |
| Article `duration` | Whole minutes: `21 mins` or `1 hour 21 mins` |
| Article and media `created`, `changed` | Publication timestamp parsed with its source timezone offset |

Publish both entities. There is **no article `body` field**. Assign `playlist`
(a term reference) only when source context or the user establishes membership.
Let existing Pathauto configuration generate the article alias.

Create unsaved entities (`$save = FALSE`) and validate before saving. Text-format
validation depends on account permissions: use `account_switcher` with an
authorized editor account and restore it in `finally`. Do not disable validation
or change permissions. Save media first, attach it to the article, then validate
and save the article. On failure, clean up only entities newly created by this
attempt; never delete reused media. oEmbed fetches the thumbnail on save and
needs network access. Check that the thumbnail file exists.

## Verify and deliver

- Reload the article and media; check publication status, title, dates, duration,
  text formats, media reference, source URL, generated alias, and thumbnail file.
- When a server is available, check the article and listing for the embed,
  thumbnail, text, and newest-first order. State when only entity checks passed.
- The usual local address is `http://127.0.0.1:8888`. If unavailable, check the
  listener; do not claim a server was started. When asked to start one, run
  `./vendor/bin/drush serve 127.0.0.1:8888 --no-browser` from repo root and report
  the actual listening address. Leave startup to the user when requested.
- Active config is YAML-backed in `config/active`; sync uses the same directory.
  Content-only additions require no config export/import. Content is in tracked
  `database/live.sqlite`; uploaded thumbnails are in ignored
  `web/sites/default/files`. A Git commit alone does not transfer uploaded files
  or deploy the website.
- Return the local article link and verification results. Obtain the user's
  visual confirmation before committing under the project's review workflow.
  Follow current branch instructions; flag a mismatch rather than switching or
  creating branches. Push or deploy only within the user's authorized scope.
