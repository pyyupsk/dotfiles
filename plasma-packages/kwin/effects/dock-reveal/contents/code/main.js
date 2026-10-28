"use strict";

// The Dock Autohide script shows the Dock ~600 ms after a desktop switch by
// changing the panel mode, which KWin does not animate
const WINDOW_MS = 2000;
let switchedAt = 0;

function reveal(w) {
    if (!w.visible || Date.now() - switchedAt > WINDOW_MS) return;
    animate({
        window: w,
        duration: animationTime(250),
        animations: [{
            type: Effect.Translation,
            from: { value1: 0, value2: w.height },
            to: { value1: 0, value2: 0 },
            curve: QEasingCurve.OutCubic
        }, {
            type: Effect.Opacity,
            from: 0.0,
            to: 1.0,
            curve: QEasingCurve.OutCubic
        }]
    });
}

function manage(w) {
    if (!w.dock || w.windowClass.indexOf("plasmashell") < 0 ||
        w.y < effects.virtualScreenGeometry.height / 2) return;
    w.windowHiddenChanged.connect(function () { reveal(w); });
}

effects.desktopChanged.connect(function () { switchedAt = Date.now(); });
effects.windowAdded.connect(manage);
effects.stackingOrder.forEach(manage);
