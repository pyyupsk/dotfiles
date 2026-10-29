/*
    macOS style restart / shut down / log out alert. Replaces the Plasma
    desktop shell's logout/Logout.qml (copied there by a pacman hook).
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami as Kirigami

Item {
    id: root

    signal logoutRequested()
    signal haltRequested()
    signal haltUpdateRequested()
    signal suspendRequested(int spdMethod)
    signal rebootRequested()
    signal rebootRequested2(int opt)
    signal rebootUpdateRequested()
    signal cancelRequested()
    signal lockScreenRequested()
    signal cancelSoftwareUpdateRequested()

    property real remainingTime: 60

    readonly property string kind: sdtype === ShutdownType.ShutdownTypeReboot ? "reboot"
        : sdtype === ShutdownType.ShutdownTypeHalt ? "halt" : "logout"

    function accept() {
        if (kind === "reboot") {
            softwareUpdatePending ? rebootUpdateRequested() : rebootRequested();
        } else if (kind === "halt") {
            softwareUpdatePending ? haltUpdateRequested() : haltRequested();
        } else {
            logoutRequested();
        }
    }

    readonly property var text: ({
        reboot: ["system-reboot", "Are you sure you want to restart your computer now?", "restart", "Restart"],
        halt: ["system-shutdown", "Are you sure you want to shut down your computer now?", "shut down", "Shut Down"],
        logout: ["system-log-out", "Are you sure you want to quit all applications and log out now?", "log you out", "Log Out"]
    })[kind]

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: if (--root.remainingTime <= 0) root.accept()
    }

    QQC2.Action { shortcut: "Escape"; onTriggered: root.cancelRequested() }
    QQC2.Action { shortcut: "Return"; onTriggered: root.accept() }
    QQC2.Action { shortcut: "Enter"; onTriggered: root.accept() }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.cancelRequested()
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: 280
        height: column.implicitHeight + 40
        radius: 26
        color: Qt.rgba(0.16, 0.16, 0.17, 0.96)
        border.color: Qt.rgba(1, 1, 1, 0.14)
        border.width: 1

        // swallow clicks so only clicks outside the alert cancel it
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            Kirigami.Icon {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                source: root.text[0]
            }

            QQC2.Label {
                Layout.fillWidth: true
                Layout.topMargin: 4
                text: root.text[1]
                color: "white"
                font.pixelSize: 13
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            QQC2.Label {
                Layout.fillWidth: true
                text: root.kind === "logout"
                    ? `If you do nothing, the system will ${root.text[2]} automatically in ${root.remainingTime} seconds.`
                    : `If you do nothing, the computer will ${root.text[2]} automatically in ${root.remainingTime} seconds.`
                color: Qt.rgba(1, 1, 1, 0.85)
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 8

                Repeater {
                    model: [
                        { label: "Cancel", primary: false },
                        { label: root.text[3], primary: true }
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        radius: height / 2
                        color: modelData.primary
                            ? (press.pressed ? "#0064d2" : "#0a84ff")
                            : (press.pressed ? Qt.rgba(1, 1, 1, 0.24) : Qt.rgba(1, 1, 1, 0.14))

                        QQC2.Label {
                            anchors.centerIn: parent
                            text: parent.modelData.label
                            color: "white"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: press
                            anchors.fill: parent
                            onClicked: parent.modelData.primary ? root.accept() : root.cancelRequested()
                        }
                    }
                }
            }
        }
    }
}
