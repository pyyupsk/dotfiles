import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Controls.impl as ControlsImpl
import "../code/Style.js" as Style
import "../code/NotificationView.js" as View

// One notification laid out like a macOS banner: app icon on the left, app
// name and time on top, bold title and plain body below. Close and actions
// show on hover or keyboard focus. Presentation only: the host owns the model.
Item {
    id: root
    // {id, appName, appIcon, summary, body, actions: [{name, label}], hasDefaultAction,
    //  closable, critical, createdMs, job: null | {state, percentage, suspendable, killable, error},
    //  reply: null | {label, placeholder, submit}, thumbnail: "" | local image URL}
    required property var notification
    property var scheme: Style.scheme("dark")
    property double nowMs: Date.now()
    // Milliseconds before `expired()`; 0 keeps the banner. Pauses on hover/focus.
    property int timeout: 0
    property bool reducedMotion: false
    // The native host may show images (QImage) through Kirigami; tests use the theme icon.
    property Component iconComponent: themeIcon
    // While replying the banner stays, and the host lets its window take keyboard focus.
    property bool replying: false
    readonly property bool engaged: hover.hovered || root.activeFocus || closeButton.activeFocus
        || actionRepeater.focused || replying
    readonly property bool isJob: !!(notification && notification.job)
    readonly property var shownActions: notification && notification.actions ? notification.actions.slice(0, View.limits.actions) : []
    readonly property var replyOffer: notification && notification.reply ? notification.reply : null
    onNotificationChanged: if (!replyOffer) replying = false

    signal activated()
    signal closeRequested()
    signal actionRequested(string name)
    signal jobControlRequested(string control)
    signal replyRequested(string text)
    signal expired()

    function beginReply() {
        if (!replyOffer) return false;
        replying = true;
        Qt.callLater(() => replyField.forceActiveFocus(Qt.OtherFocusReason));
        return true;
    }
    function sendReply() {
        const text = replyField.text.trim().slice(0, 1000);
        if (!replying || !text) return false;
        replying = false;
        replyField.text = "";
        root.replyRequested(text);
        return true;
    }

    implicitWidth: Style.size.popupWidth - Style.space.xxs * 3
    implicitHeight: content.implicitHeight
    activeFocusOnTab: true
    Accessible.role: Accessible.AlertMessage
    Accessible.name: notification ? View.plain(notification.summary, View.limits.summary) : ""
    Accessible.description: notification ? View.plainBody(notification.body, 400) : ""

    function timeText() {
        const created = notification ? notification.createdMs : 0;
        const value = View.age(created, nowMs);
        if (value.kind === "now") return qsTr("now");
        if (value.kind === "minutes") return qsTr("%1m ago").arg(value.value);
        if (value.kind === "hours") return qsTr("%1h ago").arg(value.value);
        if (value.kind === "date") return Qt.formatDate(new Date(value.value), "d MMM");
        return "";
    }

    Keys.onReturnPressed: if (notification && notification.hasDefaultAction) root.activated()
    Keys.onEnterPressed: if (notification && notification.hasDefaultAction) root.activated()
    Keys.onDeletePressed: if (notification && notification.closable) root.closeRequested()
    Keys.onEscapePressed: if (notification && notification.closable) root.closeRequested()

    Timer {
        id: expiry
        interval: Math.max(1, root.timeout)
        running: root.timeout > 0 && !root.engaged && root.visible
        onTriggered: root.expired()
    }
    // Hover restarts the full time, as macOS keeps a banner while it is read.
    onEngagedChanged: if (!engaged && expiry.running) expiry.restart()

    HoverHandler { id: hover }
    TapHandler {
        enabled: !!root.notification && root.notification.hasDefaultAction
        onTapped: root.activated()
    }

    Component {
        id: themeIcon
        ControlsImpl.IconImage {
            name: View.iconSource(root.notification ? root.notification.appIcon : "") || "preferences-desktop-notification"
            sourceSize.width: Style.size.iconLg + Style.space.xs
            sourceSize.height: Style.size.iconLg + Style.space.xs
        }
    }

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Style.space.sm

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.space.md
            Loader {
                objectName: "notificationIcon"
                Layout.preferredWidth: Style.size.iconLg + Style.space.xs
                Layout.preferredHeight: Style.size.iconLg + Style.space.xs
                Layout.alignment: Qt.AlignTop
                sourceComponent: root.iconComponent
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.space.xxs
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.space.sm
                    Text {
                        objectName: "notificationApp"
                        Layout.fillWidth: true
                        text: root.notification ? View.plain(root.notification.appName, View.limits.appName) : ""
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        font.pixelSize: Style.type.caption
                        color: root.scheme.textMuted
                    }
                    Text {
                        objectName: "notificationTime"
                        text: root.timeText()
                        textFormat: Text.PlainText
                        font.pixelSize: Style.type.caption
                        color: root.scheme.textMuted
                    }
                }
                Text {
                    objectName: "notificationSummary"
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: root.notification ? View.plain(root.notification.summary, View.limits.summary) : ""
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    font.weight: Style.weight.bold
                    color: root.scheme.text
                }
                Text {
                    objectName: "notificationBody"
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: root.notification ? View.plainBody(root.notification.body) : ""
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    maximumLineCount: root.engaged ? 8 : 3
                    elide: Text.ElideRight
                    color: root.scheme.text
                }
                // File transfers and other jobs: a capsule bar and the percent.
                RowLayout {
                    objectName: "notificationJob"
                    Layout.fillWidth: true
                    visible: root.isJob
                    spacing: Style.space.sm
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Style.space.xs + Style.space.xxs
                        radius: height / 2
                        color: Style.alpha(root.scheme.text, 0.14)
                        Rectangle {
                            readonly property real progress: root.isJob && root.notification.job.percentage >= 0
                                ? Math.min(1, root.notification.job.percentage / 100) : 0
                            width: parent.width * progress
                            height: parent.height
                            radius: height / 2
                            color: root.scheme.accent
                        }
                    }
                    Text {
                        objectName: "notificationJobState"
                        text: !root.isJob ? ""
                            : root.notification.job.state === "suspended" ? qsTr("Paused")
                            : root.notification.job.state === "stopped"
                                ? (root.notification.job.error ? qsTr("Failed") : qsTr("Completed"))
                            : root.notification.job.percentage >= 0 ? Math.round(root.notification.job.percentage) + "%" : ""
                        textFormat: Text.PlainText
                        font.pixelSize: Style.type.caption
                        font.features: {"tnum": 1}
                        color: root.scheme.textMuted
                    }
                }
            }
            // A screenshot or other image the notification carries, like macOS attachments.
            Image {
                objectName: "notificationThumbnail"
                Layout.preferredWidth: Style.size.target + Style.space.lg
                Layout.preferredHeight: Style.size.target + Style.space.lg
                Layout.alignment: Qt.AlignTop
                visible: source.toString().length > 0 && status === Image.Ready
                source: root.notification && root.notification.thumbnail ? root.notification.thumbnail : ""
                // A constant decode size: tying it to width loops while the item is hidden.
                sourceSize.width: (Style.size.target + Style.space.lg) * 2
                sourceSize.height: (Style.size.target + Style.space.lg) * 2
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                clip: true
            }
        }

        // Actions, and pause/cancel for jobs, appear while the banner is engaged.
        RowLayout {
            objectName: "notificationActions"
            Layout.fillWidth: true
            visible: root.engaged && !root.replying && (root.shownActions.length > 0 || jobControls.visible
                || root.replyOffer !== null)
            spacing: Style.space.sm
            Repeater {
                id: actionRepeater
                readonly property bool focused: {
                    for (let i = 0; i < count; i++) {
                        const item = itemAt(i);
                        if (item && item.activeFocus) return true;
                    }
                    return false;
                }
                model: root.shownActions
                delegate: Controls.Button {
                    required property var modelData
                    objectName: "notificationAction"
                    Layout.fillWidth: true
                    text: modelData.label
                    onClicked: root.actionRequested(modelData.name)
                }
            }
            Controls.Button {
                objectName: "notificationReply"
                Layout.fillWidth: true
                visible: root.replyOffer !== null
                text: root.replyOffer && root.replyOffer.label ? root.replyOffer.label : qsTr("Reply")
                onClicked: root.beginReply()
            }
            RowLayout {
                id: jobControls
                visible: root.isJob && root.notification.job.state !== "stopped"
                    && (root.notification.job.suspendable || root.notification.job.killable)
                Controls.Button {
                    objectName: "notificationJobPause"
                    visible: root.isJob && root.notification.job.suspendable
                    text: root.isJob && root.notification.job.state === "suspended" ? qsTr("Resume") : qsTr("Pause")
                    onClicked: root.jobControlRequested(root.notification.job.state === "suspended" ? "resume" : "suspend")
                }
                Controls.Button {
                    objectName: "notificationJobCancel"
                    visible: root.isJob && root.notification.job.killable
                    text: qsTr("Cancel")
                    onClicked: root.jobControlRequested("kill")
                }
            }
        }

        // The reply field replaces the actions while it is open; Escape closes it.
        RowLayout {
            objectName: "notificationReplyRow"
            Layout.fillWidth: true
            visible: root.replying
            spacing: Style.space.sm
            Controls.TextField {
                id: replyField
                objectName: "notificationReplyField"
                Layout.fillWidth: true
                maximumLength: 1000
                placeholderText: root.replyOffer && root.replyOffer.placeholder ? root.replyOffer.placeholder
                                                                                : qsTr("Reply…")
                Accessible.name: placeholderText
                onAccepted: root.sendReply()
                Keys.onEscapePressed: {
                    root.replying = false;
                    text = "";
                    root.forceActiveFocus(Qt.OtherFocusReason);
                }
            }
            Controls.Button {
                objectName: "notificationReplySend"
                enabled: replyField.text.trim().length > 0
                text: root.replyOffer && root.replyOffer.submit ? root.replyOffer.submit : qsTr("Send")
                onClicked: root.sendReply()
            }
        }
    }

    // macOS puts the close control on the banner's top-left corner, on hover.
    Controls.AbstractButton {
        id: closeButton
        objectName: "notificationClose"
        visible: !!root.notification && root.notification.closable && (root.engaged || activeFocus)
        x: -Style.space.sm
        y: -Style.space.sm
        width: Style.size.iconMd
        height: Style.size.iconMd
        activeFocusOnTab: true
        Accessible.name: qsTr("Close notification")
        onClicked: root.closeRequested()
        background: Rectangle {
            radius: width / 2
            color: root.scheme.raised
            border.width: closeButton.visualFocus ? Style.space.xxs : Style.size.divider
            border.color: closeButton.visualFocus ? root.scheme.focus : root.scheme.border
        }
        contentItem: ControlsImpl.IconImage {
            name: "window-close-symbolic"
            color: root.scheme.text
            sourceSize.width: Style.size.iconSm - Style.space.xs
            sourceSize.height: Style.size.iconSm - Style.space.xs
        }
    }
    // Visible keyboard focus on the banner itself.
    Rectangle {
        anchors.fill: parent
        anchors.margins: -Style.space.xs
        radius: Style.radius.module
        color: Style.alpha(root.scheme.focus, 0)
        border.width: root.activeFocus ? Style.space.xxs : 0
        border.color: root.scheme.focus
        visible: root.activeFocus
    }
}
