#!/usr/bin/env bash
# Compare the working database with its version in HEAD. Only /tmp copies change.
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

for command in git sqlite3 php sort diff; do
  command -v "$command" >/dev/null || {
    printf 'Required command not found: %s\n' "$command" >&2
    exit 2
  }
done

[[ -f database/live.sqlite ]] || {
  printf 'Database not found: %s/database/live.sqlite\n' "$repo_root" >&2
  exit 2
}

# Remove old copies (including SQLite sidecars) before creating fresh snapshots.
rm -f /tmp/new.sqlite /tmp/new.sqlite-wal /tmp/new.sqlite-shm /tmp/new.sqlite-journal \
  /tmp/exsting.sqlite /tmp/exsting.sqlite-wal /tmp/exsting.sqlite-shm /tmp/exsting.sqlite-journal
# SQLite backup includes committed data still held in the live WAL, if present.
sqlite3 -readonly database/live.sqlite ".backup '/tmp/new.sqlite'"
git show HEAD:database/live.sqlite > /tmp/exsting.sqlite

for name in exsting new; do
  # Drupal's schema uses this collation; load the same comparator for VACUUM.
  php -r '
    require "vendor/autoload.php";
    $db = new PDO("sqlite:" . $argv[1]);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $db->sqliteCreateCollation("NOCASE_UTF8", [Drupal\Component\Utility\Unicode::class, "strcasecmp"]);
    $db->exec("VACUUM");
  ' "/tmp/$name.sqlite"
  # Line sorting makes comparison independent of table and row storage order.
  # These ordered SQL files are comparison artifacts, not restore scripts.
  sqlite3 "/tmp/$name.sqlite" .dump | LC_ALL=C sort > "/tmp/$name.sql"
done

# Standard diff exit codes: 0 = identical, 1 = differences, 2 = error.
diff -u /tmp/exsting.sql /tmp/new.sql
