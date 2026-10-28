#!/usr/bin/env bash
# Set up a fresh Arch install to match this desktop. Read docs/install.md first.
# Usage: ./install.sh <step>...   run these steps in the order given
# Every step is safe to run again. The steps run in three phases, because the
# theme installer needs a running Plasma session and kde needs Plasma stopped.
set -euo pipefail

DOT="$(cd "$(dirname "$0")" && pwd)"
STEPS=(check packages stow system fonts wallpaper theme plasma kde apps)

THEME_REPO=https://github.com/lestercorderomurillo/macos-tahoe-liquid-kde
THEME_TAG=v0.61.8
PCC_REPO=https://github.com/cesarconte/plasma-control-center
PCC_COMMIT=3f48fc3  # the upstream commit this setup was built and tested on
WALLPAPER_URL=https://media.512pixels.net/downloads/macos-wallpapers-6k/27-Golden-Gate-Dark.png
SF_PRO_URL=https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg
VSCODE_EXTENSIONS=(subframe7536.custom-ui-style miguelsolorio.symbols beardedbear.beardedtheme
  editorconfig.editorconfig codezombiech.gitignore yzhang.markdown-all-in-one)

say() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
pause() { read -rp "    $* Press Enter when done. "; }

step_packages() {
  say "Packages from the Arch repos"
  sudo pacman -Syu --needed - < "$DOT/packages/pacman.txt"

  if ! command -v paru >/dev/null; then
    say "Build paru (AUR helper)"
    local tmp; tmp=$(mktemp -d)
    git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
    (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
  fi

  say "Packages from the AUR"
  paru -S --needed - < "$DOT/packages/aur.txt"
}

step_stow() {
  say "Link dotfiles into \$HOME"
  mkdir -p ~/.claude ~/.config/opencode ~/.local/share/applications ~/.local/share/icons
  (cd "$DOT" && stow --no-folding zsh git mise opencode ssh claude alacritty \
    applications icons fontconfig vscode)
  [[ -f ~/.zshrc.local ]] || install -m 600 "$DOT/zsh/.zshrc.local.example" ~/.zshrc.local
  [[ "$(getent passwd "$USER" | cut -d: -f7)" == /usr/bin/zsh ]] || chsh -s /usr/bin/zsh
}

step_system() {
  say "System files: Plymouth, SDDM login screen, boot options, services"
  sudo cp -r "$DOT/system/etc/." /etc/
  sudo cp -r "$DOT/system/usr/." /usr/
  sudo mkinitcpio -P

  local opts="quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0"
  sudo sh -c "for f in /boot/loader/entries/*.conf; do
    grep -q ' splash' \"\$f\" || sed -i 's/^options .*/& $opts/' \"\$f\"
  done"

  sudo systemctl enable sddm NetworkManager tailscaled fstrim.timer paccache.timer \
    nvidia-suspend nvidia-resume nvidia-hibernate
}

step_fonts() {
  say "SF Pro fonts from Apple (not stored in git: Apple license)"
  local dir=/usr/local/share/fonts/apple
  if compgen -G "$dir/SF-Pro-Text-*.otf" >/dev/null; then echo "    already installed"; return; fi
  local tmp; tmp=$(mktemp -d)
  curl -fL -o "$tmp/SF-Pro.dmg" "$SF_PRO_URL"
  7z x -y -o"$tmp/dmg" "$tmp/SF-Pro.dmg" >/dev/null
  7z x -y -o"$tmp/pkg" "$(find "$tmp/dmg" -maxdepth 2 -name '*.pkg' | head -1)" >/dev/null
  mkdir -p "$tmp/out"
  (cd "$tmp/out" && 7z x -so "$(find "$tmp/pkg" -name Payload | head -1)" | cpio -id --quiet)
  sudo mkdir -p "$dir"
  find "$tmp/out" \( -name 'SF-Pro-Text-*.otf' -o -name 'SF-Pro-Display-*.otf' -o -name 'SF-Pro-Rounded-*.otf' \) \
    -exec sudo cp {} "$dir/" \;
  rm -rf "$tmp"
  sudo fc-cache -f "$dir"
}

step_wallpaper() {
  say "Golden Gate wallpaper for the lock screen and login screen"
  mkdir -p ~/Pictures/Wallpapers
  local file=~/Pictures/Wallpapers/27-Golden-Gate-Dark.png
  [[ -f $file ]] || curl -fL -o "$file" "$WALLPAPER_URL"
  sudo install -Dm644 "$file" /usr/local/share/backgrounds/27-Golden-Gate-Dark.png
}

step_theme() {
  say "macOS Tahoe Liquid KDE theme ($THEME_TAG)"
  local src=~/.local/src/macos-tahoe-liquid-kde
  [[ -d $src ]] || git clone --branch "$THEME_TAG" "$THEME_REPO" "$src"
  echo "    The installer opens a window. Pick the choices listed in docs/install.md."
  (cd "$src" && ./install)
  systemctl --user disable --now mac-tahoe-liquid-kde-theme.timer 2>/dev/null || true
}

step_plasma() {
  say "KWin scripts, splash and widgets"
  local pp="$DOT/plasma-packages"
  mkdir -p ~/.local/share/kwin ~/.local/share/plasma
  cp -r "$pp/kwin/scripts" "$pp/kwin/effects" ~/.local/share/kwin/
  cp -r "$pp/plasma/look-and-feel" "$pp/plasmoids" ~/.local/share/plasma/

  if ! pacman -Q plasma-control-center-git >/dev/null 2>&1; then
    say "Build Control Center"
    local src=~/.local/src/plasma-control-center
    if [[ ! -d $src ]]; then
      git clone "$PCC_REPO" "$src"
      git -C "$src" reset -q --hard "$PCC_COMMIT"
      sed -i 's/"menu_new-symbolic"/"control-center-symbolic"/' "$src/src/qml/ExpanderArrow.qml"
      git -C "$src" commit -qam "use control-center-symbolic panel icon"
    fi
    local tmp; tmp=$(mktemp -d)
    cp "$pp/plasma-control-center/PKGBUILD" "$tmp/"
    (cd "$tmp" && makepkg -si --noconfirm)
    rm -rf "$tmp"
  fi
}

step_kde() {
  say "KDE settings (panels, shortcuts, window rules, Dolphin, splash)"
  "$DOT/kde/apply.sh"
}

step_apps() {
  say "Developer tools"
  mise install
  mise exec -- uv tool install -p 3.13 serena-agent 2>/dev/null || true
  command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash
  ~/.local/bin/claude mcp get serena >/dev/null 2>&1 ||
    ~/.local/bin/claude mcp add -s user serena -- serena start-mcp-server --context claude-code --project-from-cwd
  [[ -x ~/.opencode/bin/opencode ]] || curl -fsSL https://opencode.ai/v2/install | bash

  say "VS Code extensions (Custom UI Style must write to /usr/share/code)"
  sudo chown -R "$USER" /usr/share/code
  for ext in "${VSCODE_EXTENSIONS[@]}"; do code --install-extension "$ext" --force >/dev/null; done

  say "T3 Code"
  mkdir -p ~/Applications
  if [[ ! -f ~/Applications/T3-Code.AppImage ]]; then
    local url
    url=$(curl -fsSL https://api.github.com/repos/pingdotgg/t3code/releases/latest |
      python3 -c 'import json,sys; print(next(a["browser_download_url"] for a in json.load(sys.stdin)["assets"] if a["name"].endswith("x86_64.AppImage")))')
    curl -fL -o ~/Applications/T3-Code.AppImage "$url"
    chmod +x ~/Applications/T3-Code.AppImage
  fi

  say "Spicetify (Spotify must have been opened and logged in once)"
  pause "Open Spotify, log in, then close it."
  sudo chmod a+wr /opt/spotify /opt/spotify/Apps -R
  spicetify backup apply || spicetify restore backup apply
  curl -fsSL https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh | sh
}

# True when every file under $1 exists in $2 with the same content.
same_tree() {
  local f
  while IFS= read -r -d '' f; do cmp -s "$1/$f" "$2/$f" || return 1; done \
    < <(cd "$1" && find . -type f -print0)
}

# Read-only: report what each step would still change. Needs no sudo.
step_check() {
  mark() {
    if "${@:2}" >/dev/null 2>&1; then printf '  \033[32mok\033[0m    %s\n' "$1"
    else printf '  \033[33mtodo\033[0m  %s\n' "$1"; fi
  }
  no_missing_packages() { ! pacman -T $(cat "$DOT"/packages/*.txt) | grep -q .; }
  stow_clean() {
    (cd "$DOT" && stow -n -v --no-folding zsh git mise opencode ssh claude alacritty \
      applications icons fontconfig vscode 2>&1) | grep -qv -e '^WARNING' -e '^$' && return 1 || return 0
  }
  has_apps() {
    command -v claude && command -v serena && command -v spicetify &&
      [[ -x ~/.opencode/bin/opencode && -x ~/Applications/T3-Code.AppImage ]]
  }

  say "check (nothing is changed)"
  mark "packages"                no_missing_packages
  mark "stow links"              stow_clean
  mark "system files in /etc"    same_tree "$DOT/system/etc" /etc
  mark "system files in /usr"    same_tree "$DOT/system/usr" /usr
  mark "boot splash"             grep -q splash /proc/cmdline
  mark "fonts"                   compgen -G "/usr/local/share/fonts/apple/SF-Pro-Text-*.otf"
  mark "wallpaper"               test -f /usr/local/share/backgrounds/27-Golden-Gate-Dark.png
  mark "theme"                   test -d ~/.local/share/plasma/look-and-feel/org.kde.mac-tahoe-liquid-kde.dark
  mark "KWin scripts and effect" same_tree "$DOT/plasma-packages/kwin" ~/.local/share/kwin
  mark "splash and widgets"      same_tree "$DOT/plasma-packages/plasma" ~/.local/share/plasma
  mark "notification clock"      same_tree "$DOT/plasma-packages/plasmoids" ~/.local/share/plasma/plasmoids
  mark "Control Center"          pacman -Q plasma-control-center-git
  mark "kde settings"            same_tree "$DOT/kde/home" "$HOME"
  mark "apps"                    has_apps
}

run() {
  local s=$1
  [[ " ${STEPS[*]} " == *" $s "* ]] || { echo "Unknown step: $s (steps: ${STEPS[*]})" >&2; exit 1; }
  "step_$s"
}

if ((! $#)); then
  cat <<USAGE
Usage: ./install.sh <step>...   (steps: ${STEPS[*]})

1. From a TTY, before the first login:  ./install.sh packages stow system fonts wallpaper
   Then reboot and log in to Plasma.
2. In Plasma:                           ./install.sh theme plasma apps
   Then log out and switch to a TTY (Ctrl+Alt+F3).
3. From the TTY:                        ./install.sh kde
   Then log in again.
USAGE
  exit 0
fi
for s in "$@"; do run "$s"; done
