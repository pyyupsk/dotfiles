"use strict";

// KWin's maximize and mac-zoom's resize land in the same frame: fold them into one animation
const MIN_DELTA = 40;

class MacZoomAnim {
    constructor() {
        effect.configChanged.connect(() => this.loadConfig());
        effect.animationEnded.connect((window) => {
            delete window.zoomFrom;
            delete window.zoomAnim;
        });
        effects.windowAdded.connect((window) => this.manage(window));
        effects.stackingOrder.forEach((window) => this.manage(window));
        this.loadConfig();
    }

    loadConfig() {
        this.duration = animationTime(250);
    }

    manage(window) {
        window.windowFrameGeometryChanged.connect((w, old) => this.changed(w, old));
    }

    changed(window, old) {
        if (!window.visible || !window.normalWindow || window.isUserMove || window.isUserResize) return;
        const now = window.geometry;
        if (!window.zoomAnim &&
            Math.abs(now.width - old.width) < MIN_DELTA && Math.abs(now.height - old.height) < MIN_DELTA) return;

        const from = window.zoomFrom || Object.assign({}, old);
        window.zoomFrom = from;
        if (window.zoomAnim) cancel(window.zoomAnim);
        window.zoomAnim = animate({
            window: window,
            duration: this.duration,
            animations: [{
                type: Effect.Size,
                from: { value1: from.width, value2: from.height },
                to: { value1: now.width, value2: now.height },
                curve: QEasingCurve.OutCubic
            }, {
                type: Effect.Translation,
                from: {
                    value1: from.x - now.x - (now.width / 2 - from.width / 2),
                    value2: from.y - now.y - (now.height / 2 - from.height / 2)
                },
                to: { value1: 0, value2: 0 },
                curve: QEasingCurve.OutCubic
            }]
        });
    }
}

new MacZoomAnim();
