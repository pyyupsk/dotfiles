# Dotfiles

Personal configuration, organized by tool. Managed with plain symlinks - no
external tools required (no stow/chezmoi).

## Layout

```
dotfiles/
├── README.md          this file
├── install.sh         creates all symlinks
├── zsh/
│   ├── .zshrc         entry point: sources every module in ~/.zshrc.d
│   └── modules/       one file per concern, numbered for load order
├── git/
│   └── .gitconfig     git identity, signing, aliases
├── mise/
│   └── config.toml    global tool versions (node, python, rust)
├── opencode/
│   └── tui.json       opencode theme
└── ssh/
    └── config         ssh host shortcuts
```

## zsh modules

| File | Purpose |
|------|---------|
| `10-env.zsh`      | PATH / environment variables |
| `20-mise.zsh`     | mise version manager integration |
| `30-plugins.zsh`  | completions, autosuggestions, fzf |
| `40-aliases.zsh`  | ls/cat/clear replacements (eza, bat) |
| `50-navigation.zsh` | cd aliases + zoxide |
| `60-git.zsh`      | git command aliases |
| `70-headroom.zsh` | tool-specific aliases (oc) |
| `90-syntax.zsh`   | syntax highlighting (must load last) |

## Install

```sh
./install.sh
```

This symlinks each config into its home location. To remove, delete the
symlinks (originals stay safe in this repo).
