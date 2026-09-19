# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Entry point - sources all zsh modules in order.
for module in ~/.zshrc.d/*.zsh; do
  source "$module"
done

# bun completions
[ -s "/home/pyyupsk/.bun/_bun" ] && source "/home/pyyupsk/.bun/_bun"
export PATH="/home/pyyupsk/.bun/bin:$PATH"

# WSL2 mirrored networking: Windows reaches 127.0.0.1 but not [::1], so Node must bind IPv4 first
export NODE_OPTIONS=--dns-result-order=ipv4first

# >>> headroom persistent env >>>
export HEADROOM_PORT="18787"
export HEADROOM_HOST="127.0.0.1"
export HEADROOM_MODE="token"
export HEADROOM_BACKEND="anthropic"
export HEADROOM_TELEMETRY="off"
export ANTHROPIC_BASE_URL="http://127.0.0.1:18787"
export ENABLE_TOOL_SEARCH="true"
# <<< headroom persistent env <<<

# Local secrets - ~/.zshrc.local holds machine-private exports (headroom API
# headers, tokens). Never commit; see zsh/.zshrc.local.example for template.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
