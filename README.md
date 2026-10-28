# Dotfiles

Configuration for an Arch Linux machine with KDE Plasma 6 that looks and works like macOS 27 Golden Gate, dark mode only.

- To set up a new machine, read [docs/install.md](docs/install.md).
- To learn which file controls which part of the desktop, read [docs/desktop.md](docs/desktop.md).

## Layout

Folders of three kinds live here. Stow packages are linked into `$HOME`. Copied folders are copied by `install.sh`, because KDE or the system cannot use symlinks for them. The rest are lists and docs.

| Folder             | Kind             | Holds                                                                            |
| ------------------ | ---------------- | -------------------------------------------------------------------------------- |
| `zsh/`             | stow             | `.zshrc`, modules in `.zshrc.d/`, powerlevel10k prompt                           |
| `git/`             | stow             | `.gitconfig`: identity, SSH signing, pager                                       |
| `ssh/`             | stow             | `.ssh/config` for GitHub                                                         |
| `mise/`            | stow             | Global tool versions: bun, deno, node LTS, rust stable, uv                       |
| `alacritty/`       | stow             | Terminal look, Shift+Enter for Claude Code                                       |
| `fontconfig/`      | stow             | SF Pro for the UI, Noto Sans Thai for Thai                                       |
| `vscode/`          | stow             | VS Code configuration and keybindings                                            |
| `claude/`          | stow             | Claude Code configuration, hooks, statusline, `RTK.md`, `STYLE.md`               |
| `opencode/`        | stow             | opencode configuration and rtk plugin                                            |
| `applications/`    | stow             | Hides developer tools from Launchpad                                             |
| `icons/`           | stow             | Control Center menu bar icon                                                     |
| `kde/`             | copied           | Snapshot of the KDE configuration, with `save.sh` and `apply.sh`                 |
| `plasma-packages/` | copied           | KWin scripts, KWin effect, login splash, menu bar clock, Control Center PKGBUILD |
| `system/`          | copied with sudo | Boot splash configuration and the SDDM login screen                              |
| `packages/`        | list             | Packages from the Arch repos and the AUR                                         |
| `docs/`            | docs             | Install guide and desktop reference                                              |

## install.sh

```sh
./install.sh            # show the steps and the three phases
./install.sh check      # report what still differs from this repo; changes nothing
./install.sh fonts      # run one step; every step is safe to run again
```

The steps are `packages`, `stow`, `system`, `fonts`, `wallpaper`, `theme`, `plasma`, `kde` and `apps`. [docs/install.md](docs/install.md) gives the order.

## Stow

The packages use `--no-folding`, so stow links each file and never a whole folder. Apps then keep their own state (sessions, caches, credentials) outside this repo.

```sh
stow --no-folding zsh      # link one package
stow -D zsh                # remove its links
stow -n -v --no-folding zsh   # dry run
```

## Secrets

Secrets never go into this repo.

- `~/.zshrc.local` holds the AI gateway URL and key. It loads at the end of `.zshrc`. The template is `zsh/.zshrc.local.example`. Keep the file at mode 600.
- `.gitignore` blocks SSH keys, `.pem` and `.key` files and `.zshrc.local`.
- Before you commit a new `kde/save.sh` snapshot, read the diff for secrets.

## zsh modules

Files in `zsh/.zshrc.d/` load in name order.

| File                | Purpose                                           |
| ------------------- | ------------------------------------------------- |
| `10-env.zsh`        | PATH, BROWSER                                     |
| `15-history.zsh`    | History options                                   |
| `20-mise.zsh`       | mise activation                                   |
| `25-bun.zsh`        | bun PATH and completions                          |
| `30-plugins.zsh`    | Completions, autosuggestions, fzf                 |
| `40-aliases.zsh`    | eza and bat in place of ls and cat                |
| `50-navigation.zsh` | zoxide and cd aliases                             |
| `60-git.zsh`        | git aliases                                       |
| `70-ai.zsh`         | opencode PATH, `cc` for claude, `oc` for opencode |
| `80-prompt.zsh`     | powerlevel10k                                     |
| `85-p10k-theme.zsh` | macOS colors for the prompt                       |
| `90-syntax.zsh`     | Syntax highlighting in macOS colors (loads last)  |

## claude and opencode

Both tools read the same rules: `claude/.claude/RTK.md` and `STYLE.md`. Claude reads them through `@` imports in `CLAUDE.md`. opencode does not follow `@` imports, so `instructions` in `opencode.json` lists the files.

These files stay out of the repo on purpose: sessions, credentials and caches in `~/.claude`, and `cli.json` and `service.json` in `~/.config/opencode`. `service.json` holds a password.
