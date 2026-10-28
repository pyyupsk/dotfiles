const GAP = 12;
const RESTORE_WIDTH = 0.72;
const RESTORE_MAX_HEIGHT = 0.86;

function area(w) {
    return workspace.clientArea(KWin.MaximizeArea, w);
}

function gapped(w) {
    const a = area(w);
    w.frameGeometry = { x: a.x + GAP, y: a.y + GAP, width: a.width - 2 * GAP, height: a.height - 2 * GAP };
}

function centered169(w) {
    const a = area(w);
    let width = Math.round(a.width * RESTORE_WIDTH);
    let height = Math.round(width * 9 / 16);
    if (height > a.height * RESTORE_MAX_HEIGHT) {
        height = Math.round(a.height * RESTORE_MAX_HEIGHT);
        width = Math.round(height * 16 / 9);
    }
    w.frameGeometry = { x: a.x + Math.round((a.width - width) / 2), y: a.y + Math.round((a.height - height) / 2), width: width, height: height };
}

function fillsArea(w) {
    const a = area(w), g = w.frameGeometry;
    const s = workspace.clientArea(KWin.ScreenArea, w);
    // splash screens and borderless games cover the whole screen: leave them
    if (g.y <= s.y && g.height >= s.height) return false;
    return g.x <= a.x + 1 && g.y <= a.y + 1 && g.width >= a.width - 2 && g.height >= a.height - 2;
}

function hook(w, isNew) {
    if (!w.normalWindow || w.skipTaskbar || w.macZoomHooked) return;
    // resizing KWin's own windows (Alt+Tab) crashes KWin 6.8.1, KDE bug 527269
    if (!w.resourceClass || /^(kwin|org\.kde\.kwin)/.test(w.resourceClass)) return;
    w.macZoomHooked = true;
    let pending = null;
    w.maximizedAboutToChange.connect(function (mode) {
        pending = mode === 3 ? "gap" : mode === 0 ? "restore" : null;
    });
    w.frameGeometryChanged.connect(function () {
        if (w.fullScreen) return;
        if (!pending) {
            if (fillsArea(w)) gapped(w);
            return;
        }
        const todo = pending;
        pending = null;    // clear first: our own resize fires this signal again
        if (todo === "gap") gapped(w); else centered169(w);
    });
    if (w.fullScreen) return;
    if (fillsArea(w)) gapped(w);
    else if (isNew && w.resizeable && !w.transient) centered169(w);
}

workspace.windowList().forEach(function (w) { hook(w, false); });
workspace.windowAdded.connect(function (w) { hook(w, true); });
