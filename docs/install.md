# Install on a new machine

This guide turns a fresh Arch Linux install into this desktop: KDE Plasma 6 that looks like macOS 27 Golden Gate, dark mode only. Follow the steps in order. `install.sh` does most of the work. This guide covers the parts that it cannot do.

## What you need

- Arch Linux installed with `archinstall`: systemd-boot, KDE Plasma profile, NVIDIA open driver, PipeWire, NetworkManager, zram.
- Your user account with sudo.
- An internet connection.
- The SSH key for GitHub (`~/.ssh/id_ed25519`). Copy it from your backup, then run `chmod 600 ~/.ssh/id_ed25519`.

## Phase 1: from a TTY, before the first login

Do not log in to Plasma yet. At the login screen, press Ctrl+Alt+F3 and log in on the text console.

```sh
sudo pacman -S --needed git stow
git clone git@github.com:pyyupsk/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh packages stow system fonts wallpaper
```

This step does the following:

1. It installs every package in `packages/pacman.txt` and `packages/aur.txt`. If paru is missing, it builds paru first.
2. It links the dotfiles into your home folder with stow, and makes zsh your login shell.
3. It copies the boot splash and the login screen to the system. It also adds `quiet splash` to the boot options and enables the system services.
4. It downloads SF Pro from Apple and the Golden Gate wallpaper.

Then reboot:

```sh
sudo reboot
```

You see the Apple logo while the machine starts, then the macOS login screen.

## Phase 2: in Plasma

Log in. The desktop still looks like plain KDE at this point.

```sh
cd ~/dotfiles
./install.sh theme plasma boot apps
```

The `theme` step installs macos-tahoe-liquid-kde without its window, through the unattended backend. It passes these choices (`THEME_CHOICES` in `install.sh`), then rebuilds the initramfs so that the boot splash shows the Apple logo:

| Choice                         | Value                            |
| ------------------------------ | -------------------------------- |
| Appearance                     | Dark                             |
| Icons                          | Regular                          |
| Accent color                   | Blue                             |
| Wallpaper                      | Golden Gate                      |
| Launcher                       | Golden Gate                      |
| Top panel, Dock, reset layout  | On                               |
| Acrylic glass, rounded corners | On                               |
| Shadows                        | Medium                           |
| Fonts                          | On                               |
| Firefox theme                  | Off (no Firefox on this machine) |
| Window controls                | Glassy                           |
| Files                          | Dolphin                          |
| Plymouth                       | On                               |
| OLED care                      | Off                              |

The `plasma` step installs the KWin scripts, the login splash, the menu bar clock, and builds Control Center.

The `boot` step installs the rEFInd boot picker and makes it the first boot entry. It draws the theme from the wallpaper, the theme icons and SF Pro, so it runs after those steps. If Secure Boot keys from sbctl exist, it signs rEFInd. systemd-boot stays installed as a fallback in the firmware boot menu.

The `apps` step installs the developer tools, VS Code extensions, T3 Code and Spicetify. When it asks, open Spotify, log in, close Spotify, then press Enter.

## Phase 3: from a TTY again

Log out. Press Ctrl+Alt+F3 and log in on the text console.

```sh
cd ~/dotfiles
./install.sh kde
```

This copies the KDE settings from `kde/home` into your home folder: the panels, the Dock, shortcuts, window rules, Dolphin sidebar, input languages and default apps. When you log out, Plasma writes its own settings and replaces these files. For this reason, Plasma must not run during this step.

Press Ctrl+Alt+F1 and log in.

## Check the result

```sh
./install.sh check
```

Each line shows `ok` or `todo`. A `todo` line names the step to run again. The check changes nothing.

## Steps that you do by hand

The script cannot do these steps, because they need a login, a secret or a choice in an app.

1. Fill in `~/.zshrc.local` with the AI gateway URL and key. The template is `zsh/.zshrc.local.example`. Never commit this file.
2. Run `sudo tailscale up` and log in to Tailscale.
3. Log in to 1Password, Helium, Vesktop, Spotify and T3 Code.
4. In Helium, open Settings, then Privacy and security, then Security. Turn off "Use secure DNS". If secure DNS stays on, Helium skips Tailscale DNS and `.ts.net` addresses do not open.
5. In Spotify, open the Marketplace tab and install the theme you use.
6. Open System Settings, then Display & Monitor. Set the refresh rate to 75 Hz. The settings snapshot does not store the monitor, because that file holds the monitor serial number.

## On a different machine

The steps work on other hardware, with these changes:

- Without an NVIDIA GPU, remove the `MODULES=` line from `system/etc/mkinitcpio.conf.d/10-plymouth.conf`. Also remove `nvidia-open` and `nvidia-utils` from `packages/pacman.txt`, and the three `nvidia-*` services from `install.sh`.
- Set the monitor resolution, refresh rate and scale in System Settings.
- The window rules use the virtual desktop IDs in `kde/home/.config/kwinrc`. Both files are copied together, so the IDs stay correct.

## Keep the snapshot up to date

After you change a setting in System Settings, save it to the repo:

```sh
~/dotfiles/kde/save.sh
cd ~/dotfiles && git diff kde
```

Check the diff for secrets before you commit. After you install or remove a package, update the lists:

```sh
pacman -Qqen > ~/dotfiles/packages/pacman.txt
pacman -Qqem | grep -v -x -e paru -e plasma-control-center-git > ~/dotfiles/packages/aur.txt
```
