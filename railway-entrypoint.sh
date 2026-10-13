#!/bin/sh
# Fix Railway volume ownership, then run OmniRoute as the unprivileged node user.
set -e
DATA_PATH="${DATA_DIR:-/app/data}"
APP_UID=1000
APP_GID=1000

if [ "$(id -u)" = "0" ]; then
  mkdir -p "$DATA_PATH"
  # Only touch entries not already owned by node (cheap on every boot).
  find "$DATA_PATH" \( ! -user "$APP_UID" -o ! -group "$APP_GID" \) -exec chown "$APP_UID:$APP_GID" {} + 2>/dev/null || true
  chmod u+rwX "$DATA_PATH" 2>/dev/null || true
  export HOME=/home/node USER=node
  if command -v setpriv >/dev/null 2>&1; then
    exec setpriv --reuid="$APP_UID" --regid="$APP_GID" --init-groups /app/check-permissions.sh "$@"
  elif command -v runuser >/dev/null 2>&1; then
    exec runuser -u node -- /app/check-permissions.sh "$@"
  fi
  echo "WARNING: no setpriv/runuser found; running OmniRoute as root" >&2
fi
exec /app/check-permissions.sh "$@"
