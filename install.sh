#!/usr/bin/env bash
# dotfiles install script - creates symlinks for each config.
set -euo pipefail

DOTFILES="$HOME/dotfiles"

link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "SKIP  $dest (real file exists - move or remove it first)"
    return
  fi
  rm -f "$dest"
  ln -s "$src" "$dest"
  echo "LINK  $dest -> $src"
}

# zsh
link "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
mkdir -p "$HOME/.zshrc.d"
for f in "$DOTFILES"/zsh/modules/*.zsh; do
  ln -sf "$f" "$HOME/.zshrc.d/$(basename "$f")"
done
echo "LINK  ~/.zshrc.d -> zsh/modules/*.zsh"

# git
link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

# mise
link "$DOTFILES/mise/config.toml" "$HOME/.config/mise/config.toml"

# opencode
link "$DOTFILES/opencode/tui.json" "$HOME/.config/opencode/tui.json"

# ssh
link "$DOTFILES/ssh/config" "$HOME/.ssh/config"

echo "Done. Reload your shell: exec zsh"