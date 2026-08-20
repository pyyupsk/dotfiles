# Dotfiles

Personal configuration, organized by tool and managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each package directory mirrors your `$HOME` layout exactly. Running `stow <pkg>`
symlinks every file inside into place.

```
dotfiles/
├── README.md           this file
├── zsh/                package: zsh
│   ├── .zshrc          entry point: sources every file in ~/.zshrc.d
│   ├── .zshrc.d/       one module per concern, numbered for load order
│   └── .p10k.zsh       powerlevel10k config
├── git/
│   └── .gitconfig      git identity, SSH signing, pager
├── mise/
│   └── .config/mise/   global tool versions (node, python, rust)
├── opencode/
│   └── .config/opencode/  opencode theme
└── ssh/
    └── .ssh/           ssh host shortcuts
```

## zsh modules

| File | Purpose |
|------|---------|
| `10-env.zsh`        | PATH, locale |
| `20-mise.zsh`       | mise version manager integration |
| `30-plugins.zsh`    | completions, autosuggestions, fzf |
| `40-aliases.zsh`    | ls/cat/clear replacements (eza, bat) |
| `50-navigation.zsh` | cd aliases + zoxide |
| `60-git.zsh`        | git command aliases |
| `70-headroom.zsh`   | tool-specific aliases (oc) |
| `80-prompt.zsh`     | powerlevel10k theme |
| `90-syntax.zsh`     | syntax highlighting (must load last) |

## Install

```sh
stow zsh git mise opencode ssh   # create all symlinks
```

### Common stow commands

```sh
stow zsh            # install one package
stow -D zsh         # remove a package's symlinks
stow --adopt zsh    # overwrite existing files with package version
stow -n zsh         # dry run
stow -t ~ -d ~/dotfiles zsh  # explicit target/dir
```