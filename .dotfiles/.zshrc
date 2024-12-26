ZSH=/usr/share/oh-my-zsh/

# environment variables
export PATH="$PATH:/home/pyyupsk/.spicetify"
export PATH="$HOME/.local/bin:$PATH"

# fzf
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

# Load additional config files
for file in $HOME/.config/zsh/*.zsh; do
  source $file
done
