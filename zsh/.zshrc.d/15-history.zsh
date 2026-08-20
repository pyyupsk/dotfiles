# 15-history.zsh - command history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

# History options
setopt HIST_IGNORE_DUPS        # don't record duplicate entries
setopt HIST_IGNORE_ALL_DUPS    # delete older duplicates
setopt HIST_FIND_NO_DUPS       # don't show duplicates when searching
setopt HIST_IGNORE_SPACE       # don't record commands starting with space
setopt HIST_REDUCE_BLANKS      # trim excess whitespace
setopt HIST_VERIFY             # confirm before executing expanded history
setopt SHARE_HISTORY           # share history between sessions
setopt EXTENDED_HISTORY        # record timestamp in history