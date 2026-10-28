function moveAndFollow(n) {
    const w = workspace.activeWindow;
    const d = workspace.desktops[n - 1];
    if (!w || !d || !w.normalWindow) return;
    w.desktops = [d];
    workspace.currentDesktop = d;
}

for (let n = 1; n <= 9; n++) {
    registerShortcut("Move Window and Follow " + n, "Move Window to Desktop " + n + " and Follow",
        "Ctrl+Alt+" + n, function () { moveAndFollow(n); });
}
