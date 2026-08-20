# 70-headroom.zsh - custom tool aliases
# oc: launch opencode wrapped with headroom proxy on port 65535
alias oc='export PATH="$HOME/.local/share/mise/installs/python/3.13.15/bin:$PATH" && headroom wrap opencode --port 65535'