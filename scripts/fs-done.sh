#!/usr/bin/env bash
#
# fs-done — finalise a Free Sauce / frees.au build.
#
# Runs the standard "definition of done" pipeline:
#   1. drush config:export
#   2. commit + push to the hermes branch
#   3. snapshot the live SQLite DB and sites/default/files into
#      ~/backups/frees-au-ce/YYYY-MM-DD--HH-MM/
#
# Idempotent on the backup step — if the destination exists it refuses to
# clobber it (pass --force to overwrite).
#
# Usage:
#   ./scripts/fs-done                  # commit message from $1, default prefix
#   ./scripts/fs-done "Adjust sidebar" # custom message
#   ./scripts/fs-done --force "..."    # overwrite the backup directory

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

force=0
if [ "${1:-}" = "--force" ]; then
  force=1
  shift
fi

msg="${1:-Site update.}"

stamp="$(date +%Y-%m-%d--%H-%M)"
backup_root="${HOME}/backups/frees-au-ce"
backup_dir="${backup_root}/${stamp}"

echo "==> Exporting config"
./vendor/bin/drush config:export -y

echo "==> Staging changes"
git add -A

if git diff --cached --quiet; then
  echo "No config changes to commit."
else
  git commit -m "$msg"
  git push origin hermes
fi

if [ -e "$backup_dir" ] && [ "$force" -ne 1 ]; then
  echo "Backup directory already exists: $backup_dir"
  echo "Pass --force to overwrite."
  exit 1
fi

mkdir -p "$backup_dir"

echo "==> Backing up database to $backup_dir/live.sqlite"
cp -f database/live.sqlite "$backup_dir/live.sqlite"

echo "==> Backing up sites/default/files to $backup_dir/files"
mkdir -p "$backup_dir/files"
rsync -a --delete web/sites/default/files/ "$backup_dir/files/"

echo "==> Done. Backup at: $backup_dir"