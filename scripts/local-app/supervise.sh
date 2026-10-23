#!/bin/bash
set -u
set -m

repository=$1
port=$2
pid_file=$3
log_file=$4
owner_pid=$5
server_pid=''
watchdog_pid=''
cleaned_up=0

stop_server() {
  if (( cleaned_up )); then
    return
  fi
  cleaned_up=1

  if [[ -n "$watchdog_pid" ]]; then
    kill "$watchdog_pid" 2>/dev/null || true
  fi
  if [[ -n "$server_pid" ]]; then
    kill -TERM -- "-$server_pid" 2>/dev/null || true
    for _ in {1..20}; do
      kill -0 "$server_pid" 2>/dev/null || return
      sleep 0.1
    done
    kill -KILL -- "-$server_pid" 2>/dev/null || true
  fi
}

save_and_stop() {
  trap - EXIT INT TERM HUP
  save_status=0

  printf '\n[%s] Saving site before shutdown.\n' "$(date '+%Y-%m-%d %H:%M:%S')" >>"$log_file"
  if "$repository/scripts/site-save.sh" >>"$log_file" 2>&1; then
    :
  else
    save_status=$?
    printf '[%s] Site save failed; preserving database/live.sqlite.\n' "$(date '+%Y-%m-%d %H:%M:%S')" >>"$log_file"
  fi

  stop_server

  database="$repository/database/live.sqlite"
  if (( save_status == 0 )) && [[ -f "$database" ]]; then
    if php -r '$db = new PDO("sqlite:" . $argv[1]); $db->exec("PRAGMA wal_checkpoint(TRUNCATE)");' "$database" >>"$log_file" 2>&1; then
      timestamp=$(date '+%Y%m%d-%H%M%S')
      backup="$repository/database/app-backup-$timestamp.sqlite"
      if mv "$database" "$backup"; then
        printf '[%s] Database moved to %s.\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$backup" >>"$log_file"
      else
        save_status=$?
      fi
    else
      save_status=$?
      printf '[%s] SQLite checkpoint failed; preserving database/live.sqlite.\n' "$(date '+%Y-%m-%d %H:%M:%S')" >>"$log_file"
    fi
  fi

  exit "$save_status"
}

trap stop_server EXIT
trap save_and_stop INT TERM HUP

if [[ ! -f "$repository/database/live.sqlite" ]]; then
  printf '\n[%s] Loading site before startup.\n' "$(date '+%Y-%m-%d %H:%M:%S')" >>"$log_file"
  if ! "$repository/scripts/site-load.sh" >>"$log_file" 2>&1; then
    printf '[%s] Site load failed; the local server was not started.\n' "$(date '+%Y-%m-%d %H:%M:%S')" >>"$log_file"
    exit 1
  fi
fi

cd "$repository/web" || exit 1
php -S "127.0.0.1:$port" "$repository/vendor/drush/drush/misc/d8-rs-router.php" >>"$log_file" 2>&1 &
server_pid=$!
printf '%s\n' "$server_pid" >"$pid_file"

(
  while kill -0 "$owner_pid" 2>/dev/null; do
    sleep 1
  done
  kill -TERM "$$" 2>/dev/null || true
) &
watchdog_pid=$!

wait "$server_pid"
status=$?
exit "$status"
