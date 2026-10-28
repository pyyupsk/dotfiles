import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.notificationmanager as NotificationManager
import org.kde.taskmanager as TaskManager
import org.kde.plasma.components as PlasmaComponents3
import "../code/Style.js" as Style
import "../code/NotificationView.js" as View

// Fork of Orla Notifications: macOS banners on top of KDE's notification server
PlasmoidItem {
    id: root
    readonly property var scheme: Style.scheme(Style.schemeFor(String(Kirigami.Theme.backgroundColor)))
    property double nowMs: Date.now()
    readonly property bool serviceAvailable: NotificationManager.Server.valid
    readonly property int unread: historyModel.unreadNotificationsCount
    readonly property int jobs: historyModel.activeJobsCount
    property var historyItems: []

    // Do Not Disturb, computed as KDE's applet does; the server holds the result.
    readonly property bool inhibitedNow: {
        root.nowMs; // Re-evaluate when time-limited Do Not Disturb runs out.
        if (!NotificationManager.Server.valid) return false;
        const until = settings.notificationsInhibitedUntil;
        let inhibited = !!until && !isNaN(until.getTime()) && Date.now() < until.getTime();
        inhibited = inhibited || settings.notificationsInhibitedByApplication;
        inhibited = inhibited || (settings.inhibitNotificationsWhenFullscreen && settings.fullscreenFocused);
        inhibited = inhibited || (settings.inhibitNotificationsWhenScreensMirrored && settings.screensMirrored);
        return inhibited;
    }
    property bool inhibited: false
    onInhibitedNowChanged: inhibited = inhibitedNow
    onInhibitedChanged: {
        // Update the server before the summary, so it is not "added while inhibited".
        NotificationManager.Server.inhibited = inhibited;
        if (!inhibited) {
            const urgency = settings.lowPriorityHistory ? NotificationManager.Notifications.LowUrgency
                : NotificationManager.Notifications.NormalUrgency;
            popupModel.showInhibitionSummary(urgency, settings.historyBlacklistedApplications, settings.historyBlacklistedServices);
        }
    }
    Component.onCompleted: {
        inhibited = inhibitedNow;
        NotificationManager.Server.inhibited = inhibited;
    }

    Plasmoid.icon: inhibited ? "notifications-disabled" : unread > 0 ? "notification-active" : "notification-inactive"
    Plasmoid.status: unread > 0 || jobs > 0 || inhibited ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
    toolTipMainText: qsTr("Notifications")
    toolTipSubText: !serviceAvailable ? qsTr("Notification service unavailable")
        : inhibited ? qsTr("Do Not Disturb is on")
        : unread > 0 ? qsTr("%1 unread").arg(Math.min(99, unread)) : qsTr("No new notifications")
    onExpandedChanged: if (root.expanded) markAllRead()

    function setDoNotDisturb(on) {
        if (on) {
            // "Until turned off", as Plasma's own toggle does it.
            const date = new Date();
            date.setFullYear(date.getFullYear() + 1);
            settings.notificationsInhibitedUntil = date;
        } else {
            settings.notificationsInhibitedUntil = undefined;
            settings.revokeApplicationInhibitions();
        }
        settings.save();
    }
    function doNotDisturbDetail() {
        if (!serviceAvailable) return qsTr("Notification service unavailable");
        if (!inhibited) return "";
        if (settings.notificationsInhibitedByApplication) return qsTr("Requested by an app");
        const until = settings.notificationsInhibitedUntil;
        const time = until && !isNaN(until.getTime()) ? until.getTime() : 0;
        if (time > nowMs && time - nowMs < 100 * 86400000)
            return qsTr("Until %1").arg(Qt.formatDateTime(until, "d MMM, HH:mm"));
        return qsTr("Until turned off");
    }
    function historyRow(id) {
        for (let row = 0; row < historyRows.count; row++) {
            const entry = historyRows.objectAt(row);
            if (entry && entry.notificationId === id) return row;
        }
        return -1;
    }
    function markAllRead() {
        for (let row = 0; row < historyRows.count; row++) {
            const entry = historyRows.objectAt(row);
            if (entry) entry.markRead();
        }
    }
    function rebuildHistory() {
        const items = [];
        for (let row = 0; row < historyRows.count && items.length < 200; row++) {
            const entry = historyRows.objectAt(row);
            if (entry && entry.type === NotificationManager.Notifications.NotificationType) items.push(entry.item());
        }
        historyItems = items;
    }
    function screenArea() {
        const containment = Plasmoid.containment;
        if (!containment) return Qt.rect(0, 0, -1, -1);
        return Qt.rect(containment.screenGeometry.x + containment.availableScreenRect.x,
                       containment.screenGeometry.y + containment.availableScreenRect.y,
                       containment.availableScreenRect.width, containment.availableScreenRect.height);
    }
    // Top-right like macOS, newest on top pushing older ones down; at most 80% of the screen.
    function positionBanners() {
        const area = screenArea();
        if (area.width <= 0 || area.height <= 0) return;
        const windows = [];
        for (let i = bannerWindows.count - 1; i >= 0; i--) {
            const window = bannerWindows.objectAt(i);
            if (window) windows.push(window);
        }
        const places = View.stack(area, windows.map(window => window.height), Style.space.md, Style.space.sm, 0.8);
        windows.forEach((window, i) => {
            window.x = area.x + area.width - Style.space.md - window.width;
            window.y = places[i].y;
            window.visible = places[i].visible;
        });
    }

    NotificationManager.Settings { id: settings }
    TaskManager.TasksModel { id: tasks }
    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: root.nowMs = Date.now()
    }

    NotificationManager.Notifications {
        id: popupModel
        limit: 8
        showExpired: false
        showDismissed: false
        showAddedDuringInhibition: false
        blacklistedDesktopEntries: settings.popupBlacklistedApplications
        blacklistedNotifyRcNames: settings.popupBlacklistedServices
        whitelistedDesktopEntries: root.inhibited ? settings.doNotDisturbPopupWhitelistedApplications : []
        whitelistedNotifyRcNames: root.inhibited ? settings.doNotDisturbPopupWhitelistedServices : []
        showJobs: settings.jobsInNotifications
        sortMode: NotificationManager.Notifications.SortByTypeAndUrgency
        sortOrder: Qt.AscendingOrder
        groupMode: NotificationManager.Notifications.GroupDisabled
        urgencies: {
            let urgencies = 0;
            if (!root.inhibited || settings.criticalPopupsInDoNotDisturbMode)
                urgencies |= NotificationManager.Notifications.CriticalUrgency;
            if (!root.inhibited)
                urgencies |= NotificationManager.Notifications.NormalUrgency;
            if (!root.inhibited && settings.lowPriorityPopups)
                urgencies |= NotificationManager.Notifications.LowUrgency;
            return urgencies;
        }
    }

    NotificationManager.Notifications {
        id: historyModel
        showExpired: true
        showDismissed: true
        showJobs: settings.jobsInNotifications
        sortMode: NotificationManager.Notifications.SortByDate
        groupMode: NotificationManager.Notifications.GroupDisabled
        ignoreBlacklistDuringInhibition: true
        blacklistedDesktopEntries: settings.historyBlacklistedApplications
        blacklistedNotifyRcNames: settings.historyBlacklistedServices
        urgencies: NotificationManager.Notifications.CriticalUrgency | NotificationManager.Notifications.NormalUrgency
            | (settings.lowPriorityHistory ? NotificationManager.Notifications.LowUrgency : 0)
    }

    Instantiator {
        id: historyRows
        model: historyModel
        delegate: QtObject {
            required property var model
            required property string notificationId
            required property int type
            required property string summary
            required property string body
            required property string applicationName
            required property string applicationIconName
            required property string desktopEntry
            required property string notifyRcName
            required property date created
            required property date updated
            required property bool closable
            required property bool hasDefaultAction
            function markRead() { if (!model.read) model.read = true; }
            function item() {
                const time = isNaN(updated) ? created : updated;
                return {id: notificationId, appKey: desktopEntry || notifyRcName || applicationName,
                    appName: applicationName, appIcon: applicationIconName, summary: summary, body: body,
                    createdMs: time.getTime(), closable: closable, hasDefaultAction: hasDefaultAction};
            }
        }
        onObjectAdded: Qt.callLater(root.rebuildHistory)
        onObjectRemoved: Qt.callLater(root.rebuildHistory)
    }
    Connections {
        target: historyModel
        function onDataChanged() { Qt.callLater(root.rebuildHistory); }
        function onModelReset() { Qt.callLater(root.rebuildHistory); }
    }

    Instantiator {
        id: bannerWindows
        model: popupModel
        delegate: NativeBannerWindow {
            id: banner
            required property int index
            required property var model
            required property string notificationId
            required property bool hasDefaultAction
            required property list<string> actionNames
            required property list<string> actionLabels
            required property string configureActionLabel
            required property bool hasReplyAction
            required property string replyActionLabel
            required property string replyPlaceholderText
            required property string replySubmitButtonText
            required property int urgency
            required property int timeout
            required property list<url> urls
            required property int type
            required property int jobState
            required property string applicationName
            required property string applicationIconName
            required property date updated
            required property date created
            required property bool closable
            required property string summary
            required property string body
            required property var image
            required property var iconName
            required property int percentage
            required property string jobError
            required property bool suspendable
            required property bool killable
            required property bool resident
            required property string notifyRcName
            required property string desktopEntry
            readonly property bool isTransient: model.transient
            readonly property bool isJob: type === NotificationManager.Notifications.JobType
            readonly property bool hasSomeActions: hasDefaultAction || actionLabels.length > 0
                || configureActionLabel.length > 0 || hasReplyAction
            // Without a default action, clicking brings the app's window forward (KDE does the same).
            property var fallbackWindow: null
            readonly property int closeBehavior: resident ? NotificationManager.Notifications.None
                : NotificationManager.Notifications.Close

            function modelIndex() { return popupModel.index(index, 0); }

            notification: ({
                id: notificationId, appName: applicationName, appIcon: applicationIconName,
                summary: summary, body: body, actions: View.actions(actionNames, actionLabels),
                reply: View.reply(hasReplyAction, replyActionLabel, replyPlaceholderText, replySubmitButtonText),
                thumbnail: View.thumbnail(urls),
                hasDefaultAction: hasDefaultAction || fallbackWindow !== null, closable: closable,
                critical: urgency === NotificationManager.Notifications.CriticalUrgency,
                createdMs: (isNaN(updated) ? created : updated).getTime(),
                job: !isJob ? null : {
                    state: jobState === NotificationManager.Notifications.JobStateSuspended ? "suspended"
                        : jobState === NotificationManager.Notifications.JobStateStopped ? "stopped" : "running",
                    percentage: percentage, suspendable: suspendable, killable: killable, error: jobError
                }
            })
            bannerImage: image
            bannerIcon: iconName
            scheme: root.scheme
            nowMs: root.nowMs
            bannerTimeout: View.effectiveTimeout(timeout, settings.popupTimeout + (urls.length > 0 ? 5000 : 0),
                !settings.permanentJobPopups && isJob && jobState !== NotificationManager.Notifications.JobStateStopped
                    ? settings.popupTimeout : 0)

            onEngagedChanged: if (engaged && !model.read) model.read = true
            onHeightChanged: Qt.callLater(root.positionBanners)
            onActivated: {
                if (fallbackWindow && !hasDefaultAction) {
                    if (fallbackWindow.valid) tasks.requestActivate(fallbackWindow);
                    if (!resident) popupModel.close(modelIndex());
                    return;
                }
                popupModel.invokeDefaultAction(modelIndex(), closeBehavior);
            }
            onCloseRequested: popupModel.close(modelIndex())
            onActionRequested: name => popupModel.invokeAction(modelIndex(), name, closeBehavior)
            onReplyRequested: text => popupModel.reply(modelIndex(), text, closeBehavior)
            onJobControlRequested: control => {
                if (control === "suspend") popupModel.suspendJob(modelIndex());
                else if (control === "resume") popupModel.resumeJob(modelIndex());
                else if (control === "kill") popupModel.killJob(modelIndex());
            }
            onExpired: {
                // Keep resident and actionable notifications usable in the history.
                if (resident || (hasSomeActions && !isTransient)) model.expired = true;
                else popupModel.expire(modelIndex());
            }
            Component.onCompleted: {
                if (root.inhibited) model.wasAddedDuringInhibition = false;
                if (type === NotificationManager.Notifications.NotificationType && desktopEntry) {
                    // Apps seen spawning a popup can be configured later, as in KDE.
                    if (!notifyRcName) {
                        settings.registerKnownApplication(desktopEntry);
                        settings.save();
                    }
                    if (!hasDefaultAction) {
                        for (let i = 0; i < tasks.rowCount(); i++) {
                            const idx = tasks.index(i, 0);
                            if (tasks.data(idx, TaskManager.AbstractTasksModel.AppId) === desktopEntry + ".desktop") {
                                fallbackWindow = tasks.makePersistentModelIndex(i);
                                break;
                            }
                        }
                    }
                }
                // Orla handles the timeout now.
                popupModel.stopTimeout(modelIndex());
            }
        }
        onObjectAdded: (index, object) => {
            root.positionBanners();
            object.visible = true;
            popupModel.playSoundHint(popupModel.index(index, 0));
        }
        onObjectRemoved: (index, object) => {
            // A banner removed by a filter change hands its timeout back to the model.
            popupModel.startTimeout(object.notificationId);
            Qt.callLater(root.positionBanners);
        }
    }

    // In the menu bar: the date and time, like macOS. Click opens Notification Center.
    property date clockNow: new Date()
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: root.clockNow = new Date()
    }
    preferredRepresentation: compactRepresentation
    compactRepresentation: MouseArea {
        Layout.minimumWidth: clockLabel.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.preferredWidth: Layout.minimumWidth
        Layout.fillHeight: true
        onClicked: root.expanded = !root.expanded
        PlasmaComponents3.Label {
            id: clockLabel
            anchors.centerIn: parent
            text: Qt.formatDateTime(root.clockNow, "ddd MMM d  h:mm AP")
            font.family: "SF Pro Text"
            font.pointSize: 10
            font.weight: Font.Medium
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: Style.size.popupWidth
        Layout.preferredHeight: center.implicitHeight + Style.space.md * 2
        Layout.minimumWidth: Style.size.popupWidth
        NotificationCenter {
            id: center
            anchors.fill: parent
            anchors.margins: Style.space.md
            groups: View.groups(root.historyItems)
            doNotDisturb: root.inhibited
            doNotDisturbAvailable: root.serviceAvailable
            doNotDisturbDetail: root.doNotDisturbDetail()
            scheme: root.scheme
            nowMs: root.nowMs
            onClearAllRequested: historyModel.clear(NotificationManager.Notifications.ClearExpired)
            onClearGroupRequested: key => {
                for (let row = historyRows.count - 1; row >= 0; row--) {
                    const entry = historyRows.objectAt(row);
                    if (entry && entry.item().appKey === key && entry.closable) historyModel.close(historyModel.index(row, 0));
                }
            }
            onCloseRequested: id => {
                const row = root.historyRow(id);
                if (row >= 0) historyModel.close(historyModel.index(row, 0));
            }
            onActivated: id => {
                const row = root.historyRow(id);
                if (row >= 0) historyModel.invokeDefaultAction(historyModel.index(row, 0), NotificationManager.Notifications.Close);
            }
            onDoNotDisturbToggled: on => root.setDoNotDisturb(on)
        }
    }
}
