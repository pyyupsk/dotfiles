# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Entry point - sources all zsh modules in order (see ~/.zshrc.d/).
for module in ~/.zshrc.d/*.zsh; do
  source "$module"
done

# Local secrets - ~/.zshrc.local holds machine-private exports (headroom API
# headers, tokens). Never commit; see zsh/.zshrc.local.example for template.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
