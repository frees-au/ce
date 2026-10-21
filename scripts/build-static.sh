#!/usr/bin/env bash
set -euo pipefail

# Build the Tome static export using the first argument as the domain.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

DOMAIN="${1:-www.frees.au}"
URI="${TOME_URI:-https://$DOMAIN}"
ENV=$([[ "$DOMAIN" == "www.frees.au" ]] && echo "www.frees.au" || echo "static-locat-test.frees.au")

vendor/bin/drush theme:dev off -vv --uri="$URI"
vendor/bin/drush cache:rebuild -vv --uri="$URI"
vendor/bin/drush tome:static -vv --uri="$URI"

# Force drupal to generate aggregated css.
# curl -s "https://www-edit.frees.au" > /dev/null

echo
echo "✓ Static export written"
echo "  URI: $URI"
