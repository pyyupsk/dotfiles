// The desktops window rule does not stick for these windows, so pin them here
function pin(w) {
    if (w.caption === "Picture in picture") w.onAllDesktops = true;
}

function hook(w) {
    pin(w);
    w.captionChanged.connect(function () { pin(w); });
}

workspace.windowList().forEach(hook);
workspace.windowAdded.connect(hook);
