#!/usr/bin/env bash
# Copy the live KDE setup from $HOME into kde/home. Run after changing settings.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf home
grep -v -e '^#' -e '^$' files.txt | while read -r path; do
  if [[ ! -e "$HOME/$path" ]]; then
    echo "skip (missing): $path"
    continue
  fi
  mkdir -p "home/$(dirname "$path")"
  cp -a "$HOME/$path" "home/$path"
done
# Drop recent-file state: it changes all the time and names personal files
grep -rlZ -E '^(LastPlayedFile|lastImageSaveLocation|lastVideoSaveLocation)=' home | xargs -0 -r sed -i -E '/^(LastPlayedFile|lastImageSaveLocation|lastVideoSaveLocation)=/d'
echo "saved to $(pwd)/home"
