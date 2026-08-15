#!/usr/bin/env bash
# Build the Tome static export into _static-build/ at the repo root.
#
# Must be run from the repo root. Reads site config from web/sites/default/
# including tome.settings.php (which sets $settings['tome_static_directory']).
#
# Usage:
#   ./scripts/build-static.sh
#
# The output directory is gitignored (see .gitignore → /_static-build).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

OUTPUT_DIR="_static-build"
URI="${TOME_URI:-https://www.frees.au}"

# Wipe the previous build so stale paths don't linger.
rm -Rf "$OUTPUT_DIR"

# Run the Tome static command. GENERATE_STATIC_SITE switches Drupal into
# fully-static-render mode (no DB writes during the request lifecycle).
# -vv gives verbose output so we can see which routes are exported.
GENERATE_STATIC_SITE=1 \
  vendor/bin/drush tome:static -vv --uri="$URI"

echo
echo "✓ Static export written to $REPO_ROOT/$OUTPUT_DIR"
echo "  (gitignored — see .gitignore)"
