.pragma library


var limits = {appName: 60, summary: 200, body: 1200, label: 40, actions: 3, groupItems: 3};

// One line of plain text, trimmed and bounded.
function plain(text, maximum) {
    return String(text === undefined || text === null ? "" : text).replace(/\s+/g, " ").trim().slice(0, maximum);
}

// Notification bodies may carry a small HTML subset; Orla shows plain text and
// keeps at most two blank-free line breaks between paragraphs.
function plainBody(text, maximum) {
    var value = String(text === undefined || text === null ? "" : text);
    value = value.replace(/<br\s*\/?>/gi, "\n").replace(/<\/?(p|div|li)(\s[^>]*)?>/gi, "\n").replace(/<[^>]*>/g, "");
    value = value.replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, "\"")
        .replace(/&#0*39;|&apos;/g, "'").replace(/&nbsp;/g, " ").replace(/&amp;/g, "&");
    var lines = value.split(/\r?\n/).map(function (line) { return line.replace(/[^\S\n]+/g, " ").trim(); });
    lines = lines.filter(function (line) { return line.length > 0; });
    return lines.join("\n").slice(0, maximum || limits.body);
}

// A theme icon name or a local/remote URL-like source; anything else is dropped.
function iconSource(value) {
    var text = String(value || "");
    if (/^[A-Za-z0-9._+-]{1,128}$/.test(text)) return text;
    if (/^(file|image|qrc):\/{1,3}[^\s]{1,1024}$/.test(text)) return text;
    return "";
}

// KDE's rules: -1 uses the default, 0 keeps the banner, jobs may auto-hide.
function effectiveTimeout(modelTimeout, defaultTimeout, dismissTimeout) {
    if (modelTimeout === -1 || modelTimeout === undefined || modelTimeout === null) return defaultTimeout;
    if (dismissTimeout > 0) return dismissTimeout;
    return Math.max(0, modelTimeout);
}

// "agora", minutes, hours, or a date, from the creation time.
function age(createdMs, nowMs) {
    var elapsed = Math.max(0, nowMs - createdMs);
    if (!isFinite(elapsed) || !isFinite(createdMs) || createdMs <= 0) return {kind: "unknown", value: 0};
    if (elapsed < 60000) return {kind: "now", value: 0};
    if (elapsed < 3600000) return {kind: "minutes", value: Math.floor(elapsed / 60000)};
    if (elapsed < 86400000) return {kind: "hours", value: Math.floor(elapsed / 3600000)};
    return {kind: "date", value: createdMs};
}

// Up to three labeled actions; names and labels are bounded and unique.
function actions(names, labels) {
    var result = [];
    var seen = {};
    var count = Math.min(names ? names.length : 0, labels ? labels.length : 0, 16);
    for (var i = 0; i < count && result.length < limits.actions; i++) {
        var name = String(names[i] || "");
        var label = plain(labels[i], limits.label);
        if (!name || name === "default" || !label || seen[name]) continue;
        seen[name] = true;
        result.push({name: name, label: label});
    }
    return result;
}

// The first local image among a notification's files, shown as a thumbnail.
function thumbnail(urls) {
    var count = Math.min(urls ? urls.length : 0, 16);
    for (var i = 0; i < count; i++) {
        var url = String(urls[i] || "");
        if (/^file:\/\/\/[^\s]{1,1024}\.(png|jpe?g|webp|gif|bmp)$/i.test(url)) return url;
    }
    return "";
}

// An inline reply offered by the app, with bounded labels; null when there is none.
function reply(hasReply, label, placeholder, submit) {
    if (!hasReply) return null;
    return {label: plain(label, limits.label) || "", placeholder: plain(placeholder, 80) || "",
        submit: plain(submit, limits.label) || ""};
}

// Banners stack downward from the top edge with a gap; those that would go
// past `maximumFill` of the area are hidden, but the first one always shows.
function stack(area, heights, edge, gap, maximumFill) {
    var y = area.y + edge;
    var limit = area.y + area.height * maximumFill;
    var result = [];
    for (var i = 0; i < heights.length; i++) {
        var height = Math.max(0, heights[i]);
        var visible = i === 0 || y + height <= limit;
        result.push({y: y, visible: visible});
        if (height > 0) y += height + gap;
    }
    return result;
}

// History grouped by application, newest group first, newest items first.
function groups(items) {
    var byKey = {};
    var order = [];
    for (var i = 0; i < items.length; i++) {
        var item = items[i];
        var key = item.appKey || item.appName || "?";
        if (!byKey[key]) {
            byKey[key] = {key: key, appName: item.appName, appIcon: item.appIcon, latest: 0, items: []};
            order.push(key);
        }
        var group = byKey[key];
        group.items.push(item);
        group.latest = Math.max(group.latest, item.createdMs || 0);
    }
    var result = order.map(function (key) {
        var group = byKey[key];
        group.items.sort(function (a, b) { return (b.createdMs || 0) - (a.createdMs || 0); });
        return group;
    });
    result.sort(function (a, b) { return b.latest - a.latest; });
    return result;
}
