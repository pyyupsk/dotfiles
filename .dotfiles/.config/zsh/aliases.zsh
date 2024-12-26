# Terminal Operations
alias c='clear'
alias mkdir='mkdir -p'

# File Listing
alias l='eza -lh'
alias ls='eza -1'
alias ll='eza -lha --sort=name --group-directories-first'
alias ld='eza -lhD'
alias lt='eza --tree'

# Package Management
alias pa='$aurhelper -Ss'
alias pl='$aurhelper -Qs'
alias pc='$aurhelper -Sc'
alias po='$aurhelper -Qqd | $aurhelper -Rsu --print -'
alias un='$aurhelper -Rns'
alias up='$aurhelper -Syu'

# Git Operations
alias gi='git init'
alias gb='git branch'
alias gbd='git branch -d'
alias gc='git commit'
alias gca='git commit --amend --no-edit'
alias gcl='git clone'
alias ga='git add'
alias gaa='git add .'
alias gco='git checkout'
alias gdiff='git diff'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias gsvl='git status -v > git-status.log'

# Directory Navigation
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias ..='cd ..'
alias ...='cd ../..'
alias dev='cd ~/Coding'

# Replacement
alias '?'='alias_help'
alias cat='bat'
alias health='sudo ~/.local/share/bin/healthcheck.sh'
alias wget='aria2c -x 16 -s 16'
