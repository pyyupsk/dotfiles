import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Controls.impl as ControlsImpl
import "../code/Style.js" as Style
import "../code/NotificationView.js" as View

// The notification history, grouped by app like macOS Notification Center,
// with Do Not Disturb on top. Presentation only: the host owns the model.
ColumnLayout {
    id: root
    // From View.groups(): [{key, appName, appIcon, items: [{id, summary, body, createdMs, closable, hasDefaultAction}]}]
    property var groups: []
    property bool doNotDisturb: false
    property bool doNotDisturbAvailable: true
    property string doNotDisturbDetail: ""
    property var scheme: Style.scheme("dark")
    property double nowMs: Date.now()
    readonly property int total: groups.reduce((sum, group) => sum + group.items.length, 0)

    signal clearAllRequested()
    signal clearGroupRequested(string key)
    signal closeRequested(var id)
    signal activated(var id)
    signal doNotDisturbToggled(bool on)

    spacing: Style.space.md

    function timeText(createdMs) {
        const value = View.age(createdMs, nowMs);
        if (value.kind === "now") return qsTr("now");
        if (value.kind === "minutes") return qsTr("%1m ago").arg(value.value);
        if (value.kind === "hours") return qsTr("%1h ago").arg(value.value);
        if (value.kind === "date") return Qt.formatDate(new Date(value.value), "d MMM");
        return "";
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.space.sm
        Text {
            Layout.fillWidth: true
            text: qsTr("Notifications")
            textFormat: Text.PlainText
            font.pixelSize: Style.type.title
            font.weight: Style.weight.bold
            color: root.scheme.text
        }
        Controls.Button {
            objectName: "notificationsClearAll"
            text: qsTr("Clear All")
            enabled: root.total > 0
            flat: true
            onClicked: root.clearAllRequested()
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.space.sm
        ControlsImpl.IconImage {
            name: root.doNotDisturb ? "notifications-disabled-symbolic" : "notifications-symbolic"
            color: root.scheme.text
            sourceSize.width: Style.size.iconMd
            sourceSize.height: Style.size.iconMd
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: qsTr("Do Not Disturb")
                textFormat: Text.PlainText
                color: root.scheme.text
            }
            Text {
                objectName: "notificationsDoNotDisturbDetail"
                Layout.fillWidth: true
                visible: text.length > 0
                text: !root.doNotDisturbAvailable ? qsTr("Unavailable") : root.doNotDisturbDetail
                textFormat: Text.PlainText
                elide: Text.ElideRight
                font.pixelSize: Style.type.caption
                color: root.scheme.textMuted
            }
        }
        Controls.Switch {
            objectName: "notificationsDoNotDisturb"
            enabled: root.doNotDisturbAvailable
            checked: root.doNotDisturb
            Accessible.name: qsTr("Do Not Disturb")
            onToggled: root.doNotDisturbToggled(checked)
        }
    }

    Text {
        objectName: "notificationsEmpty"
        Layout.fillWidth: true
        Layout.topMargin: Style.space.lg
        Layout.bottomMargin: Style.space.lg
        visible: root.total === 0
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("No Notifications")
        textFormat: Text.PlainText
        color: root.scheme.textMuted
    }

    Controls.ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: Math.min(list.implicitHeight, Style.size.popupWidth * 1.4)
        visible: root.total > 0
        contentWidth: availableWidth
        Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
        ColumnLayout {
            id: list
            width: parent.width
            spacing: Style.space.sm
            Repeater {
                model: root.groups
                delegate: Rectangle {
                    id: groupCard
                    required property var modelData
                    objectName: "notificationGroup"
                    Layout.fillWidth: true
                    implicitHeight: groupColumn.implicitHeight + Style.space.md * 2
                    radius: Style.radius.module
                    color: Style.alpha(root.scheme.text, 0.06)
                    border.width: Style.size.divider
                    border.color: Style.alpha(root.scheme.text, 0.08)
                    ColumnLayout {
                        id: groupColumn
                        anchors.fill: parent
                        anchors.margins: Style.space.md
                        spacing: Style.space.sm
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Style.space.sm
                            ControlsImpl.IconImage {
                                name: View.iconSource(groupCard.modelData.appIcon) || "preferences-desktop-notification"
                                sourceSize.width: Style.size.iconMd
                                sourceSize.height: Style.size.iconMd
                            }
                            Text {
                                Layout.fillWidth: true
                                text: View.plain(groupCard.modelData.appName, View.limits.appName) || qsTr("App")
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                                font.weight: Style.weight.demiBold
                                color: root.scheme.text
                            }
                            Controls.Button {
                                objectName: "notificationGroupClear"
                                text: qsTr("Clear")
                                flat: true
                                Accessible.name: qsTr("Clear notifications from %1").arg(View.plain(groupCard.modelData.appName, View.limits.appName))
                                onClicked: root.clearGroupRequested(groupCard.modelData.key)
                            }
                        }
                        Repeater {
                            model: groupCard.modelData.items.slice(0, View.limits.groupItems)
                            delegate: ColumnLayout {
                                id: entry
                                required property var modelData
                                objectName: "notificationHistoryItem"
                                Layout.fillWidth: true
                                spacing: Style.space.xxs
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Style.space.sm
                                    Text {
                                        Layout.fillWidth: true
                                        text: View.plain(entry.modelData.summary, View.limits.summary)
                                        textFormat: Text.PlainText
                                        elide: Text.ElideRight
                                        font.weight: Style.weight.bold
                                        color: root.scheme.text
                                    }
                                    Text {
                                        text: root.timeText(entry.modelData.createdMs)
                                        textFormat: Text.PlainText
                                        font.pixelSize: Style.type.caption
                                        color: root.scheme.textMuted
                                    }
                                    Controls.ToolButton {
                                        objectName: "notificationHistoryClose"
                                        visible: entry.modelData.closable
                                        icon.name: "window-close-symbolic"
                                        display: Controls.AbstractButton.IconOnly
                                        Accessible.name: qsTr("Remove notification")
                                        Layout.preferredWidth: Style.size.iconButton
                                        Layout.preferredHeight: Style.size.iconButton
                                        onClicked: root.closeRequested(entry.modelData.id)
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    visible: text.length > 0
                                    text: View.plainBody(entry.modelData.body)
                                    textFormat: Text.PlainText
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                    color: root.scheme.text
                                }
                                TapHandler {
                                    enabled: entry.modelData.hasDefaultAction
                                    onTapped: root.activated(entry.modelData.id)
                                }
                            }
                        }
                        Text {
                            objectName: "notificationGroupMore"
                            visible: groupCard.modelData.items.length > View.limits.groupItems
                            text: qsTr("%1 more").arg(groupCard.modelData.items.length - View.limits.groupItems)
                            textFormat: Text.PlainText
                            font.pixelSize: Style.type.caption
                            color: root.scheme.textMuted
                        }
                    }
                }
            }
        }
    }
}
