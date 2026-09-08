# 70-headroom.zsh - custom tool aliases
# oc: launch opencode wrapped with headroom proxy on port 65535
alias oc='headroom wrap opencode --port 65535'

# oc-update-whitelist: test all models and update whitelist with free ones
alias oc-update-whitelist='python3 ~/.local/bin/oc-update-whitelist'
