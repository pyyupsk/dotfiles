# 70-ai.zsh - AI tool env (non-secret) + aliases
# Gateway URL and key live in ~/.zshrc.local (see zsh/.zshrc.local.example).
export ENABLE_TOOL_SEARCH="true"

alias oc='opencode'

# oc-update-whitelist: test all models and update whitelist with free ones
alias oc-update-whitelist='python3 ~/.local/bin/oc-update-whitelist'
