# Dotfiles

Personal configuration, organized by tool and managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each package directory mirrors your `$HOME` layout exactly. Running `stow <pkg>`
symlinks every file inside into place.

```tree
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
├── nvim/
│   └── .config/nvim/   neovim (LazyVim) config
├── opencode/            package: opencode
│   └── .config/opencode/  config, theme, plugin, skill (no binary/locks)
├── ssh/
│   └── .ssh/           ssh host shortcuts
├── claude/             package: claude
│   └── .claude/        settings, style docs, agents, commands, hooks
└── bin/
    └── .local/bin/     personal scripts
```

## zsh modules

| File                | Purpose                                |
| ------------------- | -------------------------------------- |
| `10-env.zsh`        | PATH, locale, Node options             |
| `15-history.zsh`    | command history options                |
| `20-mise.zsh`       | mise version manager integration       |
| `25-bun.zsh`        | bun runtime + completions              |
| `30-plugins.zsh`    | completions, autosuggestions, fzf      |
| `40-aliases.zsh`    | ls/cat/clear replacements (eza, bat)   |
| `50-navigation.zsh` | cd aliases + zoxide                    |
| `60-git.zsh`        | git command aliases                    |
| `70-headroom.zsh`   | headroom env (non-secret) + oc aliases |
| `80-prompt.zsh`     | powerlevel10k theme                    |
| `90-syntax.zsh`     | syntax highlighting (must load last)   |

## bin

| File                    | Purpose                                                                                  |
| ----------------------- | ---------------------------------------------------------------------------------------- |
| `oc-update-whitelist`   | fetch model pricing from models.dev and update opencode's zen whitelist with free models |
| `headroom-ensure-local` | run headroom ensure, relocate secrets to `~/.zshrc.local`, strip hook block              |

## Local secrets

Machine-private values live outside repo in `~/.zshrc.local` (chmod 600),
sourced at end of `.zshrc`. Template: `zsh/.zshrc.local.example`.
`headroom-ensure-local` (bin package) runs headroom ensure, then moves
re-injected `TARGET_API_*` lines from stowed `.zshrc` to `~/.zshrc.local`.

## claude

Ports `~/.claude` personal config (settings, `STYLE.md`/`RTK.md`, agents,
commands, statusline, one hook). Excluded on purpose:

- `skills/` — symlinks into `~/.agents/skills`, separate system.
  Real dirs (`impeccable-claude`, `lurker`, `codebase-onboarding`) also live
  there, symlinked back; plugin-synced `synced/` stays put
- `settings.json:autoMode` — machine-generated session state, rebuilds itself
- everything else under `~/.claude` — sessions, credentials, caches

`~/.claude` must pre-exist so stow links per-file (state stays out of repo):

```sh
mkdir -p ~/.claude && stow claude
```

## opencode

Ports `~/.config/opencode` personal config (`opencode.json`, theme, rtk
plugin, impeccable command). Skills live outside repo under
`~/.agents/skills/` (`impeccable-opencode`), symlinked in. Excluded on purpose:

- `skills/` — live in `~/.agents/skills/` (`impeccable-opencode`), symlinked in
- `bun.lock`, `package-lock.json`, `node_modules` — reinstallable
- `cli.json`, `service.json` (holds password), backups — machine state

Notes: `~/.config/opencode` must pre-exist before stow (same folding trap as
claude). `oc-update-whitelist` writes through the `opencode.json` symlink, so
whitelist refreshes show as repo diffs — commit them as chores.

## Install

```sh
stow zsh git mise nvim opencode ssh bin   # create all symlinks
mkdir -p ~/.claude && stow claude         # claude needs pre-existing dir
```

### Common stow commands

```sh
stow zsh            # install one package
stow -D zsh         # remove a package's symlinks
stow --adopt zsh    # overwrite existing files with package version
stow -n zsh         # dry run
stow -t ~ -d ~/dotfiles zsh  # explicit target/dir
```
