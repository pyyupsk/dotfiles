#!/bin/bash

# Ensure the script is run with root privileges
[ "$(id -u)" -eq 0 ] || { echo "Run as root or with sudo"; exit 1; }

# Determine package manager
for cmd in paru yay pacman; do
    if command -v $cmd &> /dev/null; then
        PACKAGE_MANAGER="$cmd"
        break
    fi
done

[ -n "$PACKAGE_MANAGER" ] || { echo "No supported package manager found"; exit 1; }

# Update and install system packages
sudo "$PACKAGE_MANAGER" -Syu --noconfirm && sudo "$PACKAGE_MANAGER" -S --noconfirm \
    git base-devel \  # base packages
    zsh curl wget aria2 fzf eza bat zoxide # zsh required

# Install Oh My Zsh
aria2c -x 16 -s 16 https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh && \
sh install.sh && rm install.sh

# Define ZSH_CUSTOM if not already set
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Function to clone or update git repositories
clone_or_update() {
    local repo_url=$1
    local target_dir=$2
    if [ -d "$target_dir" ]; then
        echo "Updating $target_dir..."
        git -C "$target_dir" pull
    else
        echo "Cloning $target_dir..."
        git clone "$repo_url" "$target_dir"
    fi
}

# Install ZSH plugins
clone_or_update https://github.com/chrissicool/zsh-256color.git "$ZSH_CUSTOM/plugins/zsh-256color"
clone_or_update https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# Install Pokemon Color Scripts
clone_or_update https://gitlab.com/phoneybadger/pokemon-colorscripts.git "pokemon-colorscripts" && \
sh pokemon-colorscripts/install.sh

echo "System packages installation completed!"

