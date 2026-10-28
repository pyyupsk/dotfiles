fpath+=/usr/share/zsh/site-functions
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
command -v fzf >/dev/null && eval "$(fzf --zsh)"
