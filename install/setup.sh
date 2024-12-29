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
    # Zsh
    ["$DOTFILES_DIR/.dotfiles/.zshrc"]="$HOME/.zshrc"
    ["$DOTFILES_DIR/.dotfiles/.p10k.zsh"]="$HOME/.p10k.zsh"
    ["$DOTFILES_DIR/.dotfiles/.config/zsh/aliases.zsh"]="$HOME/.config/zsh/aliases.zsh"
    ["$DOTFILES_DIR/.dotfiles/.config/zsh/functions.zsh"]="$HOME/.config/zsh/functions.zsh"
    ["$DOTFILES_DIR/.dotfiles/.config/zsh/misc.zsh"]="$HOME/.config/zsh/misc.zsh"
    ["$DOTFILES_DIR/.dotfiles/.config/zsh/plugins.zsh"]="$HOME/.config/zsh/plugins.zsh"
    ["$DOTFILES_DIR/.dotfiles/.config/zsh/theme.zsh"]="$HOME/.config/zsh/theme.zsh"

    # Ghostty
    ["$DOTFILES_DIR/.dotfiles/.config/ghostty/config"]="$HOME/.config/ghostty/config"

    # Binaries
    ["$DOTFILES_DIR/.dotfiles/.local/share/bin/healthcheck.sh"]="$HOME/.local/share/bin/healthcheck.sh"
    ["$DOTFILES_DIR/.dotfiles/.local/share/bin/screenrecord.sh"]="$HOME/.local/share/bin/screenrecord.sh"
)

# Create necessary directories and symlinks
mkdir -p "$HOME/.config/zsh" "$HOME/.local/share/bin"
for src in "${!SYMLINKS[@]}"; do
    create_symlink "$src" "${SYMLINKS[$src]}"
done

# Make zsh the default shell
chsh -s /bin/zsh

# Final message
echo "Dotfiles setup is complete, please log out and log back in for the changes to take effect."