# p10k instant prompt: must stay above anything that prints
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

for module in ~/.zshrc.d/*.zsh; do
  source "$module"
done

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
