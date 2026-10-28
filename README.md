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
├── opencode/            package: opencode
│   └── .config/opencode/  config, rtk plugin (no binary/locks)
├── ssh/
│   └── .ssh/           ssh host shortcuts
└── claude/             package: claude
    └── .claude/        settings, RTK.md + STYLE.md (opencode reads them too), statusline, hook
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
| `70-ai.zsh`         | AI env (non-secret) + oc aliases       |
| `80-prompt.zsh`     | powerlevel10k theme                    |
| `90-syntax.zsh`     | syntax highlighting (must load last)   |

## Local secrets

Machine-private values live outside repo in `~/.zshrc.local` (chmod 600),
sourced at end of `.zshrc`. Template: `zsh/.zshrc.local.example`.
Claude Code and OpenAI-compatible tools read the AI gateway URL and key
from there.

## claude

Ports `~/.claude` personal config (settings, `STYLE.md`/`RTK.md`,
statusline, one hook). Excluded on purpose:

- `settings.json:autoMode` — machine-generated session state, rebuilds itself
- everything else under `~/.claude` — sessions, credentials, caches

`~/.claude` must pre-exist so stow links per-file (state stays out of repo):

```sh
mkdir -p ~/.claude && stow claude
```

`--no-folding` keeps per-file links so machine state (sessions, credentials)
never lands inside repo dirs:

```sh
stow --no-folding claude opencode
```

## opencode

Ports `~/.config/opencode` personal config (`opencode.json`, rtk plugin).
`instructions` in `opencode.json` loads `claude/.claude/RTK.md`, `STYLE.md`
and the brain files directly, because opencode does not follow `@` imports.
Excluded on purpose:

- `bun.lock`, `package-lock.json`, `node_modules` — reinstallable
- `cli.json`, `service.json` (holds password), backups — machine state

Notes: `~/.config/opencode` must pre-exist before stow (same folding trap as
claude).

## Install

```sh
stow zsh git mise opencode ssh   # create all symlinks
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
