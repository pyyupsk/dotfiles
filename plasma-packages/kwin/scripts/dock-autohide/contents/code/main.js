// "dodgewindows" keeps the Dock visible without reserving screen space, so
// windows are never pushed up; "none" would resize them on every switch.
const SETTLE_MS = 600;
let last = null;

const settle = new QTimer();
settle.singleShot = true;
settle.timeout.connect(function () { update(); });

function counts(w, gone) {
    return w !== gone && w.normalWindow && !w.minimized && !w.skipTaskbar &&
        (w.onAllDesktops || w.desktops.indexOf(workspace.currentDesktop) >= 0);
}

function apply(mode) {
    if (mode === last) return;
    last = mode;
    callDBus("org.kde.plasmashell", "/PlasmaShell", "org.kde.PlasmaShell", "evaluateScript",
        'panels().forEach(function (p) { if (p.location == "bottom") p.hiding = "' + mode + '"; })');
}

function update(gone) {
    apply(workspace.windowList().some(function (w) { return counts(w, gone); }) ? "autohide" : "dodgewindows");
}

function hook(w) {
    w.minimizedChanged.connect(function () { update(); });
    w.desktopsChanged.connect(function () { update(); });
}

workspace.windowList().forEach(hook);
workspace.windowAdded.connect(function (w) { hook(w); update(); });
workspace.windowRemoved.connect(function (w) { update(w); });
// Hide during the slide, show only once the switching has stopped
workspace.currentDesktopChanged.connect(function () {
    apply("autohide");
    settle.start(SETTLE_MS);
});
update();
