let last = null;

function counts(w, gone) {
    return w !== gone && w.normalWindow && !w.minimized && !w.skipTaskbar &&
        (w.onAllDesktops || w.desktops.indexOf(workspace.currentDesktop) >= 0);
}

function update(gone) {
    const mode = workspace.windowList().some(function (w) { return counts(w, gone); }) ? "autohide" : "none";
    if (mode === last) return;
    last = mode;
    callDBus("org.kde.plasmashell", "/PlasmaShell", "org.kde.PlasmaShell", "evaluateScript",
        'panels().forEach(function (p) { if (p.location == "bottom") p.hiding = "' + mode + '"; })');
}

function hook(w) {
    w.minimizedChanged.connect(function () { update(); });
    w.desktopsChanged.connect(function () { update(); });
}

workspace.windowList().forEach(hook);
workspace.windowAdded.connect(function (w) { hook(w); update(); });
workspace.windowRemoved.connect(function (w) { update(w); });
workspace.currentDesktopChanged.connect(function () { update(); });
update();
