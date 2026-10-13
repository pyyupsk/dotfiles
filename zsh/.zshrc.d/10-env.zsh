# 10-env.zsh - PATH and environment setup
export PATH="$HOME/.local/bin:$PATH"

# Locale - silences perl/stow warnings about missing locale vars
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# WSL2 mirrored networking: Windows reaches 127.0.0.1 but not [::1], so Node must bind IPv4 first
export NODE_OPTIONS=--dns-result-order=ipv4first

# WSL2: npm/bun need BROWSER to open Windows browser (xdg-open via WSLg)
export BROWSER="xdg-open"
