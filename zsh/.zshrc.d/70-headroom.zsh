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
export OPENAI_BASE_URL="http://127.0.0.1:18787/v1"
export HEADROOM_PROXY_URL="http://127.0.0.1:18787"
export ENABLE_TOOL_SEARCH="true"

# oc: plain opencode. `headroom wrap opencode` is inert on opencode 2.x (v1-style
# config + file-path plugin rejected) and its gateway upstream is down, so wrapping
# only injected a dead port (65535). Revisit `headroom wrap opencode --port 18787`
# once headroom ships a 2.x transport plugin AND the gateway serves a model again.
alias oc='opencode'

# oc-update-whitelist: test all models and update whitelist with free ones
alias oc-update-whitelist='python3 ~/.local/bin/oc-update-whitelist'
