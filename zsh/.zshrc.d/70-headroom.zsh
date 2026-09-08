# 70-headroom.zsh - custom tool aliases
export HEADROOM_PORT="18787"
export HEADROOM_HOST="127.0.0.1"
export HEADROOM_MODE="token"
export HEADROOM_BACKEND="anthropic"
export HEADROOM_TELEMETRY="on"
export ANTHROPIC_BASE_URL="http://127.0.0.1:18787"
export ENABLE_TOOL_SEARCH="true"

# oc: launch opencode wrapped with headroom proxy on port 65535
alias oc='headroom wrap opencode --port 65535'

# oc-update-whitelist: test all models and update whitelist with free ones
alias oc-update-whitelist='python3 ~/.local/bin/oc-update-whitelist'
