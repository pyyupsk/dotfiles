.pragma library

var version = 1;

var brand = {
    ink: "#111923",
    slate: "#283542",
    sea: "#69d7c2",
    deepSea: "#167361",
    foam: "#eaf4f1",
    paper: "#f4f0e8"
};

var schemes = {
    dark: {
        canvas: "#111923",
        surface: "#151f2a",
        raised: "#1d2935",
        sunken: "#0d141c",
        border: "#2a3846",
        borderStrong: "#3b4c5e",
        rim: "#ffffff",
        rimOpacity: 0.07,
        text: "#eaf4f1",
        textMuted: "#a5b4bf",
        accent: "#69d7c2",
        accentHover: "#8fe4d4",
        onAccent: "#0b2a27",
        focus: "#69d7c2",
        success: "#69d7c2",
        warning: "#f2b866",
        danger: "#ff9a8f"
    },
    light: {
        canvas: "#f4f0e8",
        surface: "#faf8f3",
        raised: "#ffffff",
        sunken: "#ebe6dc",
        border: "#ddd6c9",
        borderStrong: "#c6bdae",
        rim: "#ffffff",
        rimOpacity: 0.7,
        text: "#1c2530",
        textMuted: "#56626e",
        accent: "#167361",
        accentHover: "#0f5f50",
        onAccent: "#ffffff",
        focus: "#167361",
        success: "#167361",
        warning: "#8a5300",
        danger: "#b3261e"
    }
};

var dockThemes = {
    glass: {scheme: "dark", foreground: "#edf1f9", muted: "#9da9bf", accent: "#69d7c2",
        surface: "#283542", border: "#3c4b65", opacity: 219 / 255},
    midnight: {scheme: "dark", foreground: "#edf1f9", muted: "#9da9bf", accent: "#69d7c2",
        surface: "#111923", border: "#3c4b65", opacity: 1},
    paper: {scheme: "light", foreground: "#252b35", muted: "#606c79", accent: "#167361",
        surface: "#f4f0e8", border: "#cec9bf", opacity: 1}
};

var space = {xxs: 2, xs: 4, sm: 8, md: 12, lg: 16, xl: 20, xxl: 24, xxxl: 32};

var radius = {xs: 4, sm: 6, control: 8, tile: 12, card: 14, module: 18, popup: 20, pill: 999};

var dock = {
    artwork: 6,
    slotGap: 8,
    glassInset: 4,
    glassPadding: 3,
    iconRadius: 0.225,
    systemGlassBandX: 10,
    systemGlassBandY: 12
};

var glass = {
    sheenDark: 0.07, sheenLight: 0.4,
    rimTopDark: 0.28, rimTopLight: 0.9,
    rimBottomDark: 0.04, rimBottomLight: 0.35,
    shadowDark: 0.42, shadowLight: 0.16,
    shadowBlur: 18, shadowOffset: 5,
    highlight: "#ffffff", shade: "#000000",
    frostTint: 0.5, frostModule: 0.07, frostBorder: 0.09, frameMargin: 10
};

var iconTiles = {
    paper: {top: "#fbf9f4", bottom: "#e6dfd2", ink: "#1c2530", accent: "#167361"},
    coral: {top: "#d9736c", bottom: "#9c3f58", ink: "#ffffff", accent: "#ffffff"},
    sea: {top: "#2fa597", bottom: "#1d6f78", ink: "#ffffff", accent: "#ffffff"},
    deepSea: {top: "#3a97a6", bottom: "#17485a", ink: "#ffffff", accent: "#ffffff"},
    slate: {top: "#4f5f6d", bottom: "#253240", ink: "#ffffff", accent: "#69d7c2"},
    ink: {top: "#2b3747", bottom: "#111923", ink: "#eaf4f1", accent: "#69d7c2"}
};
var widgetTiles = {clock: "ink", pomodoro: "coral", music: "sea", systemBattery: "ink",
    quota: "slate", peripherals: "deepSea", recording: "ink", controlCenter: "slate"};
var levels = {good: "#69d7c2", low: "#f2b866", critical: "#ff8a7a"};
function iconTile(kind) { return iconTiles[widgetTiles[kind] || "slate"]; }

var type = {
    overline: 10,
    caption: 11,
    label: 12,
    body: 13,
    title: 15,
    headline: 20,
    display: 40
};
var weight = {regular: 400, medium: 500, demiBold: 600, bold: 700};
var letterSpacing = {overline: 1.2};

var size = {
    control: 36,
    target: 40,
    iconButton: 28,
    iconSm: 16,
    iconMd: 20,
    iconLg: 28,
    ringStroke: 3,
    indicator: 4,
    popupWidth: 350,
    divider: 1
};

var motion = {fast: 120, normal: 180, slow: 260, hoverScale: 1.04, pressScale: 0.9, lift: 3, bounce: 10};
function duration(base, reducedMotion) { return reducedMotion ? 0 : base; }

var state = {hover: 0.08, pressed: 0.14, selected: 0.16, chip: 0.05, disabled: 0.38};

function scheme(name) { return schemes[name === "light" ? "light" : "dark"]; }
function dockTheme(name) { return dockThemes[dockThemes[name] ? name : "glass"]; }

function alpha(color, opacity) {
    const hex = String(color).replace("#", "");
    const rgb = hex.length === 8 ? hex.slice(2) : hex;
    const value = Math.max(0, Math.min(255, Math.round(opacity * 255)));
    return "#" + (value < 16 ? "0" : "") + value.toString(16) + rgb.toLowerCase();
}

function channel(value) {
    const c = value / 255;
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
}
function luminance(color) {
    const hex = String(color).replace("#", "");
    const rgb = hex.length === 8 ? hex.slice(2) : hex;
    return 0.2126 * channel(parseInt(rgb.slice(0, 2), 16))
        + 0.7152 * channel(parseInt(rgb.slice(2, 4), 16))
        + 0.0722 * channel(parseInt(rgb.slice(4, 6), 16));
}
function contrast(first, second) {
    const a = luminance(first), b = luminance(second);
    return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
}
function schemeFor(background) {
    return luminance(background) > 0.4 ? "light" : "dark";
}
