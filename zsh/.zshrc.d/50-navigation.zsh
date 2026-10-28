if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi
alias ..='cd ..'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ~='cd ~'
alias back='cd -'
