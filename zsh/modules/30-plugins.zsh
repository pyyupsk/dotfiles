# 30-plugins.zsh - zsh plugins, completions, fzf
# zsh-completions
fpath+=/usr/share/zsh/site-functions
autoload -Uz compinit
compinit -d ~/.cache/zcompdump

# zsh-autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf
eval "$(fzf --zsh)"