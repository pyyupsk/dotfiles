# Desktop reference

This page lists each part of the macOS 27 look and the file that controls it. Use it to find what to edit, or to learn why something behaves as it does.

## Look

| Part                                                                      | Source                                                                            | File in this repo                                                     |
| ------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| Global theme, colors, window buttons, icons, cursor, sounds, Kvantum, GTK | macos-tahoe-liquid-kde v0.61.8, Golden Gate edition                               | Installer choices in `docs/install.md`                                |
| Dark mode only                                                            | Light and dark both point to the dark theme, and the switch timer is off          | `kde/home/.config/kdeglobals`, `install.sh` (theme step)              |
| Fonts                                                                     | SF Pro Text for the UI, JetBrainsMono Nerd Font for code, Noto Sans Thai for Thai | `fontconfig/`, `kde/home/.config/kdeglobals`                          |
| Desktop wallpaper                                                         | MacGoldenGate, installed by the theme                                             | `kde/home/.config/plasma-org.kde.plasma.desktop-appletsrc`            |
| Lock screen                                                               | Breeze, with the Golden Gate Dark wallpaper                                       | `kde/home/.config/kscreenlockerrc`                                    |
| Boot splash                                                               | Plymouth theme MacTahoeLiquidKde, NVIDIA loads early                              | `system/etc/mkinitcpio.conf.d/`                                       |
| Login screen                                                              | Our own SDDM theme GoldenGate                                                     | `system/usr/share/sddm/themes/GoldenGate/`, `system/etc/sddm.conf.d/` |
| Splash after login                                                        | Apple logo and progress bar, same size as the boot splash                         | `plasma-packages/plasma/look-and-feel/com.pyyupsk.applesplash/`       |
| Control Center icon                                                       | Two toggles, like macOS                                                           | `icons/`                                                              |

## Menu bar and Dock

| Part                                                                                                                                               | File                                                                                       |
| -------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Top panel: Apple menu, app menu, Control Center, clock                                                                                             | `kde/home/.config/plasma-org.kde.plasma.desktop-appletsrc`                                 |
| Control Center (sound, brightness, network, Bluetooth, media, clipboard)                                                                           | Built from `plasma-packages/plasma-control-center/PKGBUILD`                                |
| Clock that opens Notification Center                                                                                                               | `plasma-packages/plasmoids/com.pyyupsk.notificationclock/`                                 |
| On an empty desktop the Dock shows. With a window open, it hides                                                                                   | `plasma-packages/kwin/scripts/dock-autohide/`                                              |
| After a desktop switch the Dock waits for the switching to stop, then slides up                                                                    | `plasma-packages/kwin/scripts/dock-autohide/`, `plasma-packages/kwin/effects/dock-reveal/` |
| Dock apps: Dolphin, Helium, T3 Code, VS Code, Alacritty, Vesktop, Spotify. Running apps from every desktop show, and a click moves to that desktop | `kde/home/.config/plasma-org.kde.plasma.desktop-appletsrc`                                 |
| Thin line between the apps and the Trash                                                                                                           | `plasma-packages/plasmoids/com.pyyupsk.docksep/`                                           |
| Launchpad hides developer tools                                                                                                                    | `kde/hidden-apps.txt`                                                                      |

## Windows

| Behavior                                                                    | File                                                                                 |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| Maximize keeps a 12 px gap and round corners                                | `plasma-packages/kwin/scripts/mac-zoom/`                                             |
| New windows and restored windows open at 16:9 in the center                 | `plasma-packages/kwin/scripts/mac-zoom/`                                             |
| Maximize and restore animate in both directions                             | `plasma-packages/kwin/effects/mac-zoom-anim/`                                        |
| During a desktop switch, the wallpaper stays still                          | `kde/home/.config/kwinrc` (`SlideBackground=false`)                                  |
| Spotify, Vesktop, Helium and T3 Code open on desktops 1 to 4                | `kde/home/.config/kwinrulesrc`                                                       |
| Alt+Tab shows big icons                                                     | `kde/home/.config/kwinrc` (`[TabBox]`)                                               |
| Picture in picture (Instagram calls) stays on top and follows every desktop | `kde/home/.config/kwinrulesrc` (`[pip]`), `plasma-packages/kwin/scripts/pip-sticky/` |

The mac-zoom script never resizes KWin's own windows, such as the Alt+Tab switcher. Resizing them crashes KWin 6.8.1 (KDE bug 527269).

## Shortcuts

All shortcuts are in `kde/home/.config/kglobalshortcutsrc`, except the launcher.

| Keys                     | Action                                                                                             |
| ------------------------ | -------------------------------------------------------------------------------------------------- |
| Alt+Space                | Launchpad (the launcher shortcut is in the panel file)                                             |
| Alt+F2                   | KRunner                                                                                            |
| F3, Ctrl+Up              | Mission Control (Overview)                                                                         |
| Ctrl+Down                | App windows (App Exposé)                                                                           |
| Alt+A, Alt+S             | Desktop to the left, desktop to the right                                                          |
| Alt+1 to Alt+4           | Go to desktop 1 to 4                                                                               |
| Ctrl+Alt+1 to Ctrl+Alt+9 | Move the window to that desktop and go there with it (`plasma-packages/kwin/scripts/move-follow/`) |
| Ctrl+Alt+F               | Maximize                                                                                           |
| Alt+M                    | Minimize                                                                                           |
| Alt+F                    | Full screen                                                                                        |
| Alt+Q, Alt+W             | Close window                                                                                       |
| Alt+Return               | Alacritty                                                                                          |
| Alt+B                    | Helium                                                                                             |
| Alt+E                    | Dolphin                                                                                            |
| Print                    | Screenshot of the full screen, copied to the clipboard                                             |
| Meta+Shift+S             | Screenshot of an area                                                                              |
| Ctrl+Shift+Space         | 1Password                                                                                          |

## Apps

| App             | Setup                                                                                          | File                                                                   |
| --------------- | ---------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| Dolphin         | Sidebar like Finder: Recents, Applications, Desktop, Documents, Downloads, Home. No status bar | `kde/home/.local/share/user-places.xbel`, `kde/home/.config/dolphinrc` |
| Default apps    | Code files open in VS Code, plain text in KWrite                                               | `kde/home/.config/mimeapps.list`                                       |
| VS Code         | Bearded Theme Vivid Black, SF Pro UI, rounded popups, no AI                                    | `vscode/`, extensions in `install.sh`                                  |
| Alacritty       | Dark gray, blur, KWin title bar, Shift+Enter for Claude Code                                   | `alacritty/`                                                           |
| zsh             | powerlevel10k prompt in macOS colors                                                           | `zsh/`                                                                 |
| Claude Code     | rtk and Serena hooks, plugins, Serena MCP                                                      | `claude/`, `install.sh` (apps step)                                    |
| opencode        | Rules from `claude/.claude/RTK.md` and `STYLE.md`                                              | `opencode/`                                                            |
| Spotify         | Spicetify with Marketplace                                                                     | `install.sh` (apps step)                                               |
| Input languages | English and Thai, shown as A and ก                                                             | `kde/home/.config/kxkbrc`                                              |
