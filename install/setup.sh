#!/bin/bash

# Set the dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"

# Function to create symlinks
create_symlink() {
    local source=$1
    local target=$2
    if [ -e "$target" ]; then
        echo "$target already exists, skipping symlink creation"
    else
        echo "Creating symlink: $source -> $target"
        ln -s "$source" "$target"
    fi
}

# Ensure the dotfiles directory exists
[ -d "$DOTFILES_DIR" ] || { echo "Dotfiles directory ($DOTFILES_DIR) does not exist. Please check your repository setup."; exit 1; }

# Symlink files/directories
declare -A SYMLINKS=(
    ["$DOTFILES_DIR/.zshrc"]="$HOME/.zshrc"
    ["$DOTFILES_DIR/.config/zsh/aliases.zsh"]="$HOME/.config/zsh/aliases.zsh"
    ["$DOTFILES_DIR/.config/zsh/functions.zsh"]="$HOME/.config/zsh/functions.zsh"
    ["$DOTFILES_DIR/.config/zsh/misc.zsh"]="$HOME/.config/zsh/misc.zsh"
    ["$DOTFILES_DIR/.config/zsh/plugins.zsh"]="$HOME/.config/zsh/plugins.zsh"
    ["$DOTFILES_DIR/.config/zsh/theme.zsh"]="$HOME/.config/zsh/theme.zsh"
    ["$DOTFILES_DIR/.local/share/bin/healthcheck.sh"]="$HOME/.local/share/bin/healthcheck.sh"
)

# Create necessary directories and symlinks
mkdir -p "$HOME/.config/zsh" "$HOME/.local/share/bin"
for src in "${!SYMLINKS[@]}"; do
    create_symlink "$src" "${SYMLINKS[$src]}"
done

# Final message
echo "Dotfiles setup is complete, We'll reload zsh in 3 seconds"

# Display a countdown before reloading zsh
for i in {3..1}; do
    echo "Reloading zsh in $i..."
    sleep 1
done
exec zsh

