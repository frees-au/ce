#!/usr/bin/env bash
# Build the Tome static export into _static-build/ at the repo root.
#
# Must be run from the repo root. Reads site config from web/sites/default/
# including tome.settings.php (which sets $settings['tome_static_directory']).
#
# Usage:
#   ./scripts/build-static.sh
#
# Env overrides (used by .forgejo/workflows/build-static.yml):
#   OUTPUT_DIR   where Tome writes output  (default: _static-build)
#   TOME_URI     base URL Tome uses for absolute links  (default: https://www.frees.au)
#   TOME_KEEP    if non-empty, skip the `rm -Rf` cleanup step (useful for
#                inspecting the previous build). Default: empty (= wipe).
#   CI_BUILD     if non-empty, skip the live-DB guard below. Set this in the
#                Forgejo workflow (which provides its own DB_PATH). Do NOT
#                leave it unset on the dev host — see live-DB guard.
#
# The output directory is gitignored (see .gitignore → /_static-build).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

OUTPUT_DIR="${OUTPUT_DIR:-$REPO_ROOT/_static-build}"
URI="${TOME_URI:-https://www.frees.au}"

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
echo "  (gitignored — see .gitignore)"
