#!/usr/bin/env bash
# Copy kde/home back into $HOME. Plasma must not be running: it writes its
# own settings on logout and would overwrite these files.
set -euo pipefail
cd "$(dirname "$0")"

if pgrep -x plasmashell >/dev/null && [[ "${1:-}" != "--force" ]]; then
  echo "Plasma is running. Log out, open a TTY (Ctrl+Alt+F3), then run this again." >&2
  echo "Use --force to copy anyway." >&2
  exit 1
fi

cp -a home/. "$HOME/"
echo "KDE settings applied. Log in to see them."
