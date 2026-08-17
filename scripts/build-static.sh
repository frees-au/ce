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
#

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# --- args / defaults -----------------------------------------------------
# DOMAIN is the first positional arg; bare host. We build `https://$DOMAIN`
# unless TOME_URI is explicitly set in the env (allows http:// for local dev).
DOMAIN="${1:-www.frees.au}"
URI="${TOME_URI:-https://$DOMAIN}"

# Sanity: drush must be present and the site must bootstrap.
if ! command -v vendor/bin/drush >/dev/null 2>&1; then
  echo "::error::vendor/bin/drush not found at $REPO_ROOT" >&2
  exit 1
fi

rm -Rf /home/runner/artifacts/frees-au-ce/prod/*
rm -Rf /home/runner/artifacts/frees-au-ce/local/*

GENERATE_STATIC_SITE=1 vendor/bin/drush tome:static -vv --uri="$URI"

echo
echo "✓ Static export written"
echo "  URI: $URI"
