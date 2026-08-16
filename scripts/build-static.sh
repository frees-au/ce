#!/usr/bin/env bash
# Build the Tome static export.
#
# Must be run from the repo root. Reads site config from web/sites/default/
# including tome.settings.php (which sets $settings['tome_static_directory']).
#
# Usage:
#   ./scripts/build-static.sh [DOMAIN] [OUTPUT_DIR]
#
# Positional args:
#   DOMAIN       bare host Tome uses as the base URL for absolute links.
#                The script builds the URI as `https://$DOMAIN` — pass the
#                host only (e.g. `frees.au`). To use a different scheme or
#                full URL, set TOME_URI in the env instead.
#                Default: frees.au
#   OUTPUT_DIR   where Tome writes output. Accepts absolute or relative paths;
#                relative paths resolve against the repo root. Default:
#                `$REPO_ROOT/_static-build`.
#
# Env overrides (used by .forgejo/workflows/build-static.yml):
#   TOME_URI     full base URL Tome uses for absolute links. Wins over DOMAIN
#                if set — useful when you need a scheme other than https://
#                (e.g. local dev against http://localhost).
#   OUTPUT_DIR   where Tome writes output  (default: $REPO_ROOT/_static-build).
#                Positional arg wins over env if both are set.
#   TOME_KEEP    if non-empty, skip the `rm -Rf` cleanup step (useful for
#                inspecting the previous build). Default: empty (= wipe).
#   CI_BUILD     retained for compatibility with workflow definitions that
#                still set it. The script no longer guards against the live
#                DB — invocation is the caller's responsibility (and AGENTS.md
#                hard rule #1: there's no working webserver, so don't render
#                against the dev DB unless you really mean to).
#
# The output directory is gitignored (see .gitignore → /_static-build).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# --- args / defaults -----------------------------------------------------
# DOMAIN is the first positional arg; bare host. We build `https://$DOMAIN`
# unless TOME_URI is explicitly set in the env (allows http:// for local dev).
DOMAIN="${1:-frees.au}"
URI="${TOME_URI:-https://$DOMAIN}"

# OUTPUT_DIR is the second positional arg; absolute or relative (resolved
# against the repo root). Env OUTPUT_DIR is honored when no positional arg
# is passed — keeps the example-full-build-static.yml workflow compatible.
if [ "${2+x}" = x ]; then
  OUTPUT_DIR="$2"
elif [ -n "${OUTPUT_DIR:-}" ]; then
  : # keep env value
else
  OUTPUT_DIR="$REPO_ROOT/_static-build"
fi
# Resolve relative paths against the repo root so a downstream `cd` can't
# surprise us, and so the artifact ends up where callers expect.
case "$OUTPUT_DIR" in
  /*) ;;
  *)  OUTPUT_DIR="$REPO_ROOT/$OUTPUT_DIR" ;;
esac

# Sanity: drush must be present and the site must bootstrap.
if ! command -v vendor/bin/drush >/dev/null 2>&1; then
  echo "::error::vendor/bin/drush not found at $REPO_ROOT — did composer install run?" >&2
  exit 1
fi

# Wipe the previous build so stale paths don't linger (opt out via TOME_KEEP).
if [ -z "${TOME_KEEP:-}" ]; then
  rm -Rf "$OUTPUT_DIR"
fi
mkdir -p "$OUTPUT_DIR"

# Tome ignores $settings['tome_static_directory'] when we hand the path on the
# CLI, so the env override always wins.
GENERATE_STATIC_SITE=1 \
  vendor/bin/drush tome:static -vv --uri="$URI" --output-dir="$OUTPUT_DIR"

echo
echo "✓ Static export written to $OUTPUT_DIR"
echo "  URI: $URI"
echo "  (gitignored — see .gitignore)"