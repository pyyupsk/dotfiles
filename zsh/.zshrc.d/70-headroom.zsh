# 70-headroom.zsh - headroom proxy env (non-secret) + aliases
# Canonical home for headroom exports. Secrets (TARGET_API_*) live in
# ~/.zshrc.local; headroom-ensure-local strips any hook-injected markers
# block from the stowed .zshrc so this file stays source of truth.
export HEADROOM_PORT="18787"
export HEADROOM_HOST="127.0.0.1"
export HEADROOM_MODE="token"
export HEADROOM_BACKEND="anthropic"
export HEADROOM_TELEMETRY="off"
export ANTHROPIC_BASE_URL="http://127.0.0.1:18787"
export ENABLE_TOOL_SEARCH="true"

# oc: launch opencode wrapped with headroom proxy on port 65535
alias oc='headroom wrap opencode --port 65535'

# oc-update-whitelist: test all models and update whitelist with free ones
alias oc-update-whitelist='python3 ~/.local/bin/oc-update-whitelist'
