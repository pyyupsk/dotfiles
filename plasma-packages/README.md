# Plasma packages

KDE add-ons that give the desktop its macOS 27 behavior. Copy them into
`~/.local/share`. Do not stow them: KDE ignores a package whose files are
symlinks that point outside the package, and falls back to Breeze.

| Folder | What it does |
| ------ | ------------ |
| `kwin/scripts/mac-zoom` | Maximize keeps a 12 px gap. Restore and new windows open centered at 16:9 |
| `kwin/scripts/dock-autohide` | On an empty desktop, the Dock stays visible. With a window open, it hides |
| `kwin/effects/mac-zoom-anim` | Animates maximize and restore in both directions |
| `plasma/look-and-feel/com.pyyupsk.applesplash` | Login splash: Apple logo and progress bar |
| `plasmoids/com.pyyupsk.notificationclock` | Menu bar clock that opens Notification Center |
| `plasma-control-center/PKGBUILD` | Builds Control Center from `~/.local/src/plasma-control-center` |

## Install

```sh
cd ~/dotfiles/plasma-packages
mkdir -p ~/.local/share/kwin ~/.local/share/plasma
cp -r kwin/scripts kwin/effects ~/.local/share/kwin/
cp -r plasma/look-and-feel plasmoids ~/.local/share/plasma/

kwriteconfig6 --file kwinrc --group Plugins --key mac-zoomEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key dock-autohideEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key mac-zoom-animEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key maximizeEnabled false
kwriteconfig6 --file ksplashrc --group KSplash --key Theme com.pyyupsk.applesplash
qdbus6 org.kde.KWin /KWin reconfigure
```

The window rules (Spotify, Vesktop, Helium and T3 Code on desktops 1 to 4)
live in `kde/`, together with the `kwinrc` that holds the desktop IDs they use.

## Control Center

The PKGBUILD builds from a local clone that carries one extra commit: the
menu bar button uses the `control-center-symbolic` icon from `icons/`.

```sh
git clone https://github.com/cesarconte/plasma-control-center ~/.local/src/plasma-control-center
cd ~/.local/src/plasma-control-center
sed -i 's/"menu_new-symbolic"/"control-center-symbolic"/' src/qml/ExpanderArrow.qml
git commit -qam "use control-center-symbolic panel icon"

mkdir -p /tmp/pcc && cp ~/dotfiles/plasma-packages/plasma-control-center/PKGBUILD /tmp/pcc/
cd /tmp/pcc && makepkg -si
```
