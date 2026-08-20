# 50-navigation.zsh - cd aliases and zoxide
# zoxide (smarter cd)
eval "$(zoxide init zsh)"
alias cd='z'

# cd navigation
alias ..='cd ..'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ~='cd ~'
alias back='cd -'